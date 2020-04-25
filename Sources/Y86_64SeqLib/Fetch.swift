//
//  Fetch.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Seq {
    func addFetch() {
        let w = self.wires

        pc = um.addRegisterUnit(
            unitName: "PC",
            inputWires: [w.newPC],
            outputWires: [w.pc],
            logic: { ru in
                // PC
                w.pc.v = ru[0]
            },
            onRising: { ru in var ru = ru
                // update PC
                ru[0] = w.newPC.v
            },
            bytesCount: 8
        )

        memory = um.addMemoryUnit(
            unitName: "Memory",
            inputWires: [w.pc,
                w.memAddr, w.memData, w.memWrite, w.memRead],
            outputWires: [w.inst0, w.inst18, w.inst29,
                w.valM,
                w.imemError, w.dmemError],
            logic: { mu in
                // Instruction
                let iAddr = w.pc.v
                let inst0 = mu[sb: iAddr]
                let inst18 = mu[sq: iAddr + 1]
                let inst29 = mu[sq: iAddr + 2]
                w.inst0[0...7] = inst0 ?? 0
                w.inst18.v = inst18 ?? 0
                w.inst29.v = inst29 ?? 0

                w.imemError.b = inst0 == nil || inst18 == nil || inst29 == nil

                // Data
                if w.memRead.b {
                    let valM = mu[sq: w.memAddr.v]
                    w.valM.v = valM ?? 0
                    w.dmemError.b = valM == nil
                } else {
                    w.dmemError.b = false
                }
            },
            onRising: { mu in var mu = mu
                if w.memWrite.b { mu[q: w.memAddr.v] = w.memData.v /* unsafe */}
            },
            bytesCount: 16 * 1024 * 1024
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
