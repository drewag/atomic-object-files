//
//  AtomicObjectType+Core.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 11/19/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import Foundation
import SQLite

extension AtomicObjectType {
    public typealias Marker = Int64?

    static var time: Expression<String> { return Expression<String>("time") }
    static var updateId: Expression<Int64> { return Expression<Int64>("updateId") }
    static var objectId: Expression<Int64> { return Expression<Int64>("id") }
    static var updatesTable: Table { return Table("updates") }

    public static func prepareAtPath(path: ReferenceType) throws {
        var encoder = SQLiteEncoder()
        try Self().prepareAtPath(path, encoder: &encoder)
    }

    public static func generateMarkerFromPath(path: ReferenceType) throws -> Marker {
        try self.prepareAtPath(path)

        let connection = try Connection(path.fullPath())
        return connection.scalar(self.updatesTable.select(self.updateId.max))
    }

    public mutating func commitToPath(path: ReferenceType) throws {
        let connection = try Connection(path.fullPath())
        var encoder = SQLiteEncoder()

        try self.prepareAtPath(path, encoder: &encoder)

        var setters = encoder.setters
        let actualId: Int64
        setters.append(Self.time <- NSDate().asSQLiteDateTimeString)
        if let id = self.uniqueId {
            actualId = id
        }
        else {
            if connection.scalar(Self.updatesTable.count) == 0 {
                setters.append(Self.objectId <- 1)
                actualId = 1
            }
            else {
                let id = connection.scalar(Self.updatesTable.order(Self.objectId.desc).limit(1).select(Self.objectId))
                actualId = id + 1
            }
        }
        setters.append(Self.objectId <- actualId)

        let insert = Self.updatesTable.insert(setters)
        try connection.run(insert)
        self.uniqueId = actualId
    }

    public mutating func removeFromPath(path: ResourceReferenceType) throws {
        if let id = self.uniqueId {
            let connection = try Connection(path.fullPath())
            try connection.run(Self.updatesTable.filter(Self.objectId == id).delete())
        }
    }

    public static func loadFromPath(path: ReferenceType, afterMarker: Marker = nil) throws -> [Self] {
        let connection = try Connection(path.fullPath())

        var updatesTable = self.updatesTable
        if let marker = afterMarker {
            updatesTable = updatesTable.filter(self.updateId > marker)
        }

        var instances = [Int64:Self]()
        for row in connection.prepare(updatesTable) {
            let decoder = SQLiteDecoder(row: row)
            var instance = Self(decoder: decoder)
            let uniqueId = row.get(self.objectId)
            instance.uniqueId = uniqueId
            instances[uniqueId] = instance
        }
        return Array(instances.values)
    }
}

private extension AtomicObjectType {
    func prepareAtPath(path: ReferenceType, inout encoder: SQLiteEncoder) throws {
        let connection = try Connection(path.fullPath())

        let create = Self.updatesTable.create(ifNotExists: true) { t in
            encoder.tableBuilder = t

            t.column(Self.updateId, primaryKey: true)
            t.column(Self.objectId)
            t.column(Self.time)

            self.encode(encoder)
        }
        try connection.run(create)
    }
}