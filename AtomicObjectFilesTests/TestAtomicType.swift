//
//  TestAtomicType.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/11/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation
import AtomicObjectFiles

struct TestAtomicType: AtomicObjectType {
    var uniqueId: Int64?

    struct Text: CoderKeyType { typealias ValueType = String }
    var text: String

    init(decoder: DecoderType) {
        self.init(text: decoder.decode(Text.self))
    }

    init(text: String) {
        self.text = text
    }

    func encode(encoder: Encoder) {
        encoder.encode(self.text, forKey: Text.self)
    }
}
