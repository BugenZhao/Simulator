//
//  WireManager.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

@dynamicMemberLookup
public class WireManager {
    @usableFromInline var wires: [WireName: Wire] = [:]
    var checkpoint: [WireName: UInt64] = [:]

    public let safe: Bool

    @inlinable public subscript(dynamicMember wireName: WireName) -> Wire {
        get {
            return self[wireName]
        }
    }

    public subscript(mayCreate wireName: WireName) -> Wire {
        get {
            if let wire = wires[wireName] { return wire }
            let wire = Wire(wireName: wireName, value: 0, safe: safe)
            wires[wireName] = wire
            return wire
        }
    }

    @inlinable public subscript(_ wireName: WireName) -> Wire {
        get {
            guard !safe || wires.keys.contains(wireName) else {
                fatalError(SimulatorError.WireManagerWireNotExistsError.rawValue + " (\(wireName))")
            }
            return wires[wireName]!
        }
    }

    public func clearCheckpoint() {
        checkpoint.removeAll()
    }

    public func doCheckpoint() -> Bool {
        var newCheckpoint = wires.mapValues { wire in wire.v }
        defer { checkpoint = newCheckpoint }
        return checkpoint == newCheckpoint
    }

    public func examine(verbose: Bool = true) -> Int {
        return wires.values.reduce(0) { acc, wire in
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

    init(safe: Bool = false) {
        self.safe = safe
    }
}
