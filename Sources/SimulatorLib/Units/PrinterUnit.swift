//
//  PrinterUnit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public class PrinterUnit: Unit {
    var name: UnitName
    var inputWires: [WireName]
    var outputWires: [WireName] = []
    var logic: (WireManager) -> Void = { _ in return }
    var onRising: (WireManager) -> Void = { _ in return }

    init(_ unitName: UnitName,
        _ inputWires: [WireName]) {
        self.name = unitName
        self.inputWires = inputWires
        self.logic = onRisingFunc
        self.onRising = onRisingFunc
    }

    func onRisingFunc(_ wireManager: WireManager) {
        print("\(type(of: self)) \(name)")
        inputWires.forEach { print("\t\($0): \(wireManager[$0].value)") }
    }
}
