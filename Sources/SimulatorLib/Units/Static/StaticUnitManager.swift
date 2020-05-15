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

    private(set) var unitsDict: [UnitName: StaticUnit] = [:]
    private(set) var units: [StaticUnit] = []

    public private(set) var halted: Bool = false

    public private(set) var cycle: UInt64 = 0

    subscript(dynamicMember unitName: UnitName) -> StaticUnit? {
        get {
            return self[unitName]
        }
    }

    subscript(_ unitName: UnitName) -> StaticUnit? {
        get {
            return unitsDict[unitName]
        }
    }

    var isReady = false

    public init() {}

    @discardableResult
    public func addGenericUnit(
        unitName: UnitName,
        inputWires: [Wire] = [],
        outputWires: [Wire] = [],
        logic: @escaping () -> Void = {}) -> StaticGenericUnit {
        guard !unitsDict.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticGenericUnit(unitName, inputWires, outputWires, logic)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }

        unitsDict[unitName] = unit
        units.append(unit)

        return unit
    }

    @discardableResult
    public func addPrinterUnit(
        unitName: UnitName,
        inputWires: [Wire],
        onlyOnRising: Bool = true) -> StaticPrinterUnit {
        guard !unitsDict.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticPrinterUnit(unitName, inputWires, onlyOnRising)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }

        unitsDict[unitName] = unit
        units.append(unit)

        return unit
    }

    @discardableResult
    public func addOutputUnit(
        unitName: UnitName,
        outputWires: [Wire] = [],
        outputValue: UInt64 = 0) -> StaticOutputUnit {
        guard !unitsDict.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticOutputUnit(unitName, outputWires, outputValue)
        checkPermission(unit)
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }

        unitsDict[unitName] = unit
        units.append(unit)

        return unit
    }

    @discardableResult
    public func addRegisterUnit(
        unitName: UnitName,
        inputWires: [Wire],
        outputWires: [Wire],
        logic: @escaping (StaticRegisterUnit) -> Void,
        onRising: @escaping (StaticRegisterUnit) -> Void,
        bytesCount: Int) -> StaticRegisterUnit {
        guard !unitsDict.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticRegisterUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }

        unitsDict[unitName] = unit
        units.append(unit)

        return unit
    }

    @discardableResult
    public func addQuadStageRegisterUnit(
        unitName: UnitName,
        inputWires: [Wire],
        outputWires: [Wire],
        controlWires: [Wire],
        defaultOnRisingWhen: @autoclosure @escaping () -> Bool = true,
        else: @escaping (StaticRegisterUnit) -> Void = { _ in }) -> StaticRegisterUnit {
        guard !unitsDict.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        guard inputWires.count == outputWires.count else { fatalError() }

        let logic: (StaticRegisterUnit) -> Void = { ru in
            outputWires.enumerated().forEach { i, wire in wire.v = ru[i.u64] }
        }
        let onRising: (StaticRegisterUnit) -> Void = { ru in var ru = ru
            if defaultOnRisingWhen() { // write
                inputWires.enumerated().forEach { i, wire in ru[i.u64] = wire.v }
            } else { `else`(ru) } // may bubble?
        }
        let bytesCount = 8 * inputWires.count
        let unit = StaticRegisterUnit(unitName, inputWires + controlWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        (inputWires + controlWires).forEach { $0.to.append(unitName); wireManager.addWire($0) }
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }

        unitsDict[unitName] = unit
        units.append(unit)

        return unit
    }

    @discardableResult
    public func addMemoryUnit(
        unitName: UnitName,
        inputWires: [Wire],
        outputWires: [Wire],
        logic: @escaping (StaticMemoryUnit) -> Void,
        onRising: @escaping (StaticMemoryUnit) -> Void,
        bytesCount: Int) -> StaticMemoryUnit {
        guard !unitsDict.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticMemoryUnit(unitName, inputWires, outputWires, logic, onRising, bytesCount)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }
        outputWires.forEach { $0.from = unitName; wireManager.addWire($0) }

        unitsDict[unitName] = unit
        units.append(unit)

        return unit
    }

    @discardableResult
    public func addHaltUnit(
        unitName: UnitName,
        inputWires: [Wire] = [],
        onlyOnRising: Bool = true) -> StaticHaltUnit {
        guard !unitsDict.keys.contains(unitName) else {
            fatalError(SimulatorError.UnitManagerDuplicateNameError.rawValue + unitName)
        }
        let unit = StaticHaltUnit(unitName, inputWires, { self.halted = true }, onlyOnRising)
        checkPermission(unit)
        inputWires.forEach { $0.to.append(unitName); wireManager.addWire($0) }

        unitsDict[unitName] = unit
        units.append(unit)

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
        repeat {
            guard !halted else { return }
            units.forEach { $0.logic() }
        } while (wireManager.doCheckpoint() == false)
    }

    func rise() {
        guard !halted else { return }
        units.forEach { $0.onRising() }
        wireManager.clearCheckpoint()
    }

    public func clock(resetWire: Bool = false, debug: Bool = false) {
        if !self.isReady { print("Warning: \(type(of: self)) may not be ready.") }

        guard !halted else { return }
        stablize()
        guard !halted else { return }
        rise()
        guard !halted else { return }

        if resetWire { resetWires() }
        if debug {
            print("Rise:")
            wireManager.wires.forEach { print($0.name, $0.v) }
        }
        cycle += 1
    }

    public func resetWires() {
        wireManager.wires.forEach { $0.v = 0 }
    }

    @discardableResult
    public func ready(verbose: Bool = true) -> Int {
        defer { isReady = true }
        return self.wireManager.examine(verbose: verbose)
    }
}
