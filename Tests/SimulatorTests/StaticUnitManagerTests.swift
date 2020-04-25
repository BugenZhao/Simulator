//
//  StaticUnitManagerTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/25.
//

import XCTest
import Nimble
@testable import SimulatorLib

class StaticUnitManagerTests: XCTestCase {
    func testEcho() {
        let unitManager = StaticUnitManager()

        let echoWire = Wire("echoWire")

        _ = unitManager.addOutputUnit(
            unitName: "echo88Unit",
            outputWires: [echoWire],
            outputValue: 88
        )
        _ = unitManager.addPrinterUnit(
            unitName: "printerUnit",
            inputWires: [echoWire]
        )

        XCTAssertEqual(unitManager.wireManager.examine(), 0)
        XCTAssertEqual(echoWire.v, 0)
        unitManager.clock()
        XCTAssertEqual(echoWire.v, 88)
        unitManager.clock()
        XCTAssertEqual(echoWire.v, 88)
    }

    func testProcedure() {
        let unitManager = StaticUnitManager()

        let wire0 = Wire("wire0")
        let wire1 = Wire("wire1")
        let wire2 = Wire("wire2")

        _ = unitManager.addOutputUnit(
            unitName: "output8Unit",
            outputWires: [wire0],
            outputValue: 8
        )
        _ = unitManager.addGenericUnit(
            unitName: "add5Unit",
            inputWires: [wire0],
            outputWires: [wire1],
            logic: { wire1.v = wire0.v + 5 }
        )
        _ = unitManager.addGenericUnit(
            unitName: "times2Unit",
            inputWires: [wire1],
            outputWires: [wire2],
            logic: {
                wire2.v = wire1.v * 2
            }
        )
        _ = unitManager.addPrinterUnit(
            unitName: "littlePrinter",
            inputWires: [wire0, wire1, wire2]
        )

        XCTAssertEqual(unitManager.wireManager.examine(), 0)
        unitManager.clock()
        XCTAssertEqual(wire2.v, (8 + 5) * 2)
    }

    func testLonelyWireExamine() {
        let unitManager = StaticUnitManager()

        let lonelyWire0 = Wire("lonelyWire0")
        let lonelyWire1 = Wire("lonelyWire1")

        _ = unitManager.addOutputUnit(
            unitName: "lonelyOutput",
            outputWires: [lonelyWire0],
            outputValue: 555
        )
        _ = unitManager.addPrinterUnit(
            unitName: "lonely_printer",
            inputWires: [lonelyWire1]
        )

        XCTAssertEqual(unitManager.wireManager.examine(), 2)
    }

    func testDuplicateName() {
        let unitManager = StaticUnitManager()

        let addOne = {
            unitManager.addOutputUnit(
                unitName: "bugen",
                outputWires: [],
                outputValue: 555
            ) }

        _ = addOne()
        expect { _ = addOne() }.to(throwAssertion())
    }

    func testConflictOutput() {
        let unitManager = StaticUnitManager()

        let crowded = Wire("crowded")

        let addOne = { (name: String) -> Void in
            _ = unitManager.addOutputUnit(
                unitName: name,
                outputWires: [crowded],
                outputValue: 555
            ) }

        addOne("bugen")
        expect { addOne("zhao") }.to(throwAssertion())
    }

    func testWriteInputWire() {
        let unitManager = StaticUnitManager()

        let wire0 = Wire("wire0")
        let wire1 = Wire("wire1")

        expect {
            _ = unitManager.addGenericUnit(
                unitName: "illegalWriter",
                inputWires: [wire0],
                outputWires: [wire1],
                logic: {
                    wire1.v = wire0.v + 5
                    wire0.v = 0
                }
            ) }.to(throwAssertion())
    }

    func testReadOutputWire() {
        let unitManager = StaticUnitManager()

        let wire0 = Wire("wire0")
        let wire1 = Wire("wire1")

        expect {
            _ = unitManager.addGenericUnit(
                unitName: "illegalReader",
                inputWires: [wire0, wire1],
                outputWires: [],
                logic: {
                    wire0.v = wire1.v + 5
                }
            ) }.to(throwAssertion())
    }

    func testReadNotDeclaredWire() {
        // No such protection is static manager
    }

    func testWriteNotDeclaredWire() {
        // No such protection is static manager
    }

    func testHalt() {
        let unitManager = StaticUnitManager()

        let w = Wire("w")

        _ = unitManager.addOutputUnit(
            unitName: "output_1",
            outputWires: [w],
            outputValue: 1
        )
        _ = unitManager.addHaltUnit(
            unitName: "halt",
            inputWires: [w]
        )

        unitManager.clock()
        XCTAssertEqual(unitManager.halted, false)
        unitManager.clock()
        XCTAssertEqual(unitManager.halted, true)
    }

    func testRegisterInc() {
        let unitManager = StaticUnitManager()

        let wpci = Wire("wpci")
        let wpco = Wire("wpco")

        _ = unitManager.addRegisterUnit(
            unitName: "PC",
            inputWires: [wpci],
            outputWires: [wpco],
            logic: { ru in wpco.v = ru[q: 0] },
            onRising: { ru in
                var ru = ru
                ru[q: 0] = wpci.v
            },
            bytesCount: 8
        )

        _ = unitManager.addGenericUnit(
            unitName: "inc_1",
            inputWires: [wpco],
            outputWires: [wpci],
            logic: { wpci.v = wpco.v + 1 }
        )

        XCTAssertEqual((unitManager.PC as! StaticRegisterUnit)[q: 0], 0)
        unitManager.clock()
        XCTAssertEqual((unitManager.PC as! StaticRegisterUnit)[q: 0], 0)
        unitManager.clock()
        XCTAssertEqual((unitManager.PC as! StaticRegisterUnit)[q: 0], 1)
        unitManager.clock()
        XCTAssertEqual((unitManager.PC as! StaticRegisterUnit)[q: 0], 2)
        unitManager.clock()
        XCTAssertEqual((unitManager.PC as! StaticRegisterUnit)[q: 0], 3)
    }

}
