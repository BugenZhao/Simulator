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

    subscript(dynamicMember wireName: WireName) -> Wire {
        get {
            if let wire = wires[wireName] { return wire }
            let wire = Wire(name: wireName, value: 0)
            wires[wireName] = wire
            return wire
        }
    }
}
