//
//  StaticOutputUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

public class StaticOutputUnit: StaticUnit {
    var name: UnitName
    var inputWires: [Wire] = []
    var outputWires: [Wire]
    var logic: () -> Void = { }
    var onRising: () -> Void = { }

    let outputValue: UInt64

    init(_ unitName: UnitName,
        _ outputWires: [Wire],
        _ outputValue: UInt64) {
        self.name = unitName
        self.outputWires = outputWires
        self.outputValue = outputValue
        self.logic = logicFunc
    }

    func logicFunc() {
        outputWires.forEach { $0.v = outputValue }
    }
}
