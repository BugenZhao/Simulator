//
//  Y86_64Seq.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation
import SimulatorLib

class Y86_64Seq: Machine {
    var um = UnitManager()

    var imemory: MemoryUnit?
    var dmemory: MemoryUnit?
    var pc: RegisterUnit?
    var register: RegisterUnit?


    func run() {
        um.clock()
        um.clock()
    }

    init() {
        addFetch()

        _ = um.wireManager.examine()
    }
}

