//
//  SQLiteEncoderTests.swift
//  AtomicObjectFiles
//
//  Created by Andrew J Wagner on 10/9/15.
//  Copyright © 2015 Drewag, LLC. All rights reserved.
//

import XCTest
import AtomicObjectFiles

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

        XCTAssertTrue(retrievedInstances.contains {$0.uniqueId == instance1.uniqueId && $0.text == instance1.text})
        XCTAssertTrue(retrievedInstances.contains {$0.uniqueId == instance2.uniqueId && $0.text == instance2.text})
        XCTAssertTrue(retrievedInstances.contains {$0.uniqueId == instance3.uniqueId && $0.text == instance3.text})
    }

    func testRetrievalAfterUpdate() {
        var instance = TestAtomicType(text: "Hello World")
        try! instance.commitToPath(self.testFilePath)
        instance.text = "Hello Changed"
        try! instance.commitToPath(self.testFilePath)

        var retrievedInstances = try! TestAtomicType.loadFromPath(self.testFilePath)
        XCTAssertEqual(retrievedInstances.count, 1)
        XCTAssertEqual(retrievedInstances[0].text, "Hello Changed")

        instance.text = "This is new text"
        try! instance.commitToPath(self.testFilePath)

        retrievedInstances = try! TestAtomicType.loadFromPath(self.testFilePath)
        XCTAssertEqual(retrievedInstances.count, 1)
        XCTAssertEqual(retrievedInstances[0].text, "This is new text")
    }

    func testRetrievalAfterMultipleCreateAndUpdate() {
        var instance1 = TestAtomicType(text: "Hello World")
        try! instance1.commitToPath(self.testFilePath)

        var instance2 = TestAtomicType(text: "Hello World 2")
        try! instance2.commitToPath(self.testFilePath)

        var instance3 = TestAtomicType(text: "Hello World 3")
        try! instance3.commitToPath(self.testFilePath)

        instance1.text = "Hello Changed"
        try! instance1.commitToPath(self.testFilePath)

        instance2.text = "Hello Changed 2"
        try! instance2.commitToPath(self.testFilePath)

        instance3.text = "Hello Changed 3"
        try! instance3.commitToPath(self.testFilePath)

        let retrievedInstances = try! TestAtomicType.loadFromPath(self.testFilePath)
        XCTAssertEqual(retrievedInstances.count, 3)

        XCTAssertTrue(retrievedInstances.contains {$0.uniqueId == instance1.uniqueId && $0.text == "Hello Changed"})
        XCTAssertTrue(retrievedInstances.contains {$0.uniqueId == instance2.uniqueId && $0.text == "Hello Changed 2"})
        XCTAssertTrue(retrievedInstances.contains {$0.uniqueId == instance3.uniqueId && $0.text == "Hello Changed 3"})
    }

    func testVariousDataTypes() {
        var instance = MultipleTypesAtomicType(
            text: "Hello World",
            truth: true,
            integer: 1,
            doubleNumber: 2.0,
            floatNumber: 3.0,
            blob: "Hello World".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!,
            optionalText: nil,
            optionalTruth: false,
            optionalInteger: 4,
            optionalDoubleNumber: nil,
            optionalFloatNumber: 5.0,
            optionalBlob: nil
        )
        try! instance.commitToPath(self.testFilePath)

        let retrievedInstances = try! MultipleTypesAtomicType.loadFromPath(self.testFilePath)
        XCTAssertEqual(retrievedInstances.count, 1)
        XCTAssertEqual(retrievedInstances[0].text, "Hello World")
        XCTAssertTrue(retrievedInstances[0].truth)
        XCTAssertEqual(retrievedInstances[0].integer, 1)
        XCTAssertEqual(retrievedInstances[0].doubleNumber, 2.0)
        XCTAssertEqual(retrievedInstances[0].floatNumber, 3.0)
        XCTAssertEqual(NSString(data: retrievedInstances[0].blob, encoding: NSUTF8StringEncoding), "Hello World")
        XCTAssertNil(retrievedInstances[0].optionalText)
        XCTAssertFalse(retrievedInstances[0].optionalTruth ?? true)
        XCTAssertEqual(retrievedInstances[0].optionalInteger, 4)
        XCTAssertNil(retrievedInstances[0].optionalDoubleNumber)
        XCTAssertEqual(retrievedInstances[0].optionalFloatNumber, 5.0)
        XCTAssertNil(retrievedInstances[0].optionalBlob)
    }
}
