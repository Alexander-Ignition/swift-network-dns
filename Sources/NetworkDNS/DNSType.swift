//
//  DNSType.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 08.02.2024.
//

import Foundation

/// DNS Type.
///
/// TYPE fields are used in resource records. QTYPE fields appear in the question part of a query.
/// QTYPES are a superset of TYPEs, hence all TYPEs are valid QTYPEs.
/// 
/// [3.2.2. TYPE values](https://datatracker.ietf.org/doc/html/rfc1035#section-3.2.2)
public struct DNSType: RawRepresentable, Hashable, Sendable {
    /// A a IPv4 host address.
    public static let a = DNSType(rawValue: 1)

    /// NS an authoritative name server
    public static let ns = DNSType(rawValue: 2)

    /// MD a mail destination (Obsolete - use MX)
    public static let md = DNSType(rawValue: 3)

    /// a mail forwarder (Obsolete - use MX)
    public static let mf = DNSType(rawValue: 4)

    /// the canonical name for an alias
    public static let cname = DNSType(rawValue: 5)

    /// marks the start of a zone of authority
    public static let soa = DNSType(rawValue: 6)

    /// a mailbox domain name (EXPERIMENTAL)
    public static let mb = DNSType(rawValue: 7)

    /// a mail group member (EXPERIMENTAL)
    public static let mg = DNSType(rawValue: 8)

    /// a mail rename domain name (EXPERIMENTAL)
    public static let mr = DNSType(rawValue: 9)

    /// a null RR (EXPERIMENTAL)
    public static let null = DNSType(rawValue: 10)

    /// a well known service description
    public static let wks = DNSType(rawValue: 11)

    /// a domain name pointer
    public static let ptr = DNSType(rawValue: 12)

    /// host information
    public static let hinfo = DNSType(rawValue: 13)

    /// mailbox or mail list information
    public static let minfo = DNSType(rawValue: 14)

    /// mail exchange
    public static let ms = DNSType(rawValue: 15)

    /// text strings
    public static let txt = DNSType(rawValue: 16)

    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension DNSType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .a:
            return "A"
        case .ns:
            return "NS"
        case .md:
            return "MD"
        default:
            return "\(rawValue))"
        }
    }
}
