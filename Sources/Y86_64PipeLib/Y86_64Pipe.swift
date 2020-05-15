//
//  Y86_64Pipe.swift
//  Y86_64PipeLib
//
//  Created by Bugen Zhao on 5/14/20.
//

import Foundation
import SimulatorLib
import Y86_64GenericLib

public class Y86_64Pipe: Machine, Y86_64System {
    public var um = StaticUnitManager()

    public var memory: StaticMemoryUnit?
    public var pc: StaticRegisterUnit?
    public var register: StaticRegisterUnit?
    public var cc: StaticRegisterUnit?
    public var stat: StaticRegisterUnit?

    public var Fregs: StaticRegisterUnit?
    public var Dregs: StaticRegisterUnit?
    public var Eregs: StaticRegisterUnit?
    public var Mregs: StaticRegisterUnit?
    public var Wregs: StaticRegisterUnit?

    class WireSet {
        // MARK: Fetch

        let FpredPC = Wire("FpredPC")
        let fpredPC = Wire("fpredPC")
        let fpc = Wire("fpc")

        let inst0 = Wire("inst0")
        let inst18 = Wire("inst18")
        let inst29 = Wire("inst29")
        let imemError = Wire("imemError")
        let instValid = Wire("instValid")
        let needRegIDs = Wire("needRegIDs")
        let needValC = Wire("needValC")

        let ficode = Wire("ficode")
        let fifun = Wire("fifun")
        let fstat = Wire("fstat")
        let frA = Wire("frA")
        let frB = Wire("frB")
        let fvalC = Wire("fvalC")
        let fvalP = Wire("fvalP")

        // MARK: Decode

        let Dicode = Wire("Dicode")
        let Difun = Wire("Difun")
        let Dstat = Wire("Dstat")
        let DrA = Wire("DrA")
        let DrB = Wire("DrB")
        let DvalC = Wire("DvalC")
        let DvalP = Wire("DvalP")

        let dsrcA = Wire("dsrcA")
        let dsrcB = Wire("dsrcB")
        let ddstE = Wire("ddstE")
        let ddstM = Wire("ddstM")

        let drvalA = Wire("drvalA")
        let drvalB = Wire("drvalB")

        let dvalA = Wire("dvalA")
        let dvalB = Wire("dvalB")

        // MARK: Execute

        let Eicode = Wire("Eicode")
        let Eifun = Wire("Eifun")
        let Estat = Wire("Estat")
        let EvalC = Wire("EvalC")
        let EvalA = Wire("EvalA")
        let EvalB = Wire("EvalB")
        let EsrcA = Wire("EsrcA")
        let EsrcB = Wire("EsrcB")
        let EdstE = Wire("EdstE")
        let EdstM = Wire("EdstM")

        let aluA = Wire("aluA")
        let aluB = Wire("aluB")
        let aluFun = Wire("aluFun")
        let zfi = Wire("zfi")
        let sfi = Wire("sfi")
        let ofi = Wire("ofi")
        let zfo = Wire("zfo")
        let sfo = Wire("sfo")
        let ofo = Wire("ofo")

        let econd = Wire("econd")
        let evalE = Wire("evalE")
        let edstE = Wire("edstE")

        // MARK: Memory

        let Micode = Wire("Micode")
        let Mifun = Wire("Mifun")
        let Mstat = Wire("Mstat")
        let Mcond = Wire("Mcond")
        let MvalE = Wire("MvalE")
        let MvalA = Wire("MvalA")
        let MsrcA = Wire("MsrcA")
        let MsrcB = Wire("MsrcB")
        let MdstE = Wire("MdstE")
        let MdstM = Wire("MdstM")

        let memAddr = Wire("memAddr")
        let memData = Wire("memData")
        let memRead = Wire("memRead")
        let memWrite = Wire("memWrite")
        let dmemError = Wire("dmemError")

        let mstat = Wire("mstat")
        let mvalM = Wire("mvalM")

        // MARK: WriteBack

        let Wicode = Wire("Wicode")
        let Wifun = Wire("Wifun")
        let Wstat = Wire("Wstat")
        let WvalE = Wire("WvalE")
        let WvalM = Wire("WvalM")
        let WsrcA = Wire("WsrcA")
        let WsrcB = Wire("WsrcB")
        let WdstE = Wire("WdstE")
        let WdstM = Wire("WdstM")

        let halt = Wire("halt")

        // MARK: Control

        let Fstall = Wire("Fstall")
        let Dstall = Wire("Dstall")
        let Dbubble = Wire("Dbubble")
        let Ebubble = Wire("Ebubble")
        let Mbubble = Wire("Mbubble")
        let Wstall = Wire("Wstall")
        let setCC = Wire("setCC")
    }

    var wires = WireSet()

    public func run(debug: Bool = false) {
        if debug { memory?.dump(at: 0...0xff) }
        repeat {
            um.clock(resetWire: true)
            if debug { printStatus(); memory?.dump(at: 0...0xff); print(">>", terminator: ""); _ = readLine() }
        } while !halted

        print("\(type(of: self)): System halted after \(um.cycle) cycles")
        printStatus()
    }

    public required convenience init() {
        self.init(fetch: true, decodeWriteBack: true, execute: true, memory: true, control: true)
    }

    init(fetch: Bool = false,
         decodeWriteBack: Bool = false,
         execute: Bool = false,
         memory: Bool = false,
         control: Bool = false) {
        if fetch { addFetch() }
        if decodeWriteBack { addDecodeWriteBack(); addWriteBack() }
        if execute { addExecute() }
        if memory { addMemory() }
        if control { addControl() }

        _ = um.ready()

        reset()
    }

    public func reset() {
        self.memory?.clear()
        self.pc?.clear()
        self.register?.clear()
        self.cc?.clear()
        self.stat?.clear()

        self.um.resetWires()

        // Default CC
        self.cc?[b: 0] = 1 // ZF
        self.cc?[b: 1] = 0 // SF
        self.cc?[b: 2] = 0 // OF
    }
}
