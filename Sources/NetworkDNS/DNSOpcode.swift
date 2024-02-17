//
//  DNSOpcode.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 12.02.2024.
//

/// A four bit field that specifies kind of query in this message.
public struct DNSOpcode: RawRepresentable, Hashable, Sendable {
    /// 0 a standard query (QUERY)
    public static let query = DNSOpcode(rawValue: 0)

    /// an inverse query (IQUERY)
    public static let inverseQuery = DNSOpcode(rawValue: 1)

    /// a server status request (STATUS)
    public static let status = DNSOpcode(rawValue: 2)

    // 3-15 reserved for future use

    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension DNSOpcode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .query:
            return ".query"
        case .inverseQuery:
            return ".inverseQuery"
        case .status:
            return ".status"
        default:
            return "\(rawValue)"
        }
    }
}
