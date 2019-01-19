//
//  FileIdMessageKeys.swift
//  FitDataProtocol
//
//  Created by Kevin Hoogheem on 8/18/18.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import AntMessageProtocol

@available(swift 4.2)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
extension FileIdMessage: FitMessageKeys {
    /// CodingKeys for FIT Message Type
    public typealias FitCodingKeys = MessageKeys

    /// FIT Message Keys
    public enum MessageKeys: Int, CodingKey, CaseIterable {
        /// File Type
        case fileType           = 0
        /// Manufacturer
        case manufacturer       = 1
        /// Product
        case product            = 2
        /// Serial Number
        case serialNumber       = 3
        /// File Creation Date
        case fileCreationDate   = 4
        /// File Number
        case fileNumber         = 5
        /// Product Name
        case productName        = 8
    }
}

public extension FileIdMessage.FitCodingKeys {

    /// Key Base Type
    public var baseType: BaseType {
        switch self {
        case .fileType:
            return .enumtype
        case .manufacturer:
            return .uint16
        case .product:
            return .uint16
        case .serialNumber:
            return .uint32z
        case .fileCreationDate:
            return .uint32
        case .fileNumber:
            return .uint16
        case .productName:
            return .string //20
        }
    }
}

internal extension FileIdMessage.FitCodingKeys {

    /// Key Base Type Resolution
    var resolution: Resolution {
        switch self {
        case .fileType:
            return Resolution(scale: 1.0, offset: 0.0)
        case .manufacturer:
            return Resolution(scale: 1.0, offset: 0.0)
        case .product:
            return Resolution(scale: 1.0, offset: 0.0)
        case .serialNumber:
            return Resolution(scale: 1.0, offset: 0.0)
        case .fileCreationDate:
            return Resolution(scale: 1.0, offset: 0.0)
        case .fileNumber:
            return Resolution(scale: 1.0, offset: 0.0)
        case .productName:
            return Resolution(scale: 1.0, offset: 0.0)
        }
    }
}

// Encoding
extension FileIdMessage.FitCodingKeys: EncodeKeyed {

    internal func encodeKeyed(value: Bool) throws -> Data {
        return try self.baseType.encodedResolution(value: value, resolution: self.resolution)
    }

    internal func encodeKeyed(value: UInt8) throws -> Data {
        return try self.baseType.encodedResolution(value: value, resolution: self.resolution)
    }

    internal func encodeKeyed(value: UInt16) throws -> Data {
        return try self.baseType.encodedResolution(value: value, resolution: self.resolution)
    }

    internal func encodeKeyed(value: UInt32) throws -> Data {
        return try self.baseType.encodedResolution(value: value, resolution: self.resolution)
    }

    internal func encodeKeyed(value: Double) throws -> Data {
        return try self.baseType.encodedResolution(value: value, resolution: self.resolution)
    }
}

internal extension FileIdMessage.FitCodingKeys {

    /// Create a Field Definition Message From the Key
    ///
    /// - Parameter size: Data Size, if nil will use the keys predefined size
    /// - Returns: FieldDefinition
    internal func fieldDefinition(size: UInt8) -> FieldDefinition {

        let fieldDefinition = FieldDefinition(fieldDefinitionNumber: UInt8(self.rawValue),
                                              size: size,
                                              endianAbility: self.baseType.hasEndian,
                                              baseType: self.baseType)

        return fieldDefinition
    }

    /// Create a Field Definition Message From the Key
    ///
    /// - Returns: FieldDefinition
    internal func fieldDefinition() -> FieldDefinition {

        let fieldDefinition = FieldDefinition(fieldDefinitionNumber: UInt8(self.rawValue),
                                              size: self.baseType.dataSize,
                                              endianAbility: self.baseType.hasEndian,
                                              baseType: self.baseType)

        return fieldDefinition
    }
}
