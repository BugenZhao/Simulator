//
//  UnitManagerTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/22.
//

import XCTest
@testable import SimulatorLib

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

        XCTAssertEqual(unitManager.wireManager.examine(), 0)
        XCTAssertEqual(unitManager.wireManager.echo_wire.v, 0)
        unitManager.clock()
        XCTAssertEqual(unitManager.wireManager.echo_wire.v, 88)
        unitManager.clock()
        XCTAssertEqual(unitManager.wireManager.echo_wire.v, 88)
    }

    func testProcedure() {
        let unitManager = UnitManager()

        unitManager.addOutputUnit(
            unitName: "output_8_unit",
            outputWires: ["wire_0"],
            outputValue: 8
        )
        unitManager.addGenericUnit(
            unitName: "add_5_unit",
            inputWires: ["wire_0"],
            outputWires: ["wire_1"],
            logic: { wm in
                wm.wire_1.v = wm.wire_0.v + 5
            }
        )
        unitManager.addGenericUnit(
            unitName: "times_2_unit",
            inputWires: ["wire_1"],
            outputWires: ["wire_2"],
            logic: { wm in
                wm.wire_2.v = wm.wire_1.v * 2
            }
        )
        unitManager.addPrinterUnit(
            unitName: "little_printer",
            inputWires: ["wire_0", "wire_1", "wire_2"]
        )

        XCTAssertEqual(unitManager.wireManager.examine(), 0)
        unitManager.clock()
        XCTAssertEqual(unitManager.wireManager.wire_2.v, (8 + 5) * 2)
    }

    func testLonelyWireExamine() {
        let unitManager = UnitManager()

        unitManager.addOutputUnit(
            unitName: "lonely_output",
            outputWires: ["lonely_wire_0"],
            outputValue: 555
        )
        unitManager.addPrinterUnit(
            unitName: "lonely_printer",
            inputWires: ["lonely_wire_1"]
        )

        XCTAssertEqual(unitManager.wireManager.examine(), 2)
    }

    func testDuplicateName() {
        let unitManager = UnitManager()

        let addOne = {
            unitManager.addOutputUnit(
                unitName: "bugen",
                outputWires: [],
                outputValue: 555
            ) }

        addOne()
        expectFatalError(expectedPrefix: SimulatorError.UnitManagerDuplicateNameError.rawValue) { addOne() }
    }

    func testConflictOutput() {
        let unitManager = UnitManager()

        let addOne = { (name: String) -> Void in
            unitManager.addOutputUnit(
                unitName: name,
                outputWires: ["crowded_wire"],
                outputValue: 555
            ) }

        addOne("bugen")
        expectFatalError(expectedPrefix: SimulatorError.WireFromIsFinalError.rawValue) { addOne("zhao") }
    }
    
    func testWriteInputWire() {
        let unitManager = UnitManager()

        expectFatalError(expectedPrefix: SimulatorError.UnitManagerWriteNotAllowedError.rawValue) {
            unitManager.addGenericUnit(
                unitName: "illegal_write",
                inputWires: ["wire_0"],
                outputWires: ["wire_1"],
                logic: { wm in
                    wm.wire_1.v = wm.wire_0.v + 5
                    wm.wire_0.v = 0
                }
            ) }
    }

    func testReadOutputWire() {
        let unitManager = UnitManager()

        expectFatalError(expectedPrefix: SimulatorError.UnitManagerReadNotAllowedError.rawValue) {
            unitManager.addGenericUnit(
                unitName: "illegal_read",
                inputWires: ["wire_0"],
                outputWires: ["wire_1"],
                logic: { wm in
                    wm.wire_1.v = wm.wire_1.v + 5
                }
            ) }
    }

    func testReadNotDeclaredWire() {
        let unitManager = UnitManager()

        unitManager.addGenericUnit(
            unitName: "add_5",
            inputWires: ["wire_0"],
            outputWires: ["wire_1"],
            logic: { wm in
                wm.wire_1.v = wm.wire_0.v + 5
            }
        )

        expectFatalError(expectedPrefix: SimulatorError.WireManagerWireNotExistsError.rawValue) {
            unitManager.addGenericUnit(
                unitName: "read_not_declared",
                inputWires: ["eriw_1"],
                outputWires: ["wire_2"],
                logic: { wm in
                    wm.wire_2.v = wm.wire_1.v + 5
                }
            ) }
    }
    
    func testWriteNotDeclaredWire() {
        let unitManager = UnitManager()

        unitManager.addGenericUnit(
            unitName: "add_5",
            inputWires: ["wire_0"],
            outputWires: ["wire_1"],
            logic: { wm in
                wm.wire_1.v = wm.wire_0.v + 5
            }
        )

        expectFatalError(expectedPrefix: SimulatorError.WireManagerWireNotExistsError.rawValue) {
            unitManager.addGenericUnit(
                unitName: "write_not_declared",
                inputWires: ["wire_1"],
                outputWires: ["eriw_2"],
                logic: { wm in
                    wm.wire_2.v = wm.wire_1.v + 5
                }
            ) }
    }
}
