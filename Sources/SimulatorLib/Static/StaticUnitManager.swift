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

    var isReady = false

    public init() { }

    public func addGenericUnit(
        unitName: UnitName,
        inputWires: [Wire] = [],
        outputWires: [Wire] = [],
        logic: @escaping () -> Void = { }) -> StaticGenericUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticGenericUnit(unitName, inputWires, outputWires, logic)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }
        units[unitName] = unit

        return unit
    }

    public func addPrinterUnit(
        unitName: UnitName,
        inputWires: [Wire],
        onlyOnRising: Bool = true) -> StaticPrinterUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticPrinterUnit(unitName, inputWires, onlyOnRising)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
        units[unitName] = unit

        return unit
    }

    public func addOutputUnit(
        unitName: UnitName,
        outputWires: [Wire] = [],
        outputValue: UInt64 = 0) -> StaticOutputUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticOutputUnit(unitName, outputWires, outputValue)
        checkPermission(unit)
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }
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
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticRegisterUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }
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
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticMemoryUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }
        units[unitName] = unit

        return unit
    }

    public func addHaltUnit(
        unitName: UnitName,
        inputWires: [Wire] = []) -> StaticHaltUnit {
        guard !units.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticHaltUnit(unitName, inputWires, { self.halted = true })
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
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
            fatalError(SimulatorError.UnitManagerWriteNotAllowedError.rawValue + unit.name)
        }
        guard (unit.outputWires.allSatisfy { $0.counter.read == 0 }) else {
            fatalError(SimulatorError.UnitManagerReadNotAllowedError.rawValue + unit.name)
        }

        unit.inputWires.forEach { $0.clear() }
        unit.outputWires.forEach { $0.clear() }
    }


    func stablize() {
        wireManager.clearCheckpoint()
        repeat {
            units.values.forEach { $0.logic() }
//            print("Stablize:")
//            wireManager.wires.forEach { print($0.name, $0.v) }
        } while(wireManager.doCheckpoint() == false)
    }

    func rise() {
        units.values.forEach { $0.onRising() }
    }

    public func clock() {
        if !self.isReady {print("Warning: \(type(of:self)) may not be ready.")}
        stablize()
        rise()
//        print("Rise:")
//        wireManager.wires.forEach { print($0.name, $0.v) }
        cycle += 1
    }

    public func ready() -> Int {
        defer { isReady = true }
        return self.wireManager.examine()
    }
}
