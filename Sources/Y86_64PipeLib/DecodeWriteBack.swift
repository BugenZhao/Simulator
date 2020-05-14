//
//  DecodeWriteBack.swift
//  Y86_64PipeLib
//
//  Created by Bugen Zhao on 5/14/20.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Pipe {
    func addDecodeWriteBack() {
        let w = self.wires

        register = um.addRegisterUnit(
            unitName: "Register",
            inputWires: [w.dsrcA, w.dsrcB, w.dstE, w.dstM, w.mvalM, w.evalE],
            outputWires: [w.dvalA, w.dvalB],
            logic: { ru in
                // decode
                w.dvalA.v = ru[w.dsrcA[0...3]]
                w.dvalB.v = ru[w.dsrcB[0...3]]
            },
            onRising: { ru in var ru = ru
                // writeback
                let e = w.dstE[0...3]
                let m = w.dstM[0...3]
                if e != R.NONE { ru[e] = w.evalE.v }
                if m != R.NONE { ru[m] = w.mvalM.v }
            },
            bytesCount: 8 * 16 // ru[15] is always 0
        )

        _ = um.addGenericUnit(unitName: "A", inputWires: [w.icode, w.rA], outputWires: [w.srcA], logic: {
                let icode = w.icode[0...3]
                if [I.RRMOVQ, I.RMMOVQ, I.OPQ, I.PUSHQ].contains(icode) { w.srcA[0...3] = w.rA[0...3] }
                else if [I.RET, I.POPQ].contains(icode) { w.srcA[0...3] = R.RSP }
                else { w.srcA[0...3] = R.NONE }
            })

        _ = um.addGenericUnit(unitName: "B", inputWires: [w.icode, w.rB], outputWires: [w.srcB], logic: {
                let icode = w.icode[0...3]
                if [I.RMMOVQ, I.MRMOVQ, I.OPQ, I.IADDQ].contains(icode) { w.srcB[0...3] = w.rB[0...3] }
                else if [I.CALL, I.RET, I.PUSHQ, I.POPQ].contains(icode) { w.srcB[0...3] = R.RSP }
                else { w.srcB[0...3] = R.NONE }
            })

        _ = um.addGenericUnit(unitName: "E", inputWires: [w.icode, w.rB, w.cond], outputWires: [w.dstE], logic: {
                let icode = w.icode[0...3]

                if icode == I.RRMOVQ && w.cond.b {
                    // RRMOVQ <=> ifun == JMP <=> w.cond.b == true
                    // CMOVXX <=> ifun == JXX
                    w.dstE[0...3] = w.rB[0...3]
                } else if [I.IRMOVQ, I.OPQ, I.IADDQ].contains(icode) {
                    w.dstE[0...3] = w.rB[0...3]
                } else if [I.CALL, I.RET, I.PUSHQ, I.POPQ].contains(icode) {
                    w.dstE[0...3] = R.RSP
                } else {
                    w.dstE[0...3] = R.NONE
                }
            })

        _ = um.addGenericUnit(unitName: "M", inputWires: [w.icode, w.rA], outputWires: [w.dstM], logic: {
                let icode = w.icode[0...3]
                if [I.MRMOVQ, I.POPQ].contains(icode) { w.dstM[0...3] = w.rA[0...3] }
                else { w.dstM[0...3] = R.NONE }
            })
    }
}
