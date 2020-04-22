//
//  Wire.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public typealias WireName = String


public class Wire {
    var value: UInt64
    private(set) var name: WireName

    var from: UnitName? = nil {
        willSet {
            guard from == nil else { fatalError(SimulatorError.WireFromIsFinalError.rawValue) }
        }
    }
    var to: [UnitName]

    class func mask(_ range: ClosedRange<Int>) -> UInt64 {
        return (0...63).reduce(0, { acc, idx in
            if range.contains(idx) { return (1 << idx) + acc }
            else { return acc }
        })
    }

    class func mask(_ idx: Int) -> UInt64 {
        return mask(idx...idx)
    }


    public subscript(idx: Int) -> UInt64 {
        get {
            guard 0...63 ~= idx else {
                fatalError(SimulatorError.WireOutOfRangeError.rawValue)
            }
            return (value & Wire.mask(idx)) >> idx
        }
        set {
            guard 0...63 ~= idx else {
                fatalError(SimulatorError.WireOutOfRangeError.rawValue)
            }
            let mask = Wire.mask(idx)
            value = value & ~mask | (newValue << idx) & mask
        }
    }

    public subscript(range: ClosedRange<Int>) -> UInt64 {
        get {
            guard 0...63 ~= range.first! && 0...63 ~= range.last! else { fatalError(SimulatorError.WireOutOfRangeError.rawValue)
            }
            return (value & Wire.mask(range)) >> range.first!
        }
        set {
            guard 0...63 ~= range.first! && 0...63 ~= range.last! else {
                fatalError(SimulatorError.WireOutOfRangeError.rawValue)
            }
            let mask = Wire.mask(range)
            value = value & ~mask | (newValue << range.first!) & mask
        }
    }

    public init(wireName: WireName, value: UInt64 = 0, from: UnitName? = nil, to: [UnitName] = []) {
        self.name = wireName
        self.value = value
        self.from = from
        self.to = to
    }
}
