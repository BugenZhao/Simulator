//
//  StaticHaltUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

public class StaticHaltUnit: StaticUnit {
    var name: UnitName
    var inputWires: [Wire]
    var outputWires: [Wire] = []
    var logic: () -> Void = {}
    var onRising: () -> Void = {}

    var haltAction: () -> Void

    init(_ unitName: UnitName,
        _ inputWires: [Wire],
        _ haltAction: @escaping () -> Void) {
        self.name = unitName
        self.inputWires = inputWires

        self.haltAction = haltAction

        self.onRising = {
            let needToHalt = !inputWires.allSatisfy { $0.b == false }
            if needToHalt { haltAction() }
        }
    }
}
