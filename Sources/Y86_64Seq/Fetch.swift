//
//  Fetch.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation

extension Y86_64Seq {
    func addFetch() {
        pc = um.addRegisterUnit(
            unitName: "PC",
            inputWires: ["newPC"],
            outputWires: ["pc"],
            logic: { wm, mu in
                // PC
                wm.pc.v = mu[0]
            },
            onRising: { wm, mu in var mu = mu
                // update PC
                mu[0] = wm.newPC.v
            },
            bytesCount: 8
        )

        imemory = um.addMemoryUnit(
            unitName: "Imemory",
            inputWires: ["pc"],
            outputWires: ["inst0", "inst18", "inst29",
                "imemError"],
            logic: { wm, mu in
                // instruction
                let addr = wm.pc.v
                wm.inst0[0...7] = mu[b: addr]
                wm.inst18.v = mu[q: addr + 1]
                wm.inst29.v = mu[q: addr + 2]

                // FIXME: imemError always false now
                wm.imemError.b = false
            },
            onRising: { _, _ in return },
            bytesCount: 0x100000
        )

        _ = um.addGenericUnit(
            unitName: "Split",
            inputWires: ["inst0",
                "imemError"],
            outputWires: ["icode", "ifun",
                "instValid", "needRegIDs", "needValC"],
            logic: { wm in
                // split the instruction
                let icode = wm.imemError.b ? I.NOP : wm.inst0[0...3]
                let ifun = wm.imemError.b ? F.NONE : wm.inst0[4...7]
                wm.icode.v = icode
                wm.ifun.v = ifun

                // control signals
                wm.instValid.b = [I.HALT, I.NOP, I.RRMOVQ, I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.OPQ, I.JXX, I.CALL, I.RET, I.PUSHQ, I.POPQ].contains(icode)
                wm.needRegIDs.b = [I.RRMOVQ, I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.OPQ, I.PUSHQ, I.POPQ].contains(icode)
                wm.needValC.b = [I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.JXX, I.CALL].contains(icode)
            }
        )

        _ = um.addGenericUnit(
            unitName: "Align",
            inputWires: ["inst18", "inst29",
                "needRegIDs"],
            outputWires: ["rA", "rB", "valC"],
            logic: { wm in
                if wm.needRegIDs.b {
                    // byte 1: two reg IDs
                    wm.rA.v = wm.inst18[4...7]
                    wm.rB.v = wm.inst18[0...3]
                    // bute 2...9: valC
                    wm.valC.v = wm.inst29.v
                } else {
                    // no reg IDs
                    wm.rA.v = R.NONE
                    wm.rB.v = R.NONE
                    // byte 1...8: valC
                    wm.valC.v = wm.inst18.v
                }
            }
        )

        _ = um.addGenericUnit(
            unitName: "PCAdder",
            inputWires: ["pc",
                "needRegIDs", "needValC"],
            outputWires: ["valP"],
            logic: { wm in
                // calculate new PC
                wm.valP.v = wm.pc.v + 1 + 1 * wm.needRegIDs.b.u64 + 8 * wm.needValC.b.u64
            }
        )
    }
}
