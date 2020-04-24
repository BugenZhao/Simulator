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

    private(set) public var halted: Bool = false

    private(set) var cycle: UInt64 = 0

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
        logic: @escaping (WireManager) -> Void = { _ in return }) -> GenericUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = GenericUnit(unitName, inputWires, outputWires, logic)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addPrinterUnit(
        unitName: UnitName,
        inputWires: [WireName],
        onlyOnRising: Bool = true) -> PrinterUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = PrinterUnit(unitName, inputWires, onlyOnRising)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        units[unitName] = unit

        return unit
    }

    public func addOutputUnit(
        unitName: UnitName,
        outputWires: [WireName] = [],
        outputValue: UInt64 = 0) -> OutputUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = OutputUnit(unitName, outputWires, outputValue)
        checkPermission(unit)
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addRegisterUnit(
        unitName: UnitName,
        inputWires: [WireName],
        outputWires: [WireName],
        logic: @escaping (WireManager, RegisterUnit) -> Void,
        onRising: @escaping (WireManager, RegisterUnit) -> Void,
        bytesCount: Int) -> RegisterUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = RegisterUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addMemoryUnit(
        unitName: UnitName,
        inputWires: [WireName],
        outputWires: [WireName],
        logic: @escaping (WireManager, MemoryUnit) -> Void,
        onRising: @escaping (WireManager, MemoryUnit) -> Void,
        bytesCount: Int) -> MemoryUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = MemoryUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        outputWires.forEach { wireName in wireManager[mayCreate: wireName].from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addHaltUnit(
        unitName: UnitName,
        inputWires: [WireName] = []) -> HaltUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = HaltUnit(unitName, inputWires, { self.halted = true })
        checkPermission(unit)
        inputWires.forEach { wireName in wireManager[mayCreate: wireName].to.append(unitName) }
        units[unitName] = unit

        return unit
    }


    private func checkPermission(_ unit: Unit) {
        let tempWireManager = WireManager(safe: true)
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
//        if !self.halted { print("Cycle \(cycle):") }
//        else { print("Machine is halted.") }

        if !self.halted {
            rise()
        }
        if !self.halted {
            stablize()
            cycle += 1
        }
    }
}
