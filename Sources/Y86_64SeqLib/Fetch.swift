//
//  Fetch.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation

extension Y86_64Seq {
    func addFetch() {
        let w = self.wires

        pc = um.addRegisterUnit(
            unitName: "PC",
            inputWires: [w.newPC],
            outputWires: [w.pc],
            logic: { mu in
                // PC
                w.pc.v = mu[0]
            },
            onRising: { mu in var mu = mu
                // update PC
                mu[0] = w.newPC.v
            },
            bytesCount: 8
        )

        imemory = um.addMemoryUnit(
            unitName: "Imemory",
            inputWires: [w.pc],
            outputWires: [w.inst0, w.inst18, w.inst29,
                w.imemError],
            logic: { mu in
                // instruction
                let addr = w.pc.v
                w.inst0[0...7] = mu[b: addr]
                w.inst18.v = mu[q: addr + 1]
                w.inst29.v = mu[q: addr + 2]

                // FIXME: imemError always false now
                w.imemError.b = false
            },
            onRising: { _ in },
            bytesCount: 0x100000
        )

        _ = um.addGenericUnit(
            unitName: "Split",
            inputWires: [w.inst0,
                w.imemError],
            outputWires: [w.icode, w.ifun,
                w.instValid, w.needRegIDs, w.needValC],
            logic: {
                // split the instruction
                let icode = w.imemError.b ? I.NOP : w.inst0[4...7]
                let ifun = w.imemError.b ? F.NONE : w.inst0[0...3]
                w.icode.v = icode
                w.ifun.v = ifun

                // control signals
                w.instValid.b = [I.HALT, I.NOP, I.RRMOVQ, I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.OPQ, I.JXX, I.CALL, I.RET, I.PUSHQ, I.POPQ].contains(icode)
                w.needRegIDs.b = [I.RRMOVQ, I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.OPQ, I.PUSHQ, I.POPQ].contains(icode)
                w.needValC.b = [I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.JXX, I.CALL].contains(icode)
            }
        )

        _ = um.addGenericUnit(
            unitName: "Align",
            inputWires: [w.inst18, w.inst29,
                w.needRegIDs],
            outputWires: [w.rA, w.rB, w.valC],
            logic: {
                if w.needRegIDs.b {
                    // byte 1: two reg IDs
                    w.rA.v = w.inst18[4...7]
                    w.rB.v = w.inst18[0...3]
                    // bute 2...9: valC
                    w.valC.v = w.inst29.v
                } else {
                    // no reg IDs
                    w.rA.v = R.NONE
                    w.rB.v = R.NONE
                    // byte 1...8: valC
                    w.valC.v = w.inst18.v
                }
            }
        )

        _ = um.addGenericUnit(
            unitName: "PCAdder",
            inputWires: [w.pc,
                w.needRegIDs, w.needValC],
            outputWires: [w.valP],
            logic: {
                // calculate new PC
                w.valP.v = w.pc.v + 1 + 1 * w.needRegIDs.b.u64 + 8 * w.needValC.b.u64
            }
        )
    }
}
