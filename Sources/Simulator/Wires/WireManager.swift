//
//  WireManager.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

@dynamicMemberLookup
public class WireManager {
    var wires: [WireName: Wire] = [:]
    var checkpoint: [WireName: UInt64] = [:]

    subscript(dynamicMember wireName: WireName) -> Wire {
        get {
            return self[wireName]
        }
    }

    subscript(_ wireName: WireName) -> Wire {
        get {
            if let wire = wires[wireName] { return wire }
            let wire = Wire(wireName: wireName, value: 0)
            wires[wireName] = wire
            return wire
        }
    }

    public func clearCheckpoint() {
        checkpoint.removeAll()
    }

    public func doCheckpoint() -> Bool {
        var newCheckpoint: [WireName: UInt64] = [:]
        defer { checkpoint = newCheckpoint }
        wires.forEach { wireName, wire in newCheckpoint[wireName] = wire.value }
        return checkpoint == newCheckpoint
    }

    public func examine() -> Int {
        return wires.values.reduce(0) { acc, wire in
            if wire.from == nil {
                print("Warning: Wire \(wire.name): no from unit")
                return acc + 1
            } else if wire.to.isEmpty {
                print("Warning: Wire \(wire.name): no to unit")
                return acc + 1
            }
            return acc
        }
    }
}
