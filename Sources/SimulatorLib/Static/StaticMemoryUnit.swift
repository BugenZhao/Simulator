//
//  StaticMemoryUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

public class StaticMemoryUnit: StaticUnit, Addressable {
    var name: UnitName
    var inputWires: [Wire]
    var outputWires: [Wire]
    var logic: () -> Void = { }
    var onRising: () -> Void = { }

    public var data: Data

    var realLogics: [(StaticMemoryUnit) -> Void]
    var realOnRisings: [(StaticMemoryUnit) -> Void]

    init(_ unitName: UnitName,
        _ inputWires: [Wire],
        _ outputWires: [Wire],
        _ logic: @escaping (StaticMemoryUnit) -> Void,
        _ onRising: @escaping (StaticMemoryUnit) -> Void,
        _ bytesCount: Int) {
        self.name = unitName
        self.inputWires = inputWires
        self.outputWires = outputWires

        self.data = Data(count: bytesCount)

        self.realLogics = [logic]
        self.realOnRisings = [onRising]

        self.logic = { self.realLogics.forEach { $0(self) } }
        self.onRising = { self.realOnRisings.forEach { $0(self) } }
    }

    public func addLogic(_ logic: @escaping (StaticMemoryUnit) -> Void) {
        realLogics.append(logic)
    }

    public func addOnRising(_ onRising: @escaping (StaticMemoryUnit) -> Void) {
        realOnRisings.append(onRising)
    }
}
