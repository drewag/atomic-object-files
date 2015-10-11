//
//  AtomicObjectType.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation
import SQLite

public protocol AtomicObjectType: EncodableType {
    var uniqueId: Int64? { get set }
}

extension AtomicObjectType {
    static var time: Expression<String> { return Expression<String>("time") }
    static var objectId: Expression<Int64> { return Expression<Int64>("id") }

    public mutating func commitToPath(path: ReferenceType) throws {
        let connection = try Connection(path.fullPath())
        let updates = Table("updates")

        let objectId = Self.objectId
        let time = Self.time

        let encoder = SQLiteEncoder()
        let create = updates.create(ifNotExists: true) { t in
            encoder.tableBuilder = t

            t.column(Self.objectId)
            t.column(time)

            self.encode(encoder)
        }
        try connection.run(create)

        var setters = encoder.setters
        let actualId: Int64
        setters.append(time <- NSDate().asSQLiteDateTimeString)
        if let id = self.uniqueId {
            actualId = id
        }
        else {
            if connection.scalar(updates.count) == 0 {
                setters.append(objectId <- 1)
                actualId = 1
            }
            else {
                let id = connection.scalar(updates.order(objectId.desc).limit(1).select(objectId))
                actualId = id + 1
            }
        }
        setters.append(objectId <- actualId)

        let insert = updates.insert(setters)
        try connection.run(insert)
        self.uniqueId = actualId
    }

    public mutating func removeFromPath(path: ResourceReferenceType) throws {
        if let id = self.uniqueId {
            let connection = try Connection(path.fullPath())
            let updates = Table("updates")
            let objectId = Self.objectId
            try connection.run(updates.filter(objectId == id).delete())
        }
    }

    public static func loadFromPath(path: ReferenceType) throws -> [Self] {
        let connection = try Connection(path.fullPath())
        let updates = Table("updates")

        let objectId = Self.objectId

        var instances = [Int64:Self]()
        for row in connection.prepare(updates) {
            let decoder = SQLiteDecoder(row: row)
            var instance = Self(decoder: decoder)
            let uniqueId = row.get(objectId)
            instance.uniqueId = uniqueId
            instances[uniqueId] = instance
        }
        return Array(instances.values)
    }
}

//
//  CoderKeyType.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation

public protocol RawEncodableType {
    init()
}
extension String: RawEncodableType {}
extension Bool: RawEncodableType {}
extension Int: RawEncodableType {}
extension Double: RawEncodableType {}
extension Float: RawEncodableType {}
extension NSData: RawEncodableType {}

public protocol CoderKeyType {
    typealias ValueType: RawEncodableType
}

public protocol OptionalCoderKeyType {
    typealias ValueType: RawEncodableType
}

extension CoderKeyType {
    static func toString() -> String {
        return String(Mirror(reflecting: self).subjectType).componentsSeparatedByString(".").first!
    }
}

extension OptionalCoderKeyType {
    static func toString() -> String {
        return String(Mirror(reflecting: self).subjectType).componentsSeparatedByString(".").first!
    }
}

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
    func decode<K: OptionalCoderKeyType>(key: K.Type) -> K.ValueType?
}

//
//  Encodable.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation

public protocol EncodableType {
    init(decoder: DecoderType)

    func encode(encoder: Encoder)
}

//
//  Encoder.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation

public protocol Encoder {
    func encode<K: CoderKeyType>(data: K.ValueType, forKey key: K.Type)
    func encode<K: OptionalCoderKeyType>(data: K.ValueType?, forKey key: K.Type)
}


//
//  NSDate+Formatting.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation


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

