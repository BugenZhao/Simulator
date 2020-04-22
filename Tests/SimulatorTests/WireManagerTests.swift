//
//  WireManagerTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/22.
//

import XCTest

class WireManagerTests: XCTestCase {
    func testSimple() {
        let wireManager = WireManager()
        XCTAssertEqual(wireManager.wires.count, 0)

        let wa = wireManager.wa
        XCTAssertEqual(wa.name, "wa")
        XCTAssertEqual(wa.value, 0)
        XCTAssertEqual(wa.from, nil)
        XCTAssertEqual(wa.to, nil)
        XCTAssertEqual(wireManager.wires.count, 1)

        let anotherWa = wireManager.wa
        XCTAssertEqual(wireManager.wires.count, 1)

        anotherWa.value = 0x12345678
        XCTAssertEqual(wa.value, 0x12345678)
        XCTAssertEqual(wireManager.wa[0...15], 0x5678)

        let wb = wireManager.wb
        XCTAssertEqual(wb.name, "wb")
        XCTAssertEqual(wireManager.wires.count, 2)
    }
}
