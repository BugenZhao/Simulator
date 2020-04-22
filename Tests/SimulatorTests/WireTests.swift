//
//  WireTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/22.
//

import XCTest

class WireTests: XCTestCase {
    func testMask() {
        XCTAssert(Wire.mask(3) == 0b1000)
        XCTAssert(Wire.mask(0) == 0b1)
        XCTAssert(Wire.mask(1) == 0b10)
        XCTAssert(Wire.mask(0...7) == 0xff)
        XCTAssert(Wire.mask(8...15) == 0xff00)
        XCTAssert(Wire.mask(0...62) == ~0x8000_0000_0000_0000)
        XCTAssert(Wire.mask(-1...150) == ~0)
    }

    func testWire() {
        var wire = Wire(name: "testWire", value: 0b1010_0101)

        XCTAssert(wire.value == 0b1010_0101)
        XCTAssert(wire[0] == 1)
        XCTAssert(wire[1] == 0)
        XCTAssert(wire[2] == 1)
        XCTAssert(wire[7] == 1)
        XCTAssert(wire[8] == 0)
        XCTAssert(wire[31] == 0)
        XCTAssert(wire[63] == 0)
        wire[0] = 0
        XCTAssert(wire.value == 0b1010_0100)
        wire[1] = 1
        XCTAssert(wire.value == 0b1010_0110)
        wire[31] = 1
        XCTAssert(wire[31] == 1)

        wire = Wire(name: "testWire", value: 0b1010_0101)

        XCTAssert(wire[0...3] == 0b0101)
        XCTAssert(wire[4...7] == 0b1010)
        XCTAssert(wire[0...7] == 0b1010_0101)
        wire[4...7] = 0b0101
        XCTAssert(wire[0...7] == 0b0101_0101)
        wire[0...0] = 0
        XCTAssert(wire.value == 0b0101_0100)
    }

    func testWireError() {
        let wire = Wire(name: "testWire", value: 0b1010_0101)

        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { print(wire[-1]) }
        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { print(wire[64]) }
        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { print(wire[-1...2]) }
        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { print(wire[60...64]) }
        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { wire[-1] = 1 }
        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { wire[64] = 0 }
        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { wire[-1...2] = 0 }
        expectFatalError(expectedMessage: SimulatorError.WireOutOfRangeError.rawValue) { wire[60...64] = 0 }

        wire.from = "FROM1"
        print(wire.from!)
        expectFatalError(expectedMessage: SimulatorError.WireFromIsFinalError.rawValue) { wire.from = "FROM2" }
        wire.to = ["TO1", "TO2"]
        print(wire.to!)
        expectFatalError(expectedMessage: SimulatorError.WireToIsFinalError.rawValue) { wire.to = ["TO3"] }
    }
}
