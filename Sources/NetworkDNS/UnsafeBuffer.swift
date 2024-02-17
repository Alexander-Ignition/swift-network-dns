//
//  UnsafeBuffer.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 07.02.2024.
//

import Foundation

public enum SerializationError: Error {
    case outOfBounds(index: Int, maximum: Int)
}

struct UnsafeBuffer { // CompressionBuffer
    typealias Buffer = UnsafeMutableRawBufferPointer
    typealias Index = Buffer.Index

    /// Underlying byte buffer.
    let base: Buffer

    /// The start index of reading or writing.
    private(set) var startIndex: Index

    @inlinable
    var endIndex: Index { base.endIndex }
    
    @inlinable
    var isEmpty: Bool { startIndex == endIndex }

    @inlinable
    var count: Index.Stride { base.distance(from: startIndex, to: endIndex) }

    init(_ buffer: Buffer) {
        self.base = buffer
        self.startIndex = buffer.startIndex
    }

    func require(length: Int) throws {
        if length >= count  {
            throw SerializationError.outOfBounds(index: startIndex + length, maximum: endIndex)
        }
    }

    // MARK: - Writing

    @inlinable
    mutating func write(_ byte: UInt8) {
        precondition(!isEmpty)
        base[startIndex] = byte.bigEndian
        base.formIndex(after: &startIndex)
    }

    @inlinable
    mutating func write(_ number: UInt16) {
        write(UInt8(number >> 8))
        write(UInt8(number & 0x00ff))
    }

    // MARK: - Reading

    @inlinable
    mutating func readInteger<T: FixedWidthInteger>(
        _ integerType: T.Type = T.self
    ) throws -> T {
        let size = MemoryLayout<T>.size
        //try require(length: size)
        let value = base.loadUnaligned(fromByteOffset: startIndex, as: integerType)
        startIndex += size
        return value.bigEndian
    }

    mutating func readBytes(length: Int) -> [UInt8] {
        let index = base.index(startIndex, offsetBy: length)
        let slice = base[startIndex..<index].map { $0.bigEndian }
        startIndex = index
        return slice
    }
}

// MARK: - Domain name

extension UInt8 {
    @inlinable
    var isCompressionPointer: Bool { (self >> 6) == 0b0000_0011 }
}

extension UInt16 {
    @inlinable
    var compressionOffset: UInt16 { self & UInt16(0b0011_1111_1111_1111) }
}

extension UnsafeBuffer {
    private static let separator: Character = "."
    private static let maximumNameLength = 255 //
    private static let maximumLabelLength = 63 // 0b0011_1111

    @inlinable
    mutating func writeDomain(_ name: String) {
        assert(name.utf8.count <= Self.maximumNameLength)
        name.split(separator: Self.separator).forEach { label in
            let text = label.utf8
            assert(text.count <= Self.maximumLabelLength)
            write(UInt8(text.count))
            text.forEach { write($0) }
        }
        write(UInt8.zero) // end
    }

    mutating func readDomainName() throws -> String {
        try require(length: 1)
        if base[startIndex].isCompressionPointer {
            let offset = try readInteger(UInt16.self).compressionOffset
            let currentIndex = startIndex
            defer {
                startIndex = currentIndex
            }
            startIndex = base.index(base.startIndex, offsetBy: Int(offset))
            return try readLabels()
        }
        return try readLabels()
    }

    private mutating func readLabels() throws -> String {
        var labels: [String] = []
        var length = try readInteger(UInt8.self)

        while length > 0 {
            let bytes = readBytes(length: Int(length))
            labels.append(String(bytes: bytes, encoding: .utf8)!)
            length = try readInteger(UInt8.self)
        }
        return labels.joined(separator: String(Self.separator))
    }
}

// MARK: - Debug

#if DEBUG

extension UInt8 {
    static let isBigEndian: Bool = {
        let number: UInt32 = 0x12345678
        return number == number.bigEndian
    }()

    @inlinable
    var hex: String { String(format: "0x%02hhX", self) }

    @inlinable
    var binary: String { String(format: "0b%08d", self) }
}

extension Collection<UInt8> {
    @inlinable
    var hex: String { map(\.hex).joined(separator: ", ") }

    @inlinable
    var binary: String { map(\.binary).joined(separator: ", ") }
}

#endif
