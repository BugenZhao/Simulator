//
//  Y86_64Seq.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation
import SimulatorLib
import Y86_64GenericLib

public class Y86_64Seq: Machine, Y86_64System {
    public var um = StaticUnitManager()

    public var memory: StaticMemoryUnit?
    public var pc: StaticRegisterUnit?
    public var register: StaticRegisterUnit?
    public var cc: StaticRegisterUnit?
    public var stat: StaticRegisterUnit?

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
//        printStatus()
        repeat {
            um.clock(resetWire: true)
//            printStatus()
            if self.cc![b: 0] == S.ADR || self.cc![b: 0] == S.INS { fatalError("Exception occured") }
        } while !halted

        print("System halted")
        printStatus()
        memory!.dump(at: 0...0x200)
    }

    required convenience public init() {
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

        reset()
        

//        self.memory!.dump(at: 0...0x1f)
//        self.pc!.dump(at: 0...0x7)
//        self.register!.dump(at: 0...15 * 8 - 1)
//        self.cc!.dump(at: 0...2)
//        print(self.stat![b: 0])
    }
    
    public func reset() {
        self.memory?.clear()
        self.pc?.clear()
        self.register?.clear()
        self.cc?.clear()
        self.stat?.clear()
        
        self.um.resetWires()
    }
}

