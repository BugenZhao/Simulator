//
//  Fetch.swift
//  Y86_64PipeLib
//
//  Created by Bugen Zhao on 5/14/20.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Pipe {
    func addFetch() {
        let w = self.wires
        
        // FIXME: fcond !!!

        Fregs = um.addQuadStageRegisterUnit(
            unitName: "Fregs",
            inputWires: [w.fpredPC],
            outputWires: [w.FpredPC]
        )

        memory = um.addMemoryUnit(
            unitName: "Memory",
            inputWires: [w.fpc,
                         /* w.memAddr, w.memData, w.memWrite, w.memRead */ ],
            outputWires: [w.inst0, w.inst18, w.inst29,
                          /* w.valM,
                              w.imemError, w.dmemError*/ ],
            logic: { mu in
                // Instruction
                let iAddr = w.fpc.v
                w.imemError.b = iAddr >= mu.count
                w.inst0[0...7] = iAddr < mu.count ? mu[b: iAddr] : 0
                w.inst18.v = iAddr + 8 < mu.count ? mu[q: iAddr + 1] : 0
                w.inst29.v = iAddr + 9 < mu.count ? mu[q: iAddr + 2] : 0

                /*
                 // Data
                 var dmemError = false
                 if w.memRead.b {
                     dmemError = w.memAddr.v >= mu.count - 7
                     w.valM.v = !dmemError ? mu[q: w.memAddr.v] : 0
                 }
                 if w.memWrite.b {
                     // Only test if error
                     dmemError = w.memAddr.v >= mu.count - 7
                 }
                 w.dmemError.b = dmemError */
            },
            onRising: { mu in var mu = mu
                // Data
                /*
                 if w.memWrite.b {
                     let error = w.memAddr.v >= mu.count - 7
                     if !error {
                         mu[q: w.memAddr.v] = w.memData.v
                     }
                     w.dmemError.b = error
                 } else {
                     w.dmemError.b = false
                 } */
            },
            bytesCount: 16 * 1024 * 1024
        )

        _ = um.addGenericUnit(
            unitName: "Split",
            inputWires: [w.inst0,
                         w.imemError],
            outputWires: [w.ficode, w.fifun,
                          w.instValid, w.needRegIDs, w.needValC],
            logic: {
                // split the instruction
                let icode = w.imemError.b ? I.NOP : w.inst0[4...7]
                let ifun = w.imemError.b ? F.NONE : w.inst0[0...3]
                w.ficode.v = icode
                w.fifun.v = ifun

                // control signals
                w.instValid.b = [I.HALT, I.NOP, I.RRMOVQ, I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.OPQ, I.JXX, I.CALL, I.RET, I.PUSHQ, I.POPQ, I.IADDQ].contains(icode)
                w.needRegIDs.b = [I.RRMOVQ, I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.OPQ, I.PUSHQ, I.POPQ, I.IADDQ].contains(icode)
                w.needValC.b = [I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.JXX, I.CALL, I.IADDQ].contains(icode)
            }
        )

        _ = um.addGenericUnit(
            unitName: "Align",
            inputWires: [w.inst18, w.inst29,
                         w.needRegIDs],
            outputWires: [w.frA, w.frB, w.fvalC],
            logic: {
                if w.needRegIDs.b {
                    // byte 1: two reg IDs
                    w.frA.v = w.inst18[4...7]
                    w.frB.v = w.inst18[0...3]
                    // bute 2...9: valC
                    w.fvalC.v = w.inst29.v
                } else {
                    // no reg IDs
                    w.frA.v = R.NONE
                    w.frB.v = R.NONE
                    // byte 1...8: valC
                    w.fvalC.v = w.inst18.v
                }
            }
        )

        _ = um.addGenericUnit(
            unitName: "PCAdder",
            inputWires: [w.fpc,
                         w.needRegIDs, w.needValC],
            outputWires: [w.fvalP],
            logic: {
                // calculate new PC
                w.fvalP.v = w.fpc.v + 1 + 1 * w.needRegIDs.b.u64 + 8 * w.needValC.b.u64
            }
        )

        _ = um.addGenericUnit(
            unitName: "PCPredictor",
            inputWires: [w.fvalC, w.fvalP, w.ficode],
            outputWires: [w.fpredPC],
            logic: { // always taken
                if [I.JXX, I.CALL].contains(w.ficode.v) { w.fpredPC.v = w.fvalC.v }
                else { w.fpredPC.v = w.fvalP.v }
            }
        )

        _ = um.addGenericUnit(
            unitName: "PCSelector",
            inputWires: [w.fvalC, w.fvalP, w.ficode],
            outputWires: [w.fpredPC],
            logic: {
                if w.Micode.v == I.JXX, !w.Mcond.b { w.fpc.v = w.MvalA.v } // mispredicted always taken
                else if w.Wicode.v == I.RET { w.fpc.v = w.WvalM.v } // `ret`
                else { w.fpc.v = w.FpredPC.v }
            }
        )
    }
}
