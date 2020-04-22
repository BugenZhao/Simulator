//
//  BasicUnit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public class GenericUnit: Unit {
    var name: UnitName
    var inputWires: [WireName]
    var outputWires: [WireName]
    var logic: (WireManager) -> Void
    var onRising: (WireManager) -> Void = { _ in return }

    init(_ unitName: UnitName,
        _ inputWires: [WireName],
        _ outputWires: [WireName],
        _ logic: @escaping (WireManager) -> Void) {
        self.name = unitName
        self.inputWires = inputWires
        self.outputWires = outputWires
        self.logic = logic
    }
}
