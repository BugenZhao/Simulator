//
//  NumericExtension.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public extension Bool {
    @inlinable var u64: UInt64 { return self ? 1 : 0 }
    @inlinable var u32: UInt32 { return self ? 1 : 0 }
    @inlinable var u16: UInt16 { return self ? 1 : 0 }
    @inlinable var u8: UInt8 { return self ? 1 : 0 }
}

public extension BinaryInteger {
    @inlinable var u64: UInt64 { return UInt64(self) }
    @inlinable var u32: UInt32 { return UInt32(self) }
    @inlinable var u16: UInt16 { return UInt16(self) }
    @inlinable var u8: UInt8 { return UInt8(self) }
}
