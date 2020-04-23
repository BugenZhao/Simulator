//
//  HaltUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/23.
//

import Foundation

public class HaltUnit: Unit {
    public var name: UnitName
    public var inputWires: [WireName]
    public var outputWires: [WireName] = []
    public var logic: (WireManager) -> Void = { _ in return }
    public var onRising: (WireManager) -> Void = { _ in return }

    var haltAction: () -> Void

    init(_ unitName: UnitName,
        _ inputWires: [WireName],
        _ haltAction: @escaping () -> Void) {
        self.name = unitName
        self.inputWires = inputWires

        self.haltAction = haltAction

        self.onRising = { wm in
            let needToHalt = !inputWires.allSatisfy { wireName in wm[wireName].b == false }
            if needToHalt { haltAction() }
        }
    }


    public func copied() -> Self {
        return HaltUnit(name, inputWires, haltAction) as! Self
    }
}
