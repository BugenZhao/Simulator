//
//  WireManagerDoctor.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

class WireManagerDoctor: WireManager {
    var inputOnlyWire: [WireName] = []
    var outputOnlyWire: [WireName] = []

    override subscript(dynamicMember wireName: WireName) -> Wire {
        get {
            return self[wireName]
        }
    }

    override subscript(_ wireName: WireName) -> Wire {
        get {
            if let wire = wires[wireName] { return wire }
            let wire = Wire(wireName: wireName, value: 0)
            wires[wireName] = wire
            return wire
        }
    }

    public func addInputOnlyWire(from wireNames: [WireName]) {

    }
}
