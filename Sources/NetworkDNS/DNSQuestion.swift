//
//  DNSQuestion.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 08.02.2024.
//

import Foundation

/// Question section format
///
/// The question section is used to carry the "question" in most queries, i.e., the parameters that define what is being asked.
public struct DNSQuestion: Hashable, Sendable {
    private static let separator: Character = "."

    /// QNAME a domain name represented as a sequence of labels, where
    /// each label consists of a length octet followed by that number of octets.
    ///
    /// The domain name terminates with the zero length octet for the null label of the root.
    ///
    /// - Note: that this field may be an odd number of octets; no padding is used.
    public var domain: String

    /// QTYPE a two octet code which specifies the type of the query.
    ///
    /// The values for this field include all codes valid for a
    /// TYPE field, together with some more general codes which
    /// can match more than one type of RR.
    public var qType: DNSType

    /// QCLASS a two octet code that specifies the class of the query.
    ///
    /// For example, the QCLASS field is IN for the Internet.
    public var qClass: DNSClass

    var length: Int { domain.utf8.count + 6 }

    public init(domain: String, qType: DNSType, qClass: DNSClass) {
        self.domain = domain
        self.qType = qType
        self.qClass = qClass
    }

    init(buffer: inout UnsafeBuffer) throws {
        domain = try buffer.readDomainName()
        qType = DNSType(rawValue: try buffer.readInteger(UInt16.self))
        qClass = DNSClass(rawValue: try buffer.readInteger(UInt16.self))
    }

    func write(to buffer: inout UnsafeBuffer) {
        buffer.writeDomain(domain)
        buffer.write(qType.rawValue)
        buffer.write(qClass.rawValue)
    }
}
