//
//  Decoder.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation

public protocol DecoderType {
    func decode<K: CoderKeyType>(key: K.Type) -> K.ValueType
}