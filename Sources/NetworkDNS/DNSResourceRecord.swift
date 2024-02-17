//
//  DNSResourceRecord.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 08.02.2024.
//

import Foundation

/// Resource record format
///
/// The answer, authority, and additional sections all share the same
/// format: a variable number of resource records, where the number of
/// records is specified in the corresponding count field in the header.
public struct DNSResourceRecord: Hashable, Sendable {
    /// NAME a domain name to which this resource record pertains.
    public let name: String

    /// TYPE two octets containing one of the RR type codes.
    ///
    /// This field specifies the meaning of the data in the RDATA field.
    public let rType: DNSType

    /// CLASS two octets which specify the class of the data in the RDATA field.
    public let rClass: DNSClass

    /// Time to live.
    ///
    /// TTL a 32 bit unsigned integer that specifies the time
    /// interval (in seconds) that the resource record may be
    /// cached before it should be discarded.
    ///
    /// Zero values are interpreted to mean that the RR can only be used for the
    /// transaction in progress, and should not be cached.
    public let ttl: UInt32

    /// RDATA a variable length string of octets that describes the resource.
    ///
    /// The format of this information varies according to the TYPE and CLASS of the resource record.
    /// For example, the if the TYPE is A and the CLASS is IN, the RDATA field is a 4 octet ARPA Internet address.
    public let data: Data

    init(buffer: inout UnsafeBuffer) throws {
        name = try buffer.readDomainName()
        rType = DNSType(rawValue: try buffer.readInteger(UInt16.self))
        rClass = DNSClass(rawValue: try buffer.readInteger(UInt16.self))
        ttl = try buffer.readInteger(UInt32.self)

        /// RDLENGTH an unsigned 16 bit integer that specifies the length in octets of the RDATA field.
        let length = try buffer.readInteger(UInt16.self)
        let bytes = buffer.readBytes(length: Int(length))
        data = Data(bytes)
    }

    public var ipv4: String? {
        guard rType == .a, data.count >= MemoryLayout<in_addr>.size else {
            return nil
        }
        return data.withUnsafeBytes { buffer in
            var bytes = [CChar](repeating: 0, count: Int(INET_ADDRSTRLEN))
            inet_ntop(AF_INET, buffer.baseAddress, &bytes, socklen_t(INET_ADDRSTRLEN))
            return String(cString: bytes)
        }
    }
}
