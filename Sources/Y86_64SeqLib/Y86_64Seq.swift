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

    var imemory: StaticMemoryUnit?
    var dmemory: StaticMemoryUnit?
    var pc: StaticRegisterUnit?
    var register: StaticRegisterUnit?

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

        // MARK: Memory

        // MARK: WriteBack
        let dstE = Wire("dstE")
        let dstM = Wire("dstM")
        let valM = Wire("valM")
        let valE = Wire("valE")

        // MARK: NewPC

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

        _ = um.examine()
    }
}

