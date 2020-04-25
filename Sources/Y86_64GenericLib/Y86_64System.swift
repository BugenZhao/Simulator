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

extension Y86_64System {
    public func printStatus() {
        let statDesc = { () -> String in
            switch self.stat![b: 0] {
            case 0...(S.AOK): return "AOK"
            case S.ADR: return "ADR"
            case S.INS: return "INS"
            case S.HLT: return "HLT"
            default: return "ERR"
            }
        }()

        print("Cycle:\t\(um.cycle)\n")
        print("\tPC: \t\(String(format: "0x%016llx", pc![0]))")
        print("\tSTAT:\t\(statDesc)")
        print("\tRAX:\t\(String(format: "0x%016llx", register![R.RAX]))")
        print("\tRCX:\t\(String(format: "0x%016llx", register![R.RCX]))")
        print("\tRDX:\t\(String(format: "0x%016llx", register![R.RDX]))")
        print("\tRBX:\t\(String(format: "0x%016llx", register![R.RBX]))")
        print("\tRSP:\t\(String(format: "0x%016llx", register![R.RSP]))")
        print("\tRBP:\t\(String(format: "0x%016llx", register![R.RBP]))")
        print("\tRSI:\t\(String(format: "0x%016llx", register![R.RSI]))")
        print("\tRDI:\t\(String(format: "0x%016llx", register![R.RDI]))")
        print("\tR8: \t\(String(format: "0x%016llx", register![R.R8]))")
        print("\tR9: \t\(String(format: "0x%016llx", register![R.R9]))")
        print("\tR10:\t\(String(format: "0x%016llx", register![R.R10]))")
        print("\tR11:\t\(String(format: "0x%016llx", register![R.R11]))")
        print("\tR12:\t\(String(format: "0x%016llx", register![R.R12]))")
        print("\tR13:\t\(String(format: "0x%016llx", register![R.R13]))")
        print("\tR14:\t\(String(format: "0x%016llx", register![R.R14]))")
        print("\tZF: \t\(cc![b: 0] != 0)")
        print("\tSF: \t\(cc![b: 1] != 0)")
        print("\tOF: \t\(cc![b: 2] != 0)")
        print("\n")
    }
    
    public var halted: Bool {
        get { stat?[b: 0] == S.HLT }
    }
}
