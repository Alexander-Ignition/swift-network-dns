//
//  DNSResponse.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 09.02.2024.
//

import Foundation

public struct DNSResponse: Sendable {
    public static let minimumLength = DNSHeader.length
    public static let maximumLength = 512 // UDP messages 512 octets or less

    public var header: DNSHeader

    /// The question for the name server.
    public var questions: [DNSQuestion]

    /// Resource records holding additional information
    public var answers: [DNSResourceRecord]

    /// Resource records pointing toward an authority
    public var authorities: [DNSResourceRecord]

    /// Resource records holding additional information
    public var additional: [DNSResourceRecord]

    public init(
        header: DNSHeader,
        questions: [DNSQuestion],
        answers: [DNSResourceRecord],
        authorities: [DNSResourceRecord],
        additional: [DNSResourceRecord]
    ) {
        self.header = header
        self.questions = questions
        self.answers = answers
        self.authorities = authorities
        self.additional = additional
    }

    public init(data: Data) throws {
        // TODO: check length
        var copy = data
        self = try copy.withUnsafeMutableBytes { ptr in
            var buffer = UnsafeBuffer(ptr)
            let header = try DNSHeader(buffer: &buffer)

            return DNSResponse(
                header: header,
                questions: try (0..<header.questionCount).map { _ in try DNSQuestion(buffer: &buffer) },
                answers: try (0..<header.answerCount).map { _ in try DNSResourceRecord(buffer: &buffer) },
                authorities: [],
                additional: []
            )
        }
    }
}
