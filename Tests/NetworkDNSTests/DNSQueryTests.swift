//
//  DNSQueryTests.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 09.02.2024.
//

import XCTest
@testable import NetworkDNS

final class DNSQueryTests: XCTestCase {

    func testInit() {
        let query = DNSQuery()
        XCTAssertEqual(query.questions, [])
    }

    func testDataRepresentation() {
        var query = DNSQuery.question(domain: "example.com", type: .a)
        query.header.id = 15
        query.header.parameters = 0x0100

        let expected = Data([
            0x00, 0x0F, // - ID
            0x01, 0x00, // – QR, Opcode, AA, TC, RD, RA, Z, RCODE
            0x00, 0x01, // – QDCOUNT
            0x00, 0x00, // – ANCOUNT
            0x00, 0x00, // – NSCOUNT
            0x00, 0x00, // – ARCOUNT

            0x07, 0x65, // – 7, e
            0x78, 0x61, // – x, a
            0x6D, 0x70, // – m, p
            0x6C, 0x65, // – l, e
            0x03, 0x63, // – 3, c
            0x6F, 0x6D, // – o, m
            0x00,       // - end QNAME
            0x00, 0x01, // – QTYPE
            0x00, 0x01, // – QCLASS
        ])
        XCTAssertEqual(try query.dataRepresentation().hex, expected.hex)
    }
}
