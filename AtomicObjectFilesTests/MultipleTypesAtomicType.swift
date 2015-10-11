//
//  MultipleTypesAtomicType.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/11/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation
import AtomicObjectFiles

struct MultipleTypesAtomicType: AtomicObjectType {
    var uniqueId: Int64?

    struct Text: CoderKeyType { typealias ValueType = String }
    var text: String

    struct Truth: CoderKeyType { typealias ValueType = Bool }
    var truth: Bool

    struct Integer: CoderKeyType { typealias ValueType = Int }
    var integer: Int

    struct DoubleNumber: CoderKeyType { typealias ValueType = Double }
    var doubleNumber: Double

    struct FloatNumber: CoderKeyType { typealias ValueType = Float }
    var floatNumber: Float

    struct Blob: CoderKeyType { typealias ValueType = NSData }
    var blob: NSData

    struct OptionalText: OptionalCoderKeyType { typealias ValueType = String }
    var optionalText: String?

    struct OptionalTruth: OptionalCoderKeyType { typealias ValueType = Bool }
    var optionalTruth: Bool?

    struct OptionalInteger: OptionalCoderKeyType { typealias ValueType = Int }
    var optionalInteger: Int?

    struct OptionalDoubleNumber: OptionalCoderKeyType { typealias ValueType = Double }
    var optionalDoubleNumber: Double?

    struct OptionalFloatNumber: OptionalCoderKeyType { typealias ValueType = Float }
    var optionalFloatNumber: Float?

    struct OptionalBlob: OptionalCoderKeyType { typealias ValueType = NSData }
    var optionalBlob: NSData?

    init(
        text: String,
        truth: Bool,
        integer: Int,
        doubleNumber: Double,
        floatNumber: Float,
        blob: NSData,
        optionalText: String?,
        optionalTruth: Bool?,
        optionalInteger: Int?,
        optionalDoubleNumber: Double?,
        optionalFloatNumber: Float?,
        optionalBlob: NSData?
        )
    {
        self.text = text
        self.truth = truth
        self.integer = integer
        self.doubleNumber = doubleNumber
        self.floatNumber = floatNumber
        self.blob = blob
        self.optionalText = optionalText
        self.optionalTruth = optionalTruth
        self.optionalInteger = optionalInteger
        self.optionalDoubleNumber = optionalDoubleNumber
        self.optionalFloatNumber = optionalFloatNumber
        self.optionalBlob = optionalBlob
    }

    init(decoder: DecoderType) {
        self.init(
            text: decoder.decode(Text.self),
            truth: decoder.decode(Truth.self),
            integer: decoder.decode(Integer.self),
            doubleNumber: decoder.decode(DoubleNumber.self),
            floatNumber: decoder.decode(FloatNumber.self),
            blob: decoder.decode(Blob.self),
            optionalText: decoder.decode(OptionalText.self),
            optionalTruth: decoder.decode(OptionalTruth.self),
            optionalInteger: decoder.decode(OptionalInteger.self),
            optionalDoubleNumber: decoder.decode(OptionalDoubleNumber.self),
            optionalFloatNumber: decoder.decode(OptionalFloatNumber.self),
            optionalBlob: decoder.decode(OptionalBlob.self)
        )
    }

    func encode(encoder: Encoder) {
        encoder.encode(self.text, forKey: Text.self)
        encoder.encode(self.truth, forKey: Truth.self)
        encoder.encode(self.integer, forKey: Integer.self)
        encoder.encode(self.doubleNumber, forKey: DoubleNumber.self)
        encoder.encode(self.floatNumber, forKey: FloatNumber.self)
        encoder.encode(self.blob, forKey: Blob.self)
        encoder.encode(self.optionalText, forKey: OptionalText.self)
        encoder.encode(self.optionalTruth, forKey: OptionalTruth.self)
        encoder.encode(self.optionalInteger, forKey: OptionalInteger.self)
        encoder.encode(self.optionalDoubleNumber, forKey: OptionalDoubleNumber.self)
        encoder.encode(self.optionalFloatNumber, forKey: OptionalFloatNumber.self)
        encoder.encode(self.optionalBlob, forKey: OptionalBlob.self)
    }
}