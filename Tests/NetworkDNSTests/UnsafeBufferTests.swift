//
//  UnsafeBufferTests.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 09.02.2024.
//

import XCTest
@testable import NetworkDNS

final class UnsafeBufferTests: XCTestCase {

    func testReadUInt16() throws {
        var bytes: [UInt8] = [
            1, 0,
            0, 1,
        ]
        try bytes.withUnsafeMutableBytes { ptr in
            var buffer = UnsafeBuffer(ptr)

            XCTAssertFalse(buffer.isEmpty)
            XCTAssertEqual(buffer.count, 4)
            XCTAssertEqual(buffer.base.count, 4)
            XCTAssertEqual(try buffer.readInteger(UInt16.self), 256, "UInt8.max + 1")

            XCTAssertFalse(buffer.isEmpty)
            XCTAssertEqual(buffer.count, 2)
            XCTAssertEqual(buffer.base.count, 4)
            XCTAssertEqual(try buffer.readInteger(UInt16.self), 1)

            XCTAssertTrue(buffer.isEmpty)
            XCTAssertEqual(buffer.count, 0)
            XCTAssertEqual(buffer.base.count, 4)
        }
    }

    func testBigEndian() {
        XCTAssertFalse(UInt8.isBigEndian)
        let number: UInt32 = 0x12345678
        XCTAssertNotEqual(number, number.bigEndian)
        XCTAssertEqual(number, number.bigEndian.bigEndian)
    }

    func testCompressionPointer() {
        XCTAssertTrue(UInt8(0b1100_0011).isCompressionPointer)
        XCTAssertFalse(UInt8(0b0100_0011).isCompressionPointer)
        XCTAssertFalse(UInt8(0b1000_0011).isCompressionPointer)
    }

    func testCompressionOffset() {
        XCTAssertEqual(UInt16(0b1100_0000_0000_0011).compressionOffset, UInt16(0b0000_0000_0000_0011))
    }
}
