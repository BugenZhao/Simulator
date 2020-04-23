//
//  Comparator.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation
import SimulatorLib

public class MaxMachine: Machine {
    public var unitManager = UnitManager()
    let a, b: UInt64

    public func run() {
        unitManager.clock()
        print("max(\(a), \(b)) is \(unitManager.wireManager.wout.v)")
    }

    public init(_ a: UInt64, _ b: UInt64) {
        self.a = a
        self.b = b
        unitManager.addOutputUnit(
            unitName: "a",
            outputWires: ["wa"],
            outputValue: a
        )
        unitManager.addOutputUnit(
            unitName: "b",
            outputWires: ["wb"],
            outputValue: b
        )
        unitManager.addGenericUnit(
            unitName: "logical_comparator",
            inputWires: ["wa", "wb"],
            outputWires: ["wselect"],
            logic: { wm in
                wm.wselect.b = wm.wa.v < wm.wb.v
            }
        )
        unitManager.addGenericUnit(
            unitName: "mux",
            inputWires: ["wa", "wb", "wselect"],
            outputWires: ["wout"],
            logic: { wm in
                wm.wout.v = wm.wselect.b ? wm.wb.v : wm.wa.v
            }
        )
        _ = unitManager.wireManager.examine(verbose: false)
    }
}
