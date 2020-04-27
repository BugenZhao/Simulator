//
//  StaticUnit.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

protocol StaticUnit {
    var name: UnitName { get }
    var inputWires: [Wire] { get }
    var outputWires: [Wire] { get }

    var logic: () -> Void { get }
    var onRising: () -> Void { get }
}
