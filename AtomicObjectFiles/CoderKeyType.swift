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

public protocol CoderKeyType {
    typealias ValueType: RawEncodableType
}

extension CoderKeyType {
    static func toString() -> String {
        return Mirror(reflecting: self).description
    }
}