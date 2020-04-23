//
//  BasicUnit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public class GenericUnit: Unit {
    public var name: UnitName
    public var inputWires: [WireName]
    public var outputWires: [WireName]
    public var logic: (WireManager) -> Void
    public var onRising: (WireManager) -> Void = { _ in return }

    init(_ unitName: UnitName,
        _ inputWires: [WireName],
        _ outputWires: [WireName],
        _ logic: @escaping (WireManager) -> Void) {
        self.name = unitName
        self.inputWires = inputWires
        self.outputWires = outputWires
        self.logic = logic
    }

    public func copied() -> Self {
        return GenericUnit(name, inputWires, outputWires, logic) as! Self
    }
}
