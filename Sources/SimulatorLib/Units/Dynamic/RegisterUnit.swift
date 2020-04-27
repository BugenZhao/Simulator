//
//  RegisterUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/23.
//

import Foundation

public class RegisterUnit: Unit, Addressable {
    var name: UnitName
    var inputWires: [WireName]
    var outputWires: [WireName]
    var logic: (WireManager) -> Void = { _ in return }
    var onRising: (WireManager) -> Void = { _ in return }

    public var data: Data

    var realLogic: (WireManager, RegisterUnit) -> Void
    var realOnRising: (WireManager, RegisterUnit) -> Void

    init(_ unitName: UnitName,
        _ inputWires: [WireName],
        _ outputWires: [WireName],
        _ logic: @escaping (WireManager, RegisterUnit) -> Void,
        _ onRising: @escaping (WireManager, RegisterUnit) -> Void,
        _ bytesCount: Int) {
        self.name = unitName
        self.inputWires = inputWires
        self.outputWires = outputWires
        
        self.data = Data(count: bytesCount)

        self.realLogic = logic
        self.realOnRising = onRising

        self.logic = { wm in self.realLogic(wm, self) }
        self.onRising = { wm in self.realOnRising(wm, self) }
    }

    func copied() -> Self {
        return RegisterUnit(name, inputWires, outputWires, realLogic, realOnRising, data.count) as! Self
    }
}
