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

        var setters: [Setter] = []
        setters.append(time <- NSDate().asSQLiteDateTimeString)
        if let id = self.uniqueId {
            setters.append(objectId <- id)
        }
        else {
            if connection.scalar(updates.count) == 0 {
                setters.append(objectId <- 1)
            }
            else {
                let id = connection.scalar(updates.order(objectId.desc).limit(1).select(objectId))
                setters.append(objectId <- (id + 1))
            }
            setters += encoder.setters
        }
        let insert = updates.insert(setters)
        self.uniqueId = try connection.run(insert)
    }

    public static func loadFromPath(path: ReferenceType) throws -> [Self] {
        let connection = try Connection(path.fullPath())
        let updates = Table("updates")

        let objectId = Self.objectId

        var instances = [Self]()
        for row in connection.prepare(updates) {
            let decoder = SQLiteDecoder(row: row)
            var instance = Self(decoder: decoder)
            instance.uniqueId = row.get(objectId)
            instances.append(instance)
        }
        return instances
    }
}