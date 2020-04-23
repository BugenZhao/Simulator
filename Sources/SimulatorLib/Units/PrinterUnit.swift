//
//  PrinterUnit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public class PrinterUnit: Unit {
    public var name: UnitName
    public var inputWires: [WireName]
    public var outputWires: [WireName] = []
    public var logic: (WireManager) -> Void = { _ in return }
    public var onRising: (WireManager) -> Void = { _ in return }

    var onlyOnRising: Bool

    init(_ unitName: UnitName,
        _ inputWires: [WireName],
        _ onlyOnRising: Bool) {
        self.name = unitName
        self.inputWires = inputWires
        self.onlyOnRising = onlyOnRising

        self.onRising = onRisingFunc
        if !onlyOnRising { self.logic = onRisingFunc }
    }

    func onRisingFunc(_ wireManager: WireManager) {
        print("\(type(of: self)) \(name)")
        inputWires.forEach { print("\t\($0): \(wireManager[mayCreate: $0].v)") }
    }

    public func copied() -> Self {
        return PrinterUnit(name, inputWires, onlyOnRising) as! Self
    }
}
