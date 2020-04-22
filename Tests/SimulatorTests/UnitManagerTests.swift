//
//  UnitManagerTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/22.
//

import XCTest

class UnitManagerTests: XCTestCase {
    func testEcho() {
        let unitManager = UnitManager()

        unitManager.addOutputUnit(
            unitName: "echo_88_unit",
            outputWires: ["echo_wire"],
            outputValue: 88
        )
        unitManager.addPrinterUnit(
            unitName: "printer_unit",
            inputWires: ["echo_wire"]
        )

        XCTAssertEqual(unitManager.wireManager.echo_wire.value, 0)
        unitManager.clock()
        XCTAssertEqual(unitManager.wireManager.echo_wire.value, 88)
        unitManager.clock()
        XCTAssertEqual(unitManager.wireManager.echo_wire.value, 88)
    }

    func testProcedure() {
        let unitManager = UnitManager()

        unitManager.addOutputUnit(
            unitName: "echo_8_unit",
            outputWires: ["wire_0"],
            outputValue: 8
        )
        unitManager.addBasicUnit(
            unitName: "add_5_unit",
            inputWires: ["wire_0"],
            outputWires: ["wire_1"],
            logic: { wm in
                wm.wire_1.value = wm.wire_0.value + 5
            }
        )
        unitManager.addBasicUnit(
            unitName: "times_2_unit",
            inputWires: ["wire_1"],
            outputWires: ["wire_2"],
            logic: { wm in
                wm.wire_2.value = wm.wire_1.value * 2
            }
        )
        unitManager.addPrinterUnit(
            unitName: "little_printer",
            inputWires: ["wire_0", "wire_1", "wire_2"]
        )

        unitManager.clock()
        XCTAssertEqual(unitManager.wireManager.wire_2.value, (8 + 5) * 2)
    }
}
