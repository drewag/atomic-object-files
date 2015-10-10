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
            default:
                fatalError("Type cannot be encoded to SQLite")
        }
    }
}