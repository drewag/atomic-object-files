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