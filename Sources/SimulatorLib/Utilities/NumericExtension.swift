//
//  NumericExtension.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public extension Bool {
    var u64: UInt64 { return self ? 1 : 0 }
}

public extension BinaryInteger {
    var u64: UInt64 { return UInt64(self) }
}
