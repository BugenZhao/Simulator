//
//  WireTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/22.
//

import XCTest
import Nimble
@testable import SimulatorLib

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
        var wire = Wire("testWire", value: 0b1111_1111)
        wire.v = 0b1010_0101
        XCTAssert(wire.v == 0b1010_0101)
        XCTAssert(wire.v == 0b1010_0101)
        XCTAssert(wire[0] == true)
        XCTAssert(wire[1] == false)
        XCTAssert(wire[2] == true)
        XCTAssert(wire[7] == true)
        XCTAssert(wire[8] == false)
        XCTAssert(wire[31] == false)
        XCTAssert(wire[63] == false)
        wire[0] = false
        XCTAssert(wire.v == 0b1010_0100)
        XCTAssert(wire.v == 0b1010_0100)
        wire[1] = true
        XCTAssert(wire.v == 0b1010_0110)
        wire[31] = true
        XCTAssert(wire[31] == true)

        wire = Wire( "testWire", value: 0b1010_0101)

        XCTAssert(wire[0...3] == 0b0101)
        XCTAssert(wire[4...7] == 0b1010)
        XCTAssert(wire[0...7] == 0b1010_0101)
        wire[4...7] = 0b0101
        XCTAssert(wire[0...7] == 0b0101_0101)
        wire[0...0] = 0
        XCTAssert(wire.v == 0b0101_0100)
    }

    func testWireError() {
        let wire = Wire("testWire", value: 0b1010_0101, safe: true)

        expect { _ = wire[-1] }.to(throwAssertion())
        expect { _ = wire[64] }.to(throwAssertion())
        expect { _ = wire[-1...2] }.to(throwAssertion())
        expect { _ = wire[60...64] }.to(throwAssertion())
        expect { wire[-1] = true }.to(throwAssertion())
        expect { wire[64] = false }.to(throwAssertion())
        expect { wire[-1...2] = 0 }.to(throwAssertion())
        expect { wire[60...64] = 0 }.to(throwAssertion())

        wire.from = "FROM1"
        print(wire.from!)
        expect { wire.from = "FROM2" }.to(throwAssertion())
        wire.to.append(contentsOf: ["TO1", "TO2"])
        print(wire.to)
    }

    func testWireCounter() {
        let wire = Wire("wire", value: 0xffff)
        XCTAssertEqual(wire.counter.read, 0)
        XCTAssertEqual(wire.counter.write, 0)

        print(wire.v)
        XCTAssertEqual(wire.counter.read, 1)
        XCTAssertEqual(wire.counter.write, 0)

        print(wire.b)
        XCTAssertEqual(wire.counter.read, 2)
        XCTAssertEqual(wire.counter.write, 0)

        print(wire[7...15])
        XCTAssertEqual(wire.counter.read, 3)
        XCTAssertEqual(wire.counter.write, 0)

        wire[0] = false
        XCTAssertEqual(wire.counter.read, 3)
        XCTAssertEqual(wire.counter.write, 1)

        wire[1...2] = 0
        XCTAssertEqual(wire.counter.read, 3)
        XCTAssertEqual(wire.counter.write, 2)

        wire.v = 0xeeee
        XCTAssertEqual(wire.counter.read, 3)
        XCTAssertEqual(wire.counter.write, 3)

        print(wire[2...2])
        XCTAssertEqual(wire.counter.read, 4)
        XCTAssertEqual(wire.counter.write, 3)

        wire.clear()
        XCTAssertEqual(wire.counter.read, 0)
        XCTAssertEqual(wire.counter.write, 0)
    }
}
