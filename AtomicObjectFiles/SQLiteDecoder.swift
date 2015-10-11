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
            case is Bool:
                return row.get(Expression<Bool>(key.toString())) as! K.ValueType
            case is Int:
                return row.get(Expression<Int>(key.toString())) as! K.ValueType
            case is Double:
                return row.get(Expression<Double>(key.toString())) as! K.ValueType
            case is Float:
                return Float(row.get(Expression<Double>(key.toString()))) as! K.ValueType
            case is NSData:
                return row.get(Expression<NSData>(key.toString())) as! K.ValueType

            default:
                fatalError("Type cannot be decoded from SQL")
        }
    }

    func decode<K: OptionalCoderKeyType>(key: K.Type) -> K.ValueType? {
        switch K.ValueType() {
            case is String:
                return row.get(Expression<String?>(key.toString())) as? K.ValueType
            case is Bool:
                return row.get(Expression<Bool?>(key.toString())) as? K.ValueType
            case is Int:
                return row.get(Expression<Int?>(key.toString())) as? K.ValueType
            case is Double:
                return row.get(Expression<Double?>(key.toString())) as? K.ValueType
            case is Float:
                if let double = row.get(Expression<Double?>(key.toString())) {
                    return Float(double) as? K.ValueType
                }
                return nil
            case is NSData:
                return row.get(Expression<NSData?>(key.toString())) as? K.ValueType

            default:
                fatalError("Type cannot be decoded from SQL")
        }
    }
}