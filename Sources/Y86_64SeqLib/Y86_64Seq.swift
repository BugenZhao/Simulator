//
//  Y86_64Seq.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation
import SimulatorLib

public class Y86_64Seq: Machine {
    var um = StaticUnitManager()

    var memory: StaticMemoryUnit?
    var pc: StaticRegisterUnit?
    var register: StaticRegisterUnit?
    var cc: StaticRegisterUnit?
    var stat: StaticRegisterUnit?

    public var halted: Bool {
        get { stat?[b: 0] == S.HLT }
    }

    class WireSet {
        // MARK: Fetch
        let newPC = Wire("newPC")
        let pc = Wire("pc")
        let inst0 = Wire("inst0")
        let inst18 = Wire("inst18")
        let inst29 = Wire("inst29")
        let imemError = Wire("imemError")
        let icode = Wire("icode")
        let ifun = Wire("ifun")
        let instValid = Wire("instValid")
        let needRegIDs = Wire("needRegIDs")
        let needValC = Wire("needValC")
        let valP = Wire("valP")
        let rA = Wire("rA")
        let rB = Wire("rb")
        let valC = Wire("valC")

        // MARK: Decode
        let srcA = Wire("srcA")
        let srcB = Wire("srcB")
        let valA = Wire("valA")
        let valB = Wire("valB")

        // MARK: Execute
        let aluA = Wire("aluA")
        let aluB = Wire("aluB")
        let aluFun = Wire("aluFun")
        let zfi = Wire("zfi")
        let sfi = Wire("sfi")
        let ofi = Wire("ofi")
        let setCC = Wire("setCC")
        let zfo = Wire("zfo")
        let sfo = Wire("sfo")
        let ofo = Wire("ofo")
        let cond = Wire("cond")
        let valE = Wire("valE")

        // MARK: Memory
        let memAddr = Wire("memAddr")
        let memData = Wire("memData")
        let memRead = Wire("memRead")
        let memWrite = Wire("memWrite")
        let dmemError = Wire("dmemError")
        let valM = Wire("valM")
        let halt = Wire("halt")

        // MARK: WriteBack
        let dstE = Wire("dstE")
        let dstM = Wire("dstM")

        // MARK: NewPC
        // No new wires
    }

    var wires = WireSet()

    public func run() {
        printStatus()
        repeat {
            um.clock()
            printStatus()
        } while !halted

        print("System halted")
        memory!.dump(at: 0...0x200)
    }

    convenience public init() {
        self.init(fetch: true, decodeWriteBack: true, execute: true, memory: true, newPC: true)
    }

    init(fetch: Bool = false,
        decodeWriteBack: Bool = false,
        execute: Bool = false,
        memory: Bool = false,
        newPC: Bool = false) {

        if fetch { addFetch() }
        if decodeWriteBack { addDecodeWriteBack() }
        if execute { addExecute() }
        if memory { addMemory() }
        if newPC { addNewPC() }

        _ = um.ready()

        self.memory?.clear()
        self.pc?.clear()
        self.register?.clear()
        self.cc?.clear()
        self.stat?.clear()

//        self.memory!.dump(at: 0...0x1f)
//        self.pc!.dump(at: 0...0x7)
//        self.register!.dump(at: 0...15 * 8 - 1)
//        self.cc!.dump(at: 0...2)
//        print(self.stat![b: 0])
    }

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
}

