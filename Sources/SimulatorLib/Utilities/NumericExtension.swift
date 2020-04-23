//
//  NumericExtension.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public extension Bool {
    var u64: UInt64 { return self ? 1 : 0 }
    var u32: UInt32 { return self ? 1 : 0 }
    var u16: UInt16 { return self ? 1 : 0 }
    var u8: UInt8 { return self ? 1 : 0 }
}

public extension BinaryInteger {
    var u64: UInt64 { return UInt64(self) }
    var u32: UInt32 { return UInt32(self) }
    var u16: UInt16 { return UInt16(self) }
    var u8: UInt8 { return UInt8(self) }
}
