//
//  DNSHeaderTests.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 09.02.2024.
//

import XCTest
@testable import NetworkDNS

final class DNSHeaderTests: XCTestCase {
    private var id: UInt16 = 0

    override func setUp() {
        super.setUp()
    }

    func testLength() {
        XCTAssertEqual(DNSHeader.length, 12, "number of bytes [UInt8]")
    }

    func testIsResponse() {
        var header = DNSHeader()
        XCTAssertFalse(header.isResponse, "is query")

        header.parameters = 0b1000_0000_0000_0000
        XCTAssertTrue(header.isResponse, "is response")
    }

    func testOpcode() {
        var header = DNSHeader()
        XCTAssertEqual(header.opcode, .query)

        header.parameters = 0b0000_1000_0000_0000
        XCTAssertEqual(header.opcode, .inverseQuery)

        header.parameters = 0b0001_0000_0000_0000
        XCTAssertEqual(header.opcode, .status)
    }

    func testIsAuthoritativeAnswer() {
        var header = DNSHeader()
        XCTAssertFalse(header.isAuthoritativeAnswer)

        header.parameters = 0b0000_0100_0000_0000
        XCTAssertTrue(header.isAuthoritativeAnswer)
    }

    func testIsTrunCation() {
        var header = DNSHeader()
        XCTAssertFalse(header.isTrunCation)

        header.parameters = 0b0000_0010_0000_0000
        XCTAssertTrue(header.isTrunCation)
    }

    func testIsRecursionDesired() {
        var header = DNSHeader()
        XCTAssertFalse(header.isRecursionDesired)

        header.parameters = 0b0000_0001_0000_0000
        XCTAssertTrue(header.isRecursionDesired)

        header.parameters = 0b1000_0000_0000_0000
        XCTAssertFalse(header.isRecursionDesired)

        header.isRecursionDesired = true
        XCTAssertTrue(header.isRecursionDesired)
        XCTAssertEqual(header.parameters, 0b1000_0001_0000_0000)

        header.isRecursionDesired = false
        XCTAssertFalse(header.isRecursionDesired)
        XCTAssertEqual(header.parameters, 0b1000_0000_0000_0000)
    }

    func testIsRecursionAvailable() {
        var header = DNSHeader()
        XCTAssertFalse(header.isRecursionAvailable)

        header.parameters = 0b0000_0000_1000_0000
        XCTAssertTrue(header.isRecursionAvailable)
    }

    func testZ() {
        var header = DNSHeader()
        XCTAssertEqual(header.z, 0)

        header.parameters = 0b0000_0000_0111_0000
        XCTAssertEqual(header.z, 0b0000_0000_0000_0111)
    }

    func testResponseCode() {
        var header = DNSHeader()
        
        header.parameters = 0
        XCTAssertEqual(header.responseCode, .success)

        header.parameters = 1
        XCTAssertEqual(header.responseCode, .formatError)

        header.parameters = 2
        XCTAssertEqual(header.responseCode, .serverFailure)

        header.parameters = 3
        XCTAssertEqual(header.responseCode, .nameError)

        header.parameters = 4
        XCTAssertEqual(header.responseCode, .notImplemented)

        header.parameters = 5
        XCTAssertEqual(header.responseCode, .refused)

        header.parameters = 0b0000_0000_0001_0000
        XCTAssertEqual(header.responseCode, .success)
    }

    func testInitWithBuffer() throws {
        var bytes: [UInt8] = [
            0xAA, 0xAA, // – Тот же ID, как и раньше
            0x81, 0x80, // – Другие флаги, разберём их ниже
            0x00, 0x01, // – 1 вопрос
            0x00, 0x01, // – 1 ответ
            0x00, 0x00, // – Нет записей об уполномоченных серверах
            0x00, 0x00, // – Нет дополнительных записей
        ]
        try bytes.withUnsafeMutableBytes { buf in
            var buffer = UnsafeBuffer(buf)
            let header = try DNSHeader(buffer: &buffer)

            XCTAssertEqual(header.id, 0xAA_AA)
            XCTAssertTrue(header.isResponse)
            XCTAssertFalse(header.isAuthoritativeAnswer)
            XCTAssertTrue(header.isRecursionDesired)
            XCTAssertTrue(header.isRecursionAvailable)
            XCTAssertEqual(header.responseCode, .success)
            XCTAssertEqual(header.questionCount, 1)
            XCTAssertEqual(header.answerCount, 1)
            XCTAssertEqual(header.authorityCount, 0)
            XCTAssertEqual(header.additionalCount, 0)
        }
    }

    func testWriteToBuffer() {
        var header = DNSHeader(id: 0xAA_AA)
        header.questionCount = 1

        var data = Data(count: DNSHeader.length)
        data.withUnsafeMutableBytes { ptr in
            var buffer = UnsafeBuffer(ptr)
            header.write(to: &buffer)
        }
        let expected = Data([
            0xAA, 0xAA, // - ID
            0x00, 0x00, // – QR, Opcode, AA, TC, RD, RA, Z, RCODE
            0x00, 0x01, // – QDCOUNT
            0x00, 0x00, // – ANCOUNT
            0x00, 0x00, // – NSCOUNT
            0x00, 0x00, // – ARCOUNT
        ])
        XCTAssertEqual(data.count, expected.count)
        XCTAssertEqual(data.hex, expected.hex)
        XCTAssertEqual(data.count, DNSHeader.length)
    }
}
