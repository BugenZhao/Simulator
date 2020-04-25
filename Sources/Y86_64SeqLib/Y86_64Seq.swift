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
        
        // MARK: Execute
        
        // MARK: Memory
        
        // MARK: WriteBack
        
    }
    
    var wires = WireSet()

    public func run() {
        um.clock()
        um.clock()
    }

    public init() {
        addFetch()

        _ = um.wireManager.examine()
    }

    init(fetch: Bool = false, decode: Bool = false, execute: Bool = false, memory: Bool = false, writeBack: Bool = false) {
        if fetch { addFetch() }

        _ = um.wireManager.examine()
    }
}

