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
    var dmemory: StaticMemoryUnit?
    var pc: StaticRegisterUnit?
    var register: StaticRegisterUnit?
    var cc: StaticRegisterUnit?
    var stat: StaticRegisterUnit?

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
        um.clock()
        um.clock()
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

        assert(um.examine() == 0)
    }
}

