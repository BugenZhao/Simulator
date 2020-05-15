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

    func run(debug: Bool)
    func reset()
    func printStatus()

    func loadYO(_: String)
}

extension Y86_64System {
    public func printStatus() {
        let statDesc = S.names[Int(self.stat![b: 0])]
        print("Cycle:\(um.cycle), PC: \(String(format: "0x%016llx", pc![0])), STAT: \(statDesc), ZF=\(cc![b: 0]), SF=\(cc![b: 1]), OF=\(cc![b: 2])")
        R.names
            .enumerated()
            .dropLast()
            .forEach { idx, name in print("\(name):\t\(String(format: "0x%016llx %lld", register![idx.u64], register![idx.u64]))") }
        print("\n")
    }

    public var halted: Bool { um.halted }

    public func run() {
        run(debug: false)
    }
}
