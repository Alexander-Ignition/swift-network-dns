//
//  DNSClass.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 10.02.2024.
//

/// DNS Class.
///
/// CLASS fields appear in resource records. QCLASS fields appear in the question section of a query.
/// QCLASS values are a superset of CLASS values; every CLASS is a valid QCLASS.
///
/// [3.2.4. CLASS values](https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.4)
public struct DNSClass: RawRepresentable, Hashable, Sendable {
    /// IN  1 the Internet
    public static let `in` = DNSClass(rawValue: 1)

    /// CS 2 the CSNET class (Obsolete - used only for examples in some obsolete RFCs)
    public static let cs = DNSClass(rawValue: 2)

    /// CH 3 the CHAOS class
    public static let ch = DNSClass(rawValue: 3)

    /// HS 4 Hesiod [Dyer 87]
    public static let hs = DNSClass(rawValue: 4)

    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension DNSClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .in:
            return "IN"
        case .cs:
            return "CS"
        case .ch:
            return "CH"
        case .hs:
            return "HS"
        default:
            return "\(rawValue)"
        }
    }
}
