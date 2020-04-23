//
//  UnitManager.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

@dynamicMemberLookup
public class UnitManager {
    public let wireManager = WireManager()
    private(set) var units: [UnitName: Unit] = [:]

    subscript(dynamicMember unitName: UnitName) -> Unit? {
        get {
            return self[unitName]
        }
    }

    subscript(_ unitName: UnitName) -> Unit? {
        get {
            return units[unitName]
        }
    }

    public init() { }

    public func addGenericUnit(
        unitName: UnitName,
        inputWires: [WireName] = [],
        outputWires: [WireName] = [],
        logic: @escaping (WireManager) -> Void = { _ in return }) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit: Unit = GenericUnit(unitName, inputWires, outputWires, logic)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit
    }

    public func addPrinterUnit(
        unitName: UnitName,
        inputWires: [WireName] = []) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit: Unit = PrinterUnit(unitName, inputWires)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        units[unitName] = unit
    }

    public func addOutputUnit(
        unitName: UnitName,
        outputWires: [WireName] = [],
        outputValue: UInt64 = 0) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit: Unit = OutputUnit(unitName, outputWires, outputValue)
        checkPermission(unit)
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit
    }

    public func addRegisterUnit(
        unitName: UnitName,
        inputWires: [WireName],
        outputWires: [WireName],
        logic: @escaping (WireManager, RegisterUnit) -> Void,
        onRising: @escaping (WireManager, RegisterUnit) -> Void,
        bytesCount: Int) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit: Unit = RegisterUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit
    }
    
    public func addMemoryUnit(
        unitName: UnitName,
        inputWires: [WireName],
        outputWires: [WireName],
        logic: @escaping (WireManager, MemoryUnit) -> Void,
        onRising: @escaping (WireManager, MemoryUnit) -> Void,
        bytesCount: Int) {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit: Unit = MemoryUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit
    }


    private func checkPermission(_ unit: Unit) {
        let tempWireManager = WireManager()
        let tempUnit = unit.copied()
        tempUnit.inputWires.forEach { wireName in
            tempWireManager[mayCreate: wireName].to.append(tempUnit.name)
        }
        tempUnit.outputWires.forEach { wireName in
            tempWireManager[mayCreate: wireName].from = tempUnit.name
        }
        tempUnit.logic(tempWireManager)

        guard (tempUnit.inputWires.allSatisfy { wireName in
            tempWireManager[mayCreate: wireName].counter.write == 0
        }) else {
            fatalError(SimulatorError.UnitManagerWriteNotAllowedError.rawValue)
        }
        guard (tempUnit.outputWires.allSatisfy { wireName in
            tempWireManager[mayCreate: wireName].counter.read == 0
        }) else {
            fatalError(SimulatorError.UnitManagerReadNotAllowedError.rawValue)
        }
    }


    func stablize() {
        wireManager.clearCheckpoint()
        repeat {
            units.values.forEach { $0.logic(wireManager) }
        } while(wireManager.doCheckpoint() == false)
    }

    func rise() {
        units.values.forEach { $0.onRising(wireManager) }
    }

    public func clock() {
        rise()
        stablize()
    }
}
