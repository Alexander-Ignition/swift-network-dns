//
//  File.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 09.02.2024.
//

import Foundation

public struct DNSQuery: Sendable {
    public var header = DNSHeader()

    public var questions: [DNSQuestion] = [] {
        didSet {
            header.questionCount = UInt16(questions.count)
        }
    }

    public var length: Int {
        DNSHeader.length + questions.reduce(0) { $0 + $1.length }
    }

    /// A new empty query.
    public init() {}
    
    /// A new query with one question.
    ///
    /// - Parameters:
    ///   - domain: domain name.
    ///   - type: DNS type.
    /// - Returns: A new query.
    public static func question(domain: String, type: DNSType) -> DNSQuery {
        let questions = DNSQuestion(domain: domain, qType: type, qClass: .in)
        var query = DNSQuery()
        query.questions.append(questions)
        query.header.isRecursionDesired = true
        return query
    }

    public func dataRepresentation() throws -> Data {
        var data = Data(count: length)
        data.withUnsafeMutableBytes { ptr in
            var buffer = UnsafeBuffer(ptr)
            write(to: &buffer)
        }
        return data
    }

    private func write(to buffer: inout UnsafeBuffer) {
        header.write(to: &buffer)
        questions.forEach { $0.write(to: &buffer) }
    }
}
