//
//  Dump.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/5/4.
//

import Foundation

public extension Data {
    func dump() {
        dump(at: 0...(self.count - 1).u64)
    }


    func dump(at range: ClosedRange<UInt64>) {
        guard range.last! < self.count.u64 else {
            fatalError(SimulatorError.AddressableInvalidAccessError.rawValue)
        }
        var lo = range.first!.u32 & (~0xf)
        var hi = (range.last!.u32 + 0x10) & (~0xf)
        hi = hi < self.count ? hi : (self.count.u32 - 1)
        print("           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F |")

        while lo < hi {
            print(String(format: "%08X  ", lo), terminator: "")
            (lo...(lo + 15)).forEach {
                if $0 < self.count { print(String(format: "%02X ", self[Int($0)]), terminator: "") }
                else { print("   ", terminator: "") }
            }
            print("| ", terminator: "")
            (lo...(lo + 15)).forEach {
                if $0 < self.count {
                    let c = Character(Unicode.Scalar(self[Int($0)]))
                    if c.isASCII && (c.isLetter || c.isNumber) {
                        print("\(c)", terminator: "")
                    }
                    else {
                        print(".", terminator: "")
                    }
                }
            }
            print()
            lo += 16
        }
    }
}
