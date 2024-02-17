//
//  DNSService.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 09.02.2024.
//

import Foundation
import Network

extension NWEndpoint.Port {
    /// Default DNS port.
    public static let dns = NWEndpoint.Port(rawValue: 53)!
}

public final class DNSService: Sendable {
    public let endpoint: NWEndpoint
    public let queue: DispatchQueue

    public struct Configuration {
        public var endpoint: NWEndpoint
        public var queue: DispatchQueue
        public var timeout: TimeInterval
    }

    public convenience init(
        host: NWEndpoint.Host,
        port: NWEndpoint.Port = .dns,
        queue: DispatchQueue
    ) {
        let endpoint = NWEndpoint.hostPort(host: host, port: port)
        self.init(endpoint: endpoint, queue: queue)
    }

    public init(endpoint: NWEndpoint, queue: DispatchQueue) {
        self.endpoint = endpoint
        self.queue = queue
    }

    public func send(_ query: DNSQuery) async throws -> DNSResponse {
        let connection = makeConnection()
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                connection.send(query, queue: queue) { result in
                    continuation.resume(with: result)
                }
            }
        } onCancel: {
            connection.cancel()
        }
    }

    public typealias ResponseHandler = (_ result: Result<DNSResponse, any Error>) -> Void

    @discardableResult
    public func send(
        _ query: DNSQuery,
        completion: @escaping ResponseHandler
    ) -> NWConnection? {
        let connection = makeConnection()
        connection.send(query, queue: queue, completion: completion)
        return connection
    }

    private func makeConnection() -> NWConnection {
        NWConnection(to: endpoint, using: .udp)
    }
}

// MARK: - NWConnection + DNS

extension NWConnection {
    fileprivate func send(
        _ query: DNSQuery,
        queue: DispatchQueue,
        completion: @escaping DNSService.ResponseHandler
    ) {
        let content: Data
        do {
            content = try query.dataRepresentation()
        } catch {
            queue.async {
                completion(.failure(error))
            }
            return
        }
        stateUpdateHandler = { newState in
            // print("state: \(newState)")
            
            switch newState {
            case .ready:
                self.send(content: content, completion: .contentProcessed { error in
                    guard let error else { return }
                    self.cancel()
                    completion(.failure(error))
                })
            case .failed(let error):
                completion(.failure(error))
            default:
                break
            }
        }
        receiveMessage { content, contentContext, isComplete, error in
            defer {
                self.cancel()
            }
            if let error {
                completion(.failure(error))
                return
            }
            guard let content, isComplete else {
                fatalError()
            }
            let response = try! DNSResponse(data: content)
            completion(.success(response))
        }
        start(queue: queue)
    }
}
