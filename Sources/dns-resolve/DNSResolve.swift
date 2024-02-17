import Foundation
import NetworkDNS

@main
struct DNSResolve {
    static func main() async throws {
        let queue = DispatchQueue(label: "swift-network-dns", qos: .utility)
        let service = DNSService(host: "8.8.8.8", queue: queue)

        let response = try await service.send(.question(domain: "google.com", type: .a))
        response.answers.forEach { record in
            print("IPv4: \(record.ipv4 ?? "nil"), \(record.name)")
        }
        let code = response.header.responseCode
        if code != .success {
            print(response, to: &standardError)
            print(code, to: &standardError)
        }
        exit(Int32(code.rawValue))

    }
}

var standardError = FileHandle.standardError

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        try! write(contentsOf: Data(string.utf8))
    }
}
