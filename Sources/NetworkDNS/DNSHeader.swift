//
//  DNSHeader.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 07.02.2024.
//

import Foundation

// https://datatracker.ietf.org/doc/html/rfc1035#page-26

/// [Header section format](https://datatracker.ietf.org/doc/html/rfc1035#page-26)
public struct DNSHeader: Hashable, Sendable, Identifiable {
    public static let length = 12 // number of bytes [UInt8]

    struct Parameters: OptionSet, Hashable, Sendable {
        var rawValue: UInt16

        static let qr       = Parameters(rawValue: 0b1000_0000_0000_0000)
        static let opcode   = Parameters(rawValue: 0b0111_1000_0000_0000)
        static let aa       = Parameters(rawValue: 0b0000_0100_0000_0000)
        static let tc       = Parameters(rawValue: 0b0000_0010_0000_0000)
        static let rd       = Parameters(rawValue: 0b0000_0001_0000_0000)
        static let ra       = Parameters(rawValue: 0b0000_0000_1000_0000)
        static let z        = Parameters(rawValue: 0b0000_0000_0111_0000)
        static let rcode    = Parameters(rawValue: 0b0000_0000_0000_1111)
    }

    /// A 16 bit identifier assigned by the program that generates any kind of query.
    ///
    /// This identifier is copied the corresponding reply and can be used by the requester
    /// to match up replies to outstanding queries.
    public var id: UInt16

    /// QR, Opcode, AA, TC, RD, RA, Z , RCODE
    var parameters = Parameters(rawValue: 0)

    /// QR. A one bit field that specifies whether this message is a query (0), or a response (1).
    public var isResponse: Bool {
        parameters.contains(.qr)
    }

    /// A four bit field that specifies kind of query in this message.
    ///
    /// This value is set by the originator of a query and copied into the response.
    public var opcode: DNSOpcode {
        DNSOpcode(rawValue: (parameters.rawValue & Parameters.opcode.rawValue) >> 11)
    }

    /// AA. Authoritative Answer - this bit is valid in responses,
    /// and specifies that the responding name server is an
    /// authority for the domain name in question section.
    ///
    /// Note that the contents of the answer section may have multiple owner names because of aliases.
    /// The AA bit corresponds to the name which matches the query name, or the first owner name in the answer section.
    public var isAuthoritativeAnswer: Bool {
        parameters.contains(.aa)
    }

    /// TrunCation - specifies that this message was truncated due to length greater than that permitted on the transmission channel.
    public var isTrunCation: Bool {
        parameters.contains(.tc)
    }

    /// Recursion Desired - this bit may be set in a query and is copied into the response.
    ///
    /// If RD is set, it directs the name server to pursue the query recursively. Recursive query support is optional.
    public var isRecursionDesired: Bool {
        get {
            parameters.contains(.rd)
        }
        set {
            if newValue {
                parameters.insert(.rd)
            } else {
                parameters.remove(.rd)
            }
        }
    }

    /// Recursion Available - this be is set or cleared in a response, and denotes
    /// whether recursive query support is available in the name server.
    public var isRecursionAvailable: Bool {
        parameters.contains(.ra)
    }

    /// Z Reserved for future use.  Must be zero in all queries and responses.
    var z: UInt16 {
        (parameters.rawValue & Parameters.z.rawValue) >> 4
    }

    /// Response code - this 4 bit field is set as part of responses.
    public var responseCode: DNSResponseCode {
        DNSResponseCode(rawValue: parameters.rawValue & Parameters.rcode.rawValue)
    }

    /// QDCOUNT an unsigned 16 bit integer specifying the number of entries in the question section.
    public var questionCount: UInt16 = 0

    /// ANCOUNT an unsigned 16 bit integer specifying the number of resource records in the answer section.
    public var answerCount: UInt16 = 0

    /// NSCOUNT an unsigned 16 bit integer specifying the number of name server resource records in the authority records section.
    public var authorityCount: UInt16 = 0

    /// ARCOUNT an unsigned 16 bit integer specifying the number of resource records in the Additional Records section.
    public var additionalCount: UInt16 = 0
    
    /// A new DNS query header.
    ///
    /// - Parameter id: a unique identifier for the matching query and response.
    public init(id: UInt16) {
        self.id = id
    }

    /// A new DNS query header with random `id`.
    public init() {
        self.init(id: UInt16.random(in: 0..<UInt16.max))
    }

    /// DNS response header.
    ///
    /// - Parameter buffer: DNS response buffer.
    init(buffer: inout UnsafeBuffer) throws {
        self.id = try buffer.readInteger(UInt16.self)
        self.parameters = Parameters(rawValue: try buffer.readInteger(UInt16.self))
        self.questionCount = try buffer.readInteger(UInt16.self)
        self.answerCount = try buffer.readInteger(UInt16.self)
        self.authorityCount = try buffer.readInteger(UInt16.self)
        self.additionalCount = try buffer.readInteger(UInt16.self)
    }

    func write(to buffer: inout UnsafeBuffer) {
        buffer.write(id)
        buffer.write(parameters.rawValue)
        buffer.write(questionCount)
        buffer.write(answerCount)
        buffer.write(authorityCount)
        buffer.write(additionalCount)
    }
}

// MARK: - CustomStringConvertible

extension DNSHeader: CustomStringConvertible {
    public var description: String {
        [
            "DNSHeader(id: \(id)",
            "isResponse: \(isResponse)",
            "opcode: \(opcode)",
            "isAuthoritativeAnswer: \(isAuthoritativeAnswer)",
            "isTrunCation: \(isTrunCation)",
            "isRecursionDesired: \(isRecursionDesired)",
            "isRecursionAvailable: \(isRecursionAvailable)",
            "z: \(z)",
            "responseCode: \"\(responseCode)\"",
            "questionCount: \(questionCount)",
            "answerCount: \(answerCount)",
            "authorityCount: \(authorityCount)",
            "additionalCount: \(additionalCount))"
        ].joined(separator: ", ")
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension DNSHeader.Parameters: ExpressibleByIntegerLiteral {
    init(integerLiteral value: UInt16) {
        self.rawValue = value
    }
}

