//
//  Unit.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public typealias UnitName = String

protocol Unit {
    var name: UnitName { get }
    var inputWires: [WireName] { get }
    var outputWires: [WireName] { get }

    var logic: (WireManager) -> Void { get }
    var onRising: (WireManager) -> Void { get }
}
