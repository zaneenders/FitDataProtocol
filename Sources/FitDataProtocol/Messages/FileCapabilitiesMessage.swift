//
//  FileCapabilitiesMessage.swift
//  FitDataProtocol
//
//  Created by Kevin Hoogheem on 8/25/18.
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
import DataDecoder
import FitnessUnits

/// FIT File Capabilities Message
@available(swift 4.0)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
open class FileCapabilitiesMessage: FitMessage {

    /// FIT Message Global Number
    public override class func globalMessageNumber() -> UInt16 {
        return 37
    }

    /// Message Index
    private(set) public var messageIndex: MessageIndex?

    /// File Type
    private(set) public var fileType: FileType?

    /// Hardware Version
    private(set) public var fileFlags: FitFileFlag?

    /// Directory
    private(set) public var directory: String?

    /// Max Count
    private(set) public var maxCount: ValidatedBinaryInteger<UInt16>?

    /// Max Size
    private(set) public var maxSize: ValidatedBinaryInteger<UInt32>?

    public required init() {}

    public init(messageIndex: MessageIndex?,
                fileType: FileType?,
                fileFlags: FitFileFlag?,
                directory: String?,
                maxCount: ValidatedBinaryInteger<UInt16>?,
                maxSize: ValidatedBinaryInteger<UInt32>?) {

        self.messageIndex = messageIndex
        self.fileType = fileType
        self.fileFlags = fileFlags
        self.directory = directory
        self.maxCount = maxCount
        self.maxSize = maxSize
    }

    internal override func decode(fieldData: FieldData, definition: DefinitionMessage, dataStrategy: FitFileDecoder.DataDecodingStrategy) throws -> FileCapabilitiesMessage  {

        var messageIndex: MessageIndex?
        var fileType: FileType?
        var fileFlags: FitFileFlag?
        var directory: String?
        var maxCount: ValidatedBinaryInteger<UInt16>?
        var maxSize: ValidatedBinaryInteger<UInt32>?

        let arch = definition.architecture

        var localDecoder = DecodeData()

        for definition in definition.fieldDefinitions {

            let key = FitCodingKeys(intValue: Int(definition.fieldDefinitionNumber))

            switch key {
            case .none:
                // We still need to pull this data off the stack
                let _ = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))
                //print("FileCreatorMessage Unknown Field Number: \(definition.fieldDefinitionNumber)")

            case .some(let converter):
                switch converter {

                case .fileType:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if UInt64(value) == definition.baseType.invalid {

                        switch dataStrategy {
                        case .nil:
                            break
                        case .useInvalid:
                            fileType = FileType.invalid
                        }

                    } else {
                        fileType = FileType(rawType: value)
                    }

                case .fileFlags:
                    let value = localDecoder.decodeUInt8(fieldData.fieldData)
                    if UInt64(value) != definition.baseType.invalid {
                        fileFlags = FitFileFlag(rawValue: value)
                    }


                case .directory:
                    let stringData = localDecoder.decodeData(fieldData.fieldData, length: Int(definition.size))
                    if UInt64(stringData.count) != definition.baseType.invalid {
                        directory = stringData.smartString
                    }

                case .maxCount:
                    let value = arch == .little ? localDecoder.decodeUInt16(fieldData.fieldData).littleEndian : localDecoder.decodeUInt16(fieldData.fieldData).bigEndian
                    if Int64(value) != definition.baseType.invalid {
                        maxCount = ValidatedBinaryInteger(value: value, valid: true)
                    } else {

                        switch dataStrategy {
                        case .nil:
                            break
                        case .useInvalid:
                            maxCount = ValidatedBinaryInteger(value: UInt16(definition.baseType.invalid), valid: false)
                        }
                    }

                case .maxSize:
                    let value = arch == .little ? localDecoder.decodeUInt32(fieldData.fieldData).littleEndian : localDecoder.decodeUInt32(fieldData.fieldData).bigEndian
                    if Int64(value) != definition.baseType.invalid {
                        maxSize = ValidatedBinaryInteger(value: value, valid: true)
                    } else {

                        switch dataStrategy {
                        case .nil:
                            break
                        case .useInvalid:
                            maxSize = ValidatedBinaryInteger(value: UInt32(definition.baseType.invalid), valid: false)
                        }
                    }

                case .messageIndex:
                    let value = arch == .little ? localDecoder.decodeUInt16(fieldData.fieldData).littleEndian : localDecoder.decodeUInt16(fieldData.fieldData).bigEndian
                    if UInt64(value) != definition.baseType.invalid {
                        messageIndex = MessageIndex(value: value)
                    }

                }
            }
        }

        return FileCapabilitiesMessage(messageIndex: messageIndex,
                                       fileType: fileType,
                                       fileFlags: fileFlags,
                                       directory: directory,
                                       maxCount: maxCount,
                                       maxSize: maxSize)
    }
}
