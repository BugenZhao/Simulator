//
//  Y86_64System.swift
//  Y86_64GenericLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation
import SimulatorLib

public protocol Y86_64System {
    var um: StaticUnitManager { get }

    var memory: StaticMemoryUnit? { get }
    var pc: StaticRegisterUnit? { get }
    var register: StaticRegisterUnit? { get }
    var cc: StaticRegisterUnit? { get }
    var stat: StaticRegisterUnit? { get }

    var halted: Bool { get }

    func run()
    func printStatus()

    func loadYO(_: String)

    init()
}
