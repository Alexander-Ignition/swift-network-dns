//
//  DNSResponseTests.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 09.02.2024.
//

import XCTest
@testable import NetworkDNS

final class DNSResponseTests: XCTestCase {

    func testInitWithData() throws {
        // big endian response data
        let data = Data([
            // Header
            0x0C, 0x54, // ID
            0x80, 0x80, // QR, Opcode, AA, TC, RD, RA, Z, RCODE
            0x00, 0x01, // QDCOUNT
            0x00, 0x01, // ANCOUNT
            0x00, 0x00, // NSCOUNT
            0x00, 0x00, // ARCOUNT

            // Question
            0x06, 0x67, // 6, g
            0x6F, 0x6F, // o, o
            0x67, 0x6C, // g, l
            0x65, 0x02, // e, 2
            0x72, 0x75, // r, u
            0x00,       // END QNAME
            0x00, 0x01, // QTYPE
            0x00, 0x01, // QCLASS

            // Answer
            0xC0, 0x0C, // NAME reference to
            0x00, 0x01, // RTYPE
            0x00, 0x01, // RCLASS
            0x00, 0x00, // TTL
            0x00, 0x7A,
            0x00, 0x04, // RDLENGTH
            0x40, 0xE9, // RDATA
            0xA4, 0x5E
        ])
        let response = try DNSResponse(data: data)
        
        XCTAssertEqual(response.header.id, 0x0C54)
        XCTAssertTrue(response.header.isResponse)
        XCTAssertEqual(response.header.opcode, .query)
        XCTAssertFalse(response.header.isAuthoritativeAnswer)
        XCTAssertFalse(response.header.isTrunCation)
        XCTAssertFalse(response.header.isRecursionDesired)
        XCTAssertTrue(response.header.isRecursionAvailable)
        XCTAssertEqual(response.header.responseCode, .success)
        XCTAssertEqual(response.header.questionCount, 1)
        XCTAssertEqual(response.header.answerCount, 1)
        XCTAssertEqual(response.header.authorityCount, 0)
        XCTAssertEqual(response.header.additionalCount, 0)
        XCTAssertEqual(response.questions.count, 1)
        XCTAssertEqual(response.answers.count, 1)
        XCTAssertEqual(response.authorities.count, 0)
        XCTAssertEqual(response.additional.count, 0)

        let question = try XCTUnwrap(response.questions.first)

        XCTAssertEqual(question.domain, "google.ru")
        XCTAssertEqual(question.qType, .a)
        XCTAssertEqual(question.qClass, .in)

        let answer = try XCTUnwrap(response.answers.first)

        XCTAssertEqual(answer.name, "google.ru")
        XCTAssertEqual(answer.rType, .a)
        XCTAssertEqual(answer.rClass, .in)
        XCTAssertEqual(answer.ttl, 0x00_00_00_7A)
        XCTAssertEqual(answer.data, Data([0x40, 0xE9, 0xA4, 0x5E]))
    }
}
