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

        Dregs = um.addQuadStageRegisterUnit(
            unitName: "Dregs",
            inputWires: [w.ficode, w.fifun, w.fstat, w.fvalC, w.fvalP, w.frA, w.frB],
            outputWires: [w.Dicode, w.Difun, w.Dstat, w.DvalC, w.DvalP, w.DrA, w.DrB],
            controlWires: [w.Dstall, w.Dbubble],
            defaultOnRisingWhen: !w.Dstall.b && !w.Dbubble.b,
            else: { ru in var ru = ru
                if w.Dstall.b { return }
                if w.Dbubble.b {
                    ru[0] = I.NOP
                    ru[1] = F.NONE
                    ru[2] = S.BUB
                    ru[5] = R.NONE
                    ru[6] = R.NONE
                }
            }
        )

        register = um.addRegisterUnit(
            unitName: "Register",
            inputWires: [w.dsrcA, w.dsrcB, w.WdstE, w.WdstM, w.WvalM, w.WvalE],
            outputWires: [w.drvalA, w.drvalB],
            logic: { ru in
                // decode
                w.drvalA.v = ru[w.dsrcA[0...3]]
                w.drvalB.v = ru[w.dsrcB[0...3]]
            },
            onRising: { ru in var ru = ru
                // writeback
                let e = w.WdstE[0...3]
                let m = w.WdstM[0...3]
                if e != R.NONE { ru[e] = w.WvalE.v }
                if m != R.NONE { ru[m] = w.WvalM.v }
            },
            bytesCount: 8 * 16 // ru[15] is always 0
        )

        _ = um.addGenericUnit(unitName: "A", inputWires: [w.Dicode, w.DrA], outputWires: [w.dsrcA], logic: {
            let icode = w.Dicode[0...3]
            if [I.RRMOVQ, I.RMMOVQ, I.OPQ, I.PUSHQ].contains(icode) { w.dsrcA[0...3] = w.DrA[0...3] }
            else if [I.RET, I.POPQ].contains(icode) { w.dsrcA[0...3] = R.RSP }
            else { w.dsrcA[0...3] = R.NONE }
            })

        _ = um.addGenericUnit(unitName: "B", inputWires: [w.Dicode, w.DrB], outputWires: [w.dsrcB], logic: {
            let icode = w.Dicode[0...3]
            if [I.RMMOVQ, I.MRMOVQ, I.OPQ, I.IADDQ].contains(icode) { w.dsrcB[0...3] = w.DrB[0...3] }
            else if [I.CALL, I.RET, I.PUSHQ, I.POPQ].contains(icode) { w.dsrcB[0...3] = R.RSP }
            else { w.dsrcB[0...3] = R.NONE }
            })

        _ = um.addGenericUnit(unitName: "E", inputWires: [w.Dicode, w.DrB], outputWires: [w.ddstE], logic: {
            let icode = w.Dicode[0...3]

            if icode == I.RRMOVQ { // no more cond here
                w.ddstE[0...3] = w.DrB[0...3]
            } else if [I.IRMOVQ, I.OPQ, I.IADDQ].contains(icode) {
                w.ddstE[0...3] = w.DrB[0...3]
            } else if [I.CALL, I.RET, I.PUSHQ, I.POPQ].contains(icode) {
                w.ddstE[0...3] = R.RSP
            } else {
                w.ddstE[0...3] = R.NONE
            }
            })

        _ = um.addGenericUnit(unitName: "M", inputWires: [w.Dicode, w.DrA], outputWires: [w.ddstM], logic: {
            let icode = w.Dicode[0...3]
            if [I.MRMOVQ, I.POPQ].contains(icode) { w.ddstM[0...3] = w.DrA[0...3] }
            else { w.ddstM[0...3] = R.NONE }
            })

        _ = um.addGenericUnit(
            unitName: "SelFwdA",
            inputWires: [w.Dicode, w.dsrcA, w.drvalA, w.DvalP,
                         w.edstE, w.MdstM, w.MdstE, w.WdstM, w.WdstE,
                         w.evalE, w.mvalM, w.MvalE, w.WvalM, w.WvalE],
            outputWires: [w.dvalA],
            logic: {
                let dsrcA = w.dsrcA[0...3]
                if [I.CALL, I.JXX].contains(w.Dicode[0...3]) { // select valP
                    w.dvalA.v = w.DvalP.v
                } else if dsrcA == w.edstE[0...3] { // forward from EX
                    w.dvalA.v = w.evalE.v
                } else if dsrcA == w.MdstM[0...3] { // from MEM, first M
                    w.dvalA.v = w.mvalM.v
                } else if dsrcA == w.MdstE[0...3] { // from MEM, then E => for `popq %rsp`
                    w.dvalA.v = w.MvalE.v
                } else if dsrcA == w.WdstM[0...3] { // from WB
                    w.dvalA.v = w.WvalM.v
                } else if dsrcA == w.WdstE[0...3] { // from WB
                    w.dvalA.v = w.WvalE.v
                } else { // okay
                    w.dvalA.v = w.drvalA.v
                }
            }
        )

        _ = um.addGenericUnit(
            unitName: "FwdB",
            inputWires: [w.dsrcB, w.drvalB,
                         w.edstE, w.MdstM, w.MdstE, w.WdstM, w.WdstE,
                         w.evalE, w.mvalM, w.MvalE, w.WvalM, w.WvalE],
            outputWires: [w.dvalB],
            logic: {
                let dsrcB = w.dsrcB[0...3]
                if dsrcB == w.edstE[0...3] { // forward from EX
                    w.dvalB.v = w.evalE.v
                } else if dsrcB == w.MdstM[0...3] { // from MEM, first M
                    w.dvalB.v = w.mvalM.v
                } else if dsrcB == w.MdstE[0...3] { // from MEM, then E => for `popq %rsp`
                    w.dvalB.v = w.MvalE.v
                } else if dsrcB == w.WdstM[0...3] { // from WB
                    w.dvalB.v = w.WvalM.v
                } else if dsrcB == w.WdstE[0...3] { // from WB
                    w.dvalB.v = w.WvalE.v
                } else { // okay
                    w.dvalB.v = w.drvalB.v
                }
            }
        )
    }
}
