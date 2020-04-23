//
//  OutputUnit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public class OutputUnit: Unit {
    public var name: UnitName
    public var inputWires: [WireName] = []
    public var outputWires: [WireName]
    public var logic: (WireManager) -> Void = { _ in return }
    public var onRising: (WireManager) -> Void = { _ in return }

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
        outputWires.forEach { wireManager[mayCreate: $0].v = outputValue }
    }

    public func copied() -> Self {
        return OutputUnit(name, outputWires, outputValue) as! Self
    }
}
