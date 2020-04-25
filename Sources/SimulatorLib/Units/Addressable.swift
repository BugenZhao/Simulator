//
//  Addressable.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/23.
//

import Foundation


public protocol Addressable {
    var data: Data { get set }

    subscript (_ idx: UInt64) -> UInt64 { get set } // quad index

    subscript (b b: UInt64) -> UInt64 { get set }
    subscript (w w: UInt64) -> UInt64 { get set }
    subscript (l l: UInt64) -> UInt64 { get set }
    subscript (q q: UInt64) -> UInt64 { get set }

    func dump(at range: ClosedRange<UInt64>)

    mutating func clear()
}

extension Addressable {
    func validateAccess(at address: Int) {
        guard 0..<data.count ~= address else {
            fatalError(SimulatorError.AddressableInvalidAccessError.rawValue + "\(address)")
        }
    }
    
    public mutating func clear() {
        self.data.resetBytes(in: 0..<self.data.count)
    }

    public subscript (_ idx: UInt64) -> UInt64 {
        get { self[q: idx * 8] }
        set { self[q: idx * 8] = newValue }
    }

    public subscript (b b: UInt64) -> UInt64 {
        get {
            let b = Int(b)
            validateAccess(at: b)
            return UInt64(data[b])
        }
        set {
            let b = Int(b)
            validateAccess(at: b)
            data[b] = UInt8(newValue)
        }
    }
    public subscript (w w: UInt64) -> UInt64 {
        get {
            let w = Int(w)
            validateAccess(at: w + 1)
            return (UInt64(data[w + 0]) << 0x00) +
                (UInt64(data[w + 1]) << 0x08)
        }
        set {
            let w = Int(w)
            validateAccess(at: w + 1)
            data[w + 0] = UInt8((newValue & 0x00ff) >> 0x00)
            data[w + 1] = UInt8((newValue & 0xff00) >> 0x08)
        }
    }
    public subscript (l l: UInt64) -> UInt64 {
        get {
            let l = Int(l)
            validateAccess(at: l + 3)
            return (UInt64(data[l + 0]) << 0x00) +
                (UInt64(data[l + 1]) << 0x08) +
                (UInt64(data[l + 2]) << 0x10) +
                (UInt64(data[l + 3]) << 0x18)
        }
        set {
            let l = Int(l)
            validateAccess(at: l + 3)
            data[l + 0] = UInt8((newValue & 0x0000_00ff) >> 0x00)
            data[l + 1] = UInt8((newValue & 0x0000_ff00) >> 0x08)
            data[l + 2] = UInt8((newValue & 0x00ff_0000) >> 0x10)
            data[l + 3] = UInt8((newValue & 0xff00_0000) >> 0x18)
        }
    }
    public subscript (q q: UInt64) -> UInt64 {
        get {
            let q = Int(q)
            validateAccess(at: q + 7)
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
            let q = Int(q)
            validateAccess(at: q + 7)
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

    public func dump(at range: ClosedRange<UInt64>) {
        guard range.last! < data.count.u64 else {
            fatalError(SimulatorError.AddressableInvalidAccessError.rawValue)
        }
        var lo = range.first!.u32 & (~0xf)
        var hi = (range.last!.u32 + 0x10) & (~0xf)
        hi = hi < data.count ? hi : (data.count.u32 - 1)
        print("           0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F |")

        while lo < hi {
            print(String(format: "%08X  ", lo), terminator: "")
            (lo...(lo + 15)).forEach {
                if $0 < data.count { print(String(format: "%02X ", data[Int($0)]), terminator: "") }
                else { print("   ", terminator: "") }
            }
            print("| ", terminator: "")
            (lo...(lo + 15)).forEach {
                if $0 < data.count {
                    let c = Character(Unicode.Scalar(data[Int($0)]))
                    if c.isLetter || c.isNumber {
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
