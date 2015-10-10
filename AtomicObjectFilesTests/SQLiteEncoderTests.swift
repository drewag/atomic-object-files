//
//  SQLiteEncoderTests.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import XCTest
import AtomicObjectFiles

struct TestAtomicType: AtomicObjectType {
    var uniqueId: Int64?

    struct Text: CoderKeyType { typealias ValueType = String }
    let text: String

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

class SQLiteEncoderTests: XCTestCase {
    let testFilePath = FileManager.defaultManager.documentsDirectory.append("testFile.sqlite")

    override func setUp() {
        let _ = try? self.testFilePath.delete()
    }

    func testCreate() {
        var instance = TestAtomicType(text: "Hello World")

        try! instance.commitToPath(self.testFilePath)

        XCTAssertNotNil(instance.uniqueId)
    }

    func testMultipleCreate() {
        var instance1 = TestAtomicType(text: "Hello World")
        var instance2 = TestAtomicType(text: "Hello World 2")
        var instance3 = TestAtomicType(text: "Hello World 3")

        try! instance1.commitToPath(self.testFilePath)
        try! instance2.commitToPath(self.testFilePath)
        XCTAssertNotNil(instance2.uniqueId)
        try! instance3.commitToPath(self.testFilePath)
        XCTAssertNotNil(instance3.uniqueId)

        XCTAssertNotEqual(instance1.uniqueId, instance2.uniqueId)
        XCTAssertNotEqual(instance1.uniqueId, instance3.uniqueId)
        XCTAssertNotEqual(instance2.uniqueId, instance3.uniqueId)
    }

    func testRetrievalAfterCreate() {
        var instance = TestAtomicType(text: "Hello World")

        try! instance.commitToPath(self.testFilePath)

        let retrievedInstances = try! TestAtomicType.loadFromPath(self.testFilePath)
        XCTAssertEqual(retrievedInstances.count, 1)
        XCTAssertEqual(retrievedInstances[0].uniqueId, instance.uniqueId)
        XCTAssertEqual(retrievedInstances[0].text, instance.text)
    }

    func testRetrievalAfterMultipleCreate() {
        var instance1 = TestAtomicType(text: "Hello World")
        var instance2 = TestAtomicType(text: "Hello World 2")
        var instance3 = TestAtomicType(text: "Hello World 3")

        try! instance1.commitToPath(self.testFilePath)
        try! instance2.commitToPath(self.testFilePath)
        try! instance3.commitToPath(self.testFilePath)

        let retrievedInstances = try! TestAtomicType.loadFromPath(self.testFilePath)
        XCTAssertEqual(retrievedInstances.count, 3)

        XCTAssertEqual(retrievedInstances[0].uniqueId, instance1.uniqueId)
        XCTAssertEqual(retrievedInstances[0].text, instance1.text)

        XCTAssertEqual(retrievedInstances[1].uniqueId, instance2.uniqueId)
        XCTAssertEqual(retrievedInstances[1].text, instance2.text)

        XCTAssertEqual(retrievedInstances[2].uniqueId, instance3.uniqueId)
        XCTAssertEqual(retrievedInstances[2].text, instance3.text)
    }
}
