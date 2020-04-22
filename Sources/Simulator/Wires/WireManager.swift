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
            if let wire = wires[wireName] { return wire }
            let wire = Wire(wireName: wireName, value: 0)
            wires[wireName] = wire
            return wire
        }
    }

    subscript(_ wireName: WireName) -> Wire {
        get {
            return self[dynamicMember: wireName]
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
}
