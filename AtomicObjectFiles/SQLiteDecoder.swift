//
//  SQLiteDecoder.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation
import SQLite

struct SQLiteDecoder: DecoderType {
    let row: Row

    func decode<K: CoderKeyType>(key: K.Type) -> K.ValueType {
        switch K.ValueType() {
            case is String:
                return row.get(Expression<String>(key.toString())) as! K.ValueType
            default:
                fatalError("Type cannot be decoded from SQL")
        }
    }
}