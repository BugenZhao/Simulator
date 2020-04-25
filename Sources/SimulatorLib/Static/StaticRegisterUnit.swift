//
//  StaticRegisterUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

public class StaticRegisterUnit: StaticUnit, Addressable {
    var name: UnitName
    var inputWires: [Wire]
    var outputWires: [Wire]
    var logic: () -> Void = { }
    var onRising: () -> Void = { }

    public var data: Data

    var realLogic: (StaticRegisterUnit) -> Void
    var realOnRising: (StaticRegisterUnit) -> Void

    init(_ unitName: UnitName,
        _ inputWires: [Wire],
        _ outputWires: [Wire],
        _ logic: @escaping (StaticRegisterUnit) -> Void,
        _ onRising: @escaping (StaticRegisterUnit) -> Void,
        _ bytesCount: Int) {
        self.name = unitName
        self.inputWires = inputWires
        self.outputWires = outputWires

        self.data = Data(count: bytesCount)

        self.realLogic = logic
        self.realOnRising = onRising

        self.logic = { self.realLogic(self) }
        self.onRising = { self.realOnRising(self) }
    }
}
