//
//  Y86_64Seq.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation
import SimulatorLib

public class Y86_64Seq: Machine {
    var um = UnitManager()

    var imemory: MemoryUnit?
    var dmemory: MemoryUnit?
    var pc: RegisterUnit?
    var register: RegisterUnit?


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

