//
//  StaticWireManager.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation


public class StaticWireManager {
    var wires: [Wire] = []
    var wiresDict: [WireName: Wire] = [:]
    var checkpoint: [UInt64] = []

    public func addWire(_ wire: Wire) {
        if let exWire = wiresDict[wire.name] {
            if exWire !== wire { fatalError(SimulatorError.WireManagerDuplicateNameError.rawValue) }
            else { return }
        }
        wires.append(wire)
        wiresDict[wire.name] = wire
    }

    public func clearCheckpoint() {
        checkpoint.removeAll()
    }

    public func doCheckpoint() -> Bool {
        var newCheckpoint = wires.map { $0.v }
        defer { checkpoint = newCheckpoint }
        return checkpoint == newCheckpoint
    }

    public func doPartialCheckpoint() -> Set<UnitName> {
        var newCheckpoint = wires.map { $0.v }
        defer { checkpoint = newCheckpoint }

        var ret = Set<UnitName>()
        for idx in 0..<checkpoint.count {
            if checkpoint[idx] != newCheckpoint[idx] {
                wires[idx].to.forEach { ret.insert($0) }
            }
        }
        return ret
    }

    public func examine(verbose: Bool = true) -> Int {
        return wires.reduce(0) { acc, wire in
            if wire.from == nil {
                if verbose { print("Warning: Wire \(wire.name): no from unit") }
                return acc + 1
            } else if wire.to.isEmpty {
                if verbose { print("Warning: Wire \(wire.name): no to unit") }
                return acc + 1
            }
            return acc
        }
    }
}
