//
//  StaticPrinterUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

public class StaticPrinterUnit: StaticUnit {
    var name: UnitName
    var inputWires: [Wire]
    var outputWires: [Wire] = []
    var logic: () -> Void = { }
    var onRising: () -> Void = { }

    var onlyOnRising: Bool

    init(_ unitName: UnitName,
         _ inputWires: [Wire],
        _ onlyOnRising: Bool) {
        self.name = unitName
        self.inputWires = inputWires
        self.onlyOnRising = onlyOnRising

        self.onRising = onRisingFunc
        if !onlyOnRising { self.logic = onRisingFunc }
    }

    func onRisingFunc() {
        print("\(type(of: self)) \(name)")
        inputWires.forEach { print("\t\($0.name): \($0.v)") }
    }
}
