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