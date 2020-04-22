//
//  PrinterUnit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

class PrinterUnit: Unit {
    var name: UnitName
    var inputWires: [WireName]
    var outputWires: [WireName] = []
    var logic: (WireManager) -> Void = { _ in return }
    var onRising: (WireManager) -> Void = { _ in return }

    init(_ unitName: UnitName,
        _ inputWires: [WireName]) {
        self.name = unitName
        self.inputWires = inputWires
        self.onRising = onRisingFunc
    }

    func onRisingFunc(_ wireManager: WireManager) {
        print("\(type(of: self)) \(name)")
        inputWires.forEach { wireName in print("\t\(wireName): \(wireManager[wireName])") }
    }
}
