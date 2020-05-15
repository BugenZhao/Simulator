//
//  Execute.swift
//  Y86_64PipeLib
//
//  Created by Bugen Zhao on 5/14/20.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Pipe {
    func addExecute() {
        let w = self.wires

        Eregs = um.addQuadStageRegisterUnit(
            unitName: "Eregs",
            inputWires: [w.Dicode, w.Difun, w.Dstat, w.DvalC, w.dvalA, w.dvalB, w.ddstE, w.ddstM, w.dsrcA, w.dsrcB],
            outputWires: [w.Eicode, w.Eifun, w.Estat, w.EvalC, w.EvalA, w.EvalB, w.EdstE, w.EdstM, w.EsrcA, w.EsrcB],
            controlWires: [w.Ebubble],
            defaultOnRisingWhen: !w.Ebubble.b,
            else: { ru in var ru = ru
                if w.Ebubble.b {
                    ru[0] = I.NOP
                    ru[1] = F.NONE
                    ru[6] = R.NONE
                    ru[7] = R.NONE
                    ru[8] = R.NONE
                    ru[9] = R.NONE
                }
            }
        )

        cc = um.addRegisterUnit(
            unitName: "CC",
            inputWires: [w.setCC, w.zfi, w.sfi, w.ofi],
            outputWires: [w.zfo, w.sfo, w.ofo],
            logic: { ru in
                w.zfo.b = ru[b: 0] == 1
                w.sfo.b = ru[b: 1] == 1
                w.ofo.b = ru[b: 2] == 2
            },
            onRising: { ru in var ru = ru
                if w.setCC.b {
                    ru[b: 0] = w.zfi.b.u64
                    ru[b: 1] = w.sfi.b.u64
                    ru[b: 2] = w.ofi.b.u64
                }
            },
            bytesCount: 3
        )

        _ = um.addGenericUnit(
            unitName: "ALUA",
            inputWires: [w.Eicode, w.EvalA, w.EvalC],
            outputWires: [w.aluA],
            logic: {
                let icode = w.Eicode[0...3]
                if [I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.IADDQ].contains(icode) { w.aluA.v = w.EvalC.v }
                else if [I.RRMOVQ, I.OPQ].contains(icode) { w.aluA.v = w.EvalA.v }
                else if [I.CALL, I.PUSHQ].contains(icode) { w.aluA.v = (-8).nu64 }
                else if [I.RET, I.POPQ].contains(icode) { w.aluA.v = 8 }
            }
        )

        _ = um.addGenericUnit(
            unitName: "ALUB",
            inputWires: [w.Eicode, w.EvalB],
            outputWires: [w.aluB],
            logic: {
                let icode = w.Eicode[0...3]
                if [I.IRMOVQ, I.RRMOVQ].contains(icode) { w.aluB.v = 0 }
                else if [I.RMMOVQ, I.MRMOVQ, I.OPQ, I.CALL, I.RET, I.PUSHQ, I.POPQ, I.IADDQ].contains(icode) { w.aluB.v = w.EvalB.v }
            }
        )

        _ = um.addGenericUnit(
            unitName: "ALUFun",
            inputWires: [w.Eicode, w.Eifun],
            outputWires: [w.aluFun],
            logic: {
                let icode = w.Eicode[0...3]
                if icode == I.OPQ { w.aluFun[0...3] = w.Eifun[0...3] }
                else if icode == I.IADDQ { w.aluFun[0...3] = F.ADD }
                else { w.aluFun[0...3] = F.ADD }
            }
        )

        _ = um.addGenericUnit(
            unitName: "SetCC",
            inputWires: [w.Eicode, w.Eifun, w.Wstat, w.mstat],
            outputWires: [w.setCC],
            logic: {
                if ![S.ADR, S.INS, S.HLT].contains(w.mstat[0...7]), ![S.ADR, S.INS, S.HLT].contains(w.Wstat[0...7]) {
                    let icode = w.Eicode[0...3]
                    let ifun = w.Eifun[0...3]
                    w.setCC.b = (icode == I.OPQ && [F.ADD, F.SUB, F.AND, F.XOR].contains(ifun)) || icode == I.IADDQ
                } else { // exception has occured in MEM or WB !!!
                    w.setCC.b = false
                }
            }
        )

        _ = um.addGenericUnit(
            unitName: "Cond",
            inputWires: [w.Eifun, w.zfo, w.sfo, w.ofo],
            outputWires: [w.econd],
            logic: {
                // for JXX and CMOV
                let ifun = w.Eifun[0...3]
                if ifun == F.JMP { w.econd.b = true }
                else if ifun == F.JLE { w.econd.b = w.zfo.b || (w.sfo.b != w.ofo.b) }
                else if ifun == F.JL { w.econd.b = (w.sfo.b != w.ofo.b) }
                else if ifun == F.JE { w.econd.b = w.zfo.b }
                else if ifun == F.JNE { w.econd.b = !w.zfo.b }
                else if ifun == F.JGE { w.econd.b = (w.sfo.b == w.ofo.b) }
                else if ifun == F.JG { w.econd.b = (!w.zfo.b) && (w.sfo.b == w.ofo.b) }
            }
        )

        _ = um.addGenericUnit(
            unitName: "ALU",
            inputWires: [w.aluA, w.aluB, w.aluFun],
            outputWires: [w.evalE, w.zfi, w.sfi, w.ofi],
            logic: {
                let aluFun = w.aluFun[0...3]
                let a = Int64(bitPattern: w.aluA.v)
                let b = Int64(bitPattern: w.aluB.v)
                var r = Int64(0)

                switch aluFun {
                case F.ADD:
                    r = b &+ a
                    w.zfi.b = r == 0
                    w.sfi.b = r < 0
                    w.ofi.b = ((a < 0) == (b < 0)) && ((r < 0) != (a < 0))
                case F.SUB:
                    r = b &- a
                    w.zfi.b = r == 0
                    w.sfi.b = r < 0
                    w.ofi.b = ((a > 0) == (b < 0)) && ((r < 0) != (b < 0))
                case F.AND:
                    r = b & a
                    w.zfi.b = r == 0
                    w.sfi.b = r < 0
                    w.ofi.b = false
                case F.XOR:
                    r = b ^ a
                    w.zfi.b = r == 0
                    w.sfi.b = r < 0
                    w.ofi.b = false
                default:
                    print("What is \(aluFun)?")
                    break
                }

                w.evalE.v = UInt64(bitPattern: r)
            }
        )

        _ = um.addGenericUnit(
            unitName: "DstE",
            inputWires: [w.Eicode, w.econd, w.EdstE],
            outputWires: [w.edstE],
            logic: {
                // for CMOV
                if w.Eicode[0...3] == I.RRMOVQ, !w.econd.b { w.edstE[0...3] = R.NONE }
                else { w.edstE[0...3] = w.EdstE[0...3] }
            }
        )
    }
}
