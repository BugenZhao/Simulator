//
//  StaticBasicUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

public class StaticGenericUnit: StaticUnit {
    var name: UnitName
    var inputWires: [Wire]
    var outputWires: [Wire]
    var logic: () -> Void
    var onRising: () -> Void = { }

    init(_ unitName: UnitName,
        _ inputWires: [Wire],
        _ outputWires: [Wire],
        _ logic: @escaping () -> Void) {
        self.name = unitName
        self.inputWires = inputWires
        self.outputWires = outputWires
        self.logic = logic
    }
}
