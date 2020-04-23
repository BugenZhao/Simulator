//
//  Addressable.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/23.
//

import Foundation


protocol Addressable {
    var data: Data { get set }
    subscript (b b: Int) -> UInt8 { get set }
    subscript (w w: Int) -> UInt16 { get set }
    subscript (l l: Int) -> UInt32 { get set }
    subscript (q q: Int) -> UInt64 { get set }
}

extension Addressable {
    subscript (b b: Int) -> UInt8 {
        get { data[b] }
        set { data[b] = newValue }
    }
    subscript (w w: Int) -> UInt16 {
        get {
            return (UInt16(data[w + 0]) << 0x00) +
                (UInt16(data[w + 1]) << 0x08)
        }
        set {
            data[w + 0] = UInt8((newValue & 0x00ff) >> 0x00)
            data[w + 1] = UInt8((newValue & 0xff00) >> 0x08)
        }
    }
    subscript (l l: Int) -> UInt32 {
        get {
            return (UInt32(data[l + 0]) << 0x00) +
                (UInt32(data[l + 1]) << 0x08) +
                (UInt32(data[l + 2]) << 0x10) +
                (UInt32(data[l + 3]) << 0x18)
        }
        set {
            data[l + 0] = UInt8((newValue & 0x0000_00ff) >> 0x00)
            data[l + 1] = UInt8((newValue & 0x0000_ff00) >> 0x08)
            data[l + 2] = UInt8((newValue & 0x00ff_0000) >> 0x10)
            data[l + 3] = UInt8((newValue & 0xff00_0000) >> 0x18)
        }
    }
    subscript (q q: Int) -> UInt64 {
        get {
            let lo = (UInt64(data[q + 0]) << 0x00) +
                (UInt64(data[q + 1]) << 0x08) +
                (UInt64(data[q + 2]) << 0x10) +
                (UInt64(data[q + 3]) << 0x18)

            let hi = (UInt64(data[q + 4]) << 0x20) +
                (UInt64(data[q + 5]) << 0x28) +
                (UInt64(data[q + 6]) << 0x30) +
                (UInt64(data[q + 7]) << 0x38)

            return lo + hi
        }
        set {
            data[q + 0] = UInt8((newValue & 0x0000_0000_0000_00ff) >> 0x00)
            data[q + 1] = UInt8((newValue & 0x0000_0000_0000_ff00) >> 0x08)
            data[q + 2] = UInt8((newValue & 0x0000_0000_00ff_0000) >> 0x10)
            data[q + 3] = UInt8((newValue & 0x0000_0000_ff00_0000) >> 0x18)
            data[q + 4] = UInt8((newValue & 0x0000_00ff_0000_0000) >> 0x20)
            data[q + 5] = UInt8((newValue & 0x0000_ff00_0000_0000) >> 0x28)
            data[q + 6] = UInt8((newValue & 0x00ff_0000_0000_0000) >> 0x30)
            data[q + 7] = UInt8((newValue & 0xff00_0000_0000_0000) >> 0x38)
        }
    }
}
