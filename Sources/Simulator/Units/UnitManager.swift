//
//  UnitManager.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public class UnitManager {
    let wireManager = WireManager()
    private(set) var units: [UnitName: Unit] = [:]

    public func addBasicUnit(
        unitName: UnitName,
        inputWires: [WireName],
        outputWires: [WireName],
        logic: @escaping (WireManager) -> Void) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateName.rawValue)
        }
        let unit: Unit = BasicUnit(unitName, inputWires, outputWires, logic)
        inputWires.forEach { wireName in wireManager[wireName].to.append(unitName) }
        outputWires.forEach { wireName in wireManager[wireName].from = unitName }
        units[unitName] = unit
    }

    public func addPrinterUnit(
        unitName: UnitName,
        inputWires: [WireName]) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateName.rawValue)
        }
        let unit: Unit = PrinterUnit(unitName, inputWires)
        inputWires.forEach { wireName in wireManager[wireName].to.append(unitName) }
        units[unitName] = unit
    }

    public func addOutputUnit(
        unitName: UnitName,
        outputWires: [WireName],
        outputValue: UInt64 ) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateName.rawValue)
        }
        let unit: Unit = OutputUnit(unitName, outputWires, outputValue)
        outputWires.forEach { wireName in wireManager[wireName].from = unitName }
        units[unitName] = unit
    }


    private func stablize() {
        wireManager.clearCheckpoint()
        repeat {
            units.values.forEach { $0.logic(wireManager) }
        } while(wireManager.doCheckpoint() == false)
    }

    private func rise() {
        units.values.forEach { $0.onRising(wireManager) }
    }

    public func clock() {
        rise()
        stablize()
    }
}
