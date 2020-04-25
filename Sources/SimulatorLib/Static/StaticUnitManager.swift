//
//  StaticUnitManager.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

@dynamicMemberLookup
public class StaticUnitManager {
    public let wireManager = StaticWireManager()

    private(set) var units: [UnitName: StaticUnit] = [:]

    private(set) public var halted: Bool = false

    private(set) public var cycle: UInt64 = 0

    subscript(dynamicMember unitName: UnitName) -> StaticUnit? {
        get {
            return self[unitName]
        }
    }

    subscript(_ unitName: UnitName) -> StaticUnit? {
        get {
            return units[unitName]
        }
    }

    public init() { }

    public func addGenericUnit(
        unitName: UnitName,
        inputWires: [Wire] = [],
        outputWires: [Wire] = [],
        logic: @escaping () -> Void = { }) -> StaticGenericUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = StaticGenericUnit(unitName, inputWires, outputWires, logic)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName) }
        outputWires.forEach { $0.from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addPrinterUnit(
        unitName: UnitName,
        inputWires: [Wire],
        onlyOnRising: Bool = true) -> StaticPrinterUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = StaticPrinterUnit(unitName, inputWires, onlyOnRising)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName) }
        units[unitName] = unit

        return unit
    }

    public func addOutputUnit(
        unitName: UnitName,
        outputWires: [Wire] = [],
        outputValue: UInt64 = 0) -> StaticOutputUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = StaticOutputUnit(unitName, outputWires, outputValue)
        checkPermission(unit)
        outputWires.forEach { $0.from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addRegisterUnit(
        unitName: UnitName,
        inputWires: [Wire],
        outputWires: [Wire],
        logic: @escaping (StaticRegisterUnit) -> Void,
        onRising: @escaping (StaticRegisterUnit) -> Void,
        bytesCount: Int) -> StaticRegisterUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = StaticRegisterUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName) }
        outputWires.forEach { $0.from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addMemoryUnit(
        unitName: UnitName,
        inputWires: [Wire],
        outputWires: [Wire],
        logic: @escaping (StaticMemoryUnit) -> Void,
        onRising: @escaping (StaticMemoryUnit) -> Void,
        bytesCount: Int) -> StaticMemoryUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = StaticMemoryUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName) }
        outputWires.forEach { $0.from = unitName }
        units[unitName] = unit

        return unit
    }

    public func addHaltUnit(
        unitName: UnitName,
        inputWires: [Wire] = []) -> StaticHaltUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue)
        }
        let unit = StaticHaltUnit(unitName, inputWires, { self.halted = true })
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName) }
        units[unitName] = unit

        return unit
    }


    private func checkPermission(_ unit: StaticUnit) {
        let tempWireManager = StaticWireManager()
        unit.inputWires.forEach { tempWireManager.addWire($0) }
        unit.outputWires.forEach { tempWireManager.addWire($0) }
        unit.logic()
        unit.onRising()

        guard (unit.inputWires.allSatisfy { $0.counter.write == 0 }) else {
            fatalError(SimulatorError.UnitManagerWriteNotAllowedError.rawValue)
        }
        guard (unit.outputWires.allSatisfy { $0.counter.read == 0 }) else {
            fatalError(SimulatorError.UnitManagerReadNotAllowedError.rawValue)
        }

        unit.inputWires.forEach { $0.clear() }
        unit.outputWires.forEach { $0.clear() }
    }


    func stablize() {
        wireManager.clearCheckpoint()
        repeat {
            units.values.forEach { $0.logic() }
        } while(wireManager.doCheckpoint() == false)
    }

    func rise() {
        units.values.forEach { $0.onRising() }
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
