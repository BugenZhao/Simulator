//
//  OutputUnit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public class OutputUnit: Unit {
    var name: UnitName
    var inputWires: [WireName] = []
    var outputWires: [WireName]
    var logic: (WireManager) -> Void = { _ in return }
    var onRising: (WireManager) -> Void = { _ in return }

    let outputValue: UInt64

    init(_ unitName: UnitName,
        _ outputWires: [WireName],
        _ outputValue: UInt64) {
        self.name = unitName
        self.outputWires = outputWires
        self.outputValue = outputValue
        self.logic = logicFunc
    }

    func logicFunc(_ wireManager: WireManager) {
        outputWires.forEach { wireManager[$0].value = outputValue }
    }
}
