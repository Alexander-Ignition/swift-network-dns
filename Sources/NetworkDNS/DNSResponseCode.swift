//
//  DNSResponseCode.swift
//  NetworkDNS
//
//  Created by Alexander Ignition on 12.02.2024.
//

/// Response code - this 4 bit field is set as part of responses.
public struct DNSResponseCode: RawRepresentable, Hashable, Sendable {
    /// No error condition
    public static let success = DNSResponseCode(rawValue: 0)

    /// Format error - The name server was unable to interpret the query.
    public static let formatError = DNSResponseCode(rawValue: 1)

    /// Server failure - The name server was unable to process this query due to a problem with the name server.
    public static let serverFailure = DNSResponseCode(rawValue: 2)

    /// Name Error - Meaningful only for responses from an authoritative name server,
    /// this code signifies that the domain name referenced in the query does not exist.
    public static let nameError = DNSResponseCode(rawValue: 3)

    /// Not Implemented - The name server does not support the requested kind of query.
    public static let notImplemented = DNSResponseCode(rawValue: 4)

    /// Refused - The name server refuses to perform the specified operation for policy reasons.
    ///
    /// For example, a name server may not wish to provide the information to the particular requester,
    /// or a name server may not wish to perform a particular operation (e.g., zone transfer) for particular data.
    public static let refused = DNSResponseCode(rawValue: 5)

    // 6-15 Reserved for future use.

    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension DNSResponseCode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .success:
            return "No error"
        case .formatError:
            return "Format error"
        case .serverFailure:
            return "Server failure"
        case .nameError:
            return "Name Error"
        case .notImplemented:
            return "Not Implemented"
        case .refused:
            return "Refused"
        default:
            return "\(rawValue)"
        }
    }
}
