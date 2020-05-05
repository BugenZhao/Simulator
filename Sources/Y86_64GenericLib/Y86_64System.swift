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
        let statDesc = S.statDesc(stat: self.stat![b: 0])

        print("Cycle:\t\(um.cycle)")
        print("PC: \t\(String(format: "0x%016llx", pc![0]))")
        print("STAT:\t\(statDesc)")
        print("RAX:\t\(String(format: "0x%016llx %lld", register![R.RAX], register![R.RAX]))")
        print("RCX:\t\(String(format: "0x%016llx %lld", register![R.RCX], register![R.RCX]))")
        print("RDX:\t\(String(format: "0x%016llx %lld", register![R.RDX], register![R.RDX]))")
        print("RBX:\t\(String(format: "0x%016llx %lld", register![R.RBX], register![R.RBX]))")
        print("RSP:\t\(String(format: "0x%016llx %lld", register![R.RSP], register![R.RSP]))")
        print("RBP:\t\(String(format: "0x%016llx %lld", register![R.RBP], register![R.RBP]))")
        print("RSI:\t\(String(format: "0x%016llx %lld", register![R.RSI], register![R.RSI]))")
        print("RDI:\t\(String(format: "0x%016llx %lld", register![R.RDI], register![R.RDI]))")
        print("R8: \t\(String(format: "0x%016llx %lld", register![R.R8], register![R.R8]))")
        print("R9: \t\(String(format: "0x%016llx %lld", register![R.R9], register![R.R9]))")
        print("R10:\t\(String(format: "0x%016llx %lld", register![R.R10], register![R.R10]))")
        print("R11:\t\(String(format: "0x%016llx %lld", register![R.R11], register![R.R11]))")
        print("R12:\t\(String(format: "0x%016llx %lld", register![R.R12], register![R.R12]))")
        print("R13:\t\(String(format: "0x%016llx %lld", register![R.R13], register![R.R13]))")
        print("R14:\t\(String(format: "0x%016llx %lld", register![R.R14], register![R.R14]))")
        print("ZF: \t\(cc![b: 0] != 0)")
        print("SF: \t\(cc![b: 1] != 0)")
        print("OF: \t\(cc![b: 2] != 0)")
        print("\n")
    }

    public var halted: Bool {
        get { um.halted }
    }

    public func run() {
        run(debug: false)
    }
}
