//
//  SQLiteEncoder.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation
import SQLite

final class SQLiteEncoder: Encoder {
    var setters: [Setter] = []

    var tableBuilder: TableBuilder!

    func encodeSQLEncodable<K: CoderKeyType where K.ValueType: Value>(data: K.ValueType, forKey key: K.Type) {
        let expression = Expression<K.ValueType>(key.toString())
        self.tableBuilder.column(expression)
        self.setters.append(expression <- data)
    }

    func encode<K: CoderKeyType>(data: K.ValueType, forKey key: K.Type) {
        switch data {
            case let v as String:
                let expression = Expression<String>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Bool:
                let expression = Expression<Bool>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Int:
                let expression = Expression<Int>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Double:
                let expression = Expression<Double>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Float:
                let expression = Expression<Double>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- Double(v))
            case let v as NSData:
                let expression = Expression<NSData>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            default:
                fatalError("Type cannot be encoded to SQLite")
        }
    }

    func encode<K: OptionalCoderKeyType>(data: K.ValueType?, forKey key: K.Type) {
        switch data {
            case let v as String?:
                let expression = Expression<String?>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Bool?:
                let expression = Expression<Bool?>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Int?:
                let expression = Expression<Int?>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Double?:
                let expression = Expression<Double?>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            case let v as Float?:
                let expression = Expression<Double?>(key.toString())
                self.tableBuilder.column(expression)
                if let v = v {
                    self.setters.append(expression <- Double(v))
                }
                else {
                    self.setters.append(expression <- nil)
                }
            case let v as NSData?:
                let expression = Expression<NSData?>(key.toString())
                self.tableBuilder.column(expression)
                self.setters.append(expression <- v)
            default:
                fatalError("Type cannot be encoded to SQLite")
        }
    }
}