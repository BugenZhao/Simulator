//
//  Execute.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Seq {
    func addExecute() {
        let w = self.wires

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
            inputWires: [w.icode, w.valA, w.valC],
            outputWires: [w.aluA],
            logic: {
                let icode = w.icode[0...3]
                if [I.IRMOVQ, I.RMMOVQ, I.MRMOVQ, I.IADDQ].contains(icode) { w.aluA.v = w.valC.v }
                else if [I.RRMOVQ, I.OPQ].contains(icode) { w.aluA.v = w.valA.v }
                else if [I.CALL, I.PUSHQ].contains(icode) { w.aluA.v = (-8).nu64 }
                else if [I.RET, I.POPQ].contains(icode) { w.aluA.v = 8 }
            }
        )

        _ = um.addGenericUnit(
            unitName: "ALUB",
            inputWires: [w.icode, w.valB],
            outputWires: [w.aluB],
            logic: {
                let icode = w.icode[0...3]
                if [I.IRMOVQ, I.RRMOVQ].contains(icode) { w.aluB.v = 0 }
                else if [I.RMMOVQ, I.MRMOVQ, I.OPQ, I.CALL, I.RET, I.PUSHQ, I.POPQ, I.IADDQ].contains(icode) { w.aluB.v = w.valB.v }
            }
        )

        _ = um.addGenericUnit(
            unitName: "ALUFun",
            inputWires: [w.icode, w.ifun],
            outputWires: [w.aluFun],
            logic: {
                let icode = w.icode[0...3]
                if icode == I.OPQ { w.aluFun[0...3] = w.ifun[0...3] }
                else if icode == I.IADDQ { w.aluFun[0...3] = F.ADD }
                else { w.aluFun[0...3] = F.ADD }
            }
        )

        _ = um.addGenericUnit(
            unitName: "SetCC",
            inputWires: [w.icode],
            outputWires: [w.setCC],
            logic: {
                let icode = w.icode[0...3]
                w.setCC.b = icode == I.OPQ || icode == I.IADDQ
            }
        )

        _ = um.addGenericUnit(
            unitName: "Cond",
            inputWires: [w.ifun, w.zfo, w.sfo, w.ofo],
            outputWires: [w.cond],
            logic: {
                let ifun = w.ifun[0...3]
                if ifun == F.JMP { w.cond.b = true }
                else if ifun == F.JLE { w.cond.b = w.zfo.b || (w.sfo.b != w.ofo.b) }
                else if ifun == F.JL { w.cond.b = (w.sfo.b != w.ofo.b) }
                else if ifun == F.JE { w.cond.b = w.zfo.b }
                else if ifun == F.JNE { w.cond.b = !w.zfo.b }
                else if ifun == F.JGE { w.cond.b = (w.sfo.b == w.ofo.b) }
                else if ifun == F.JG { w.cond.b = (!w.zfo.b) && (w.sfo.b == w.ofo.b) }
            }
        )

        _ = um.addGenericUnit(
            unitName: "ALU",
            inputWires: [w.aluA, w.aluB, w.aluFun],
            outputWires: [w.valE, w.zfi, w.sfi, w.ofi],
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
                    fatalError()
                }

                w.valE.v = UInt64(bitPattern: r)
            }
        )

    }
}
