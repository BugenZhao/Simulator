import Foundation

class Wire {
    var value: UInt64

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
            guard 0...63 ~= idx else { fatalError(); }
            return (value & Wire.mask(idx)) >> idx
        }
        set {
            guard 0...63 ~= idx else { fatalError(); }
            let mask = Wire.mask(idx)
            value = value & ~mask | (newValue << idx) & mask
        }
    }

    public subscript(range: ClosedRange<Int>) -> UInt64 {
        get {
            guard 0...63 ~= range.first! && 0...63 ~= range.last! else { fatalError() }
            return (value & Wire.mask(range)) >> range.first!
        }
        set {
            guard 0...63 ~= range.first! && 0...63 ~= range.last! else { fatalError() }
            let mask = Wire.mask(range)
            value = value & ~mask | (newValue << range.first!) & mask
        }
    }

    init() { value = 0 }
    init(_ value: UInt64) { self.value = value }
}

var wire = Wire(0b0101_0101)

assert(Wire.mask(3) == 0b1000)
assert(Wire.mask(0) == 0b1)
assert(Wire.mask(0...7) == 0xff)
assert(Wire.mask(8...15) == 0xff00)
assert(Wire.mask(-1...150) == ~0)




wire[0]
wire[1]
wire[2]
wire[3]
wire[4]
wire[5]
wire[6]
wire[7]
wire[8]
wire[31]
wire.value
wire[0] = 0
wire.value
wire[1] = 1
wire.value
wire[31] = 1
wire.value

wire = Wire(0b0101_0101)

wire[0...3]
wire[4...7]
wire[0...7] == 0b0101_0101
wire[4...7] = 0b1010
wire[0...7] == 0b1010_0101
wire[0...0] = 0
wire.value == 0b1010_0100

typealias WireName = String
typealias UnitName = String


