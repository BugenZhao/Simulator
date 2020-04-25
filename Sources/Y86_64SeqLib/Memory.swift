//
//  Memory.swift
//  Y86_64SeqLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Seq {
    func addMemory() {
        let w = self.wires

        stat = um.addRegisterUnit(
            unitName: "Stat",
            inputWires: [w.instValid, w.imemError, w.icode, w.dmemError],
            outputWires: [w.halt],
            logic: { ru in
                w.halt.b = (ru[b: 0] != 0 && ru[b: 0] != S.AOK)
            },
            onRising: { ru in var ru = ru
                if !w.instValid.b { ru[b: 0] = S.INS }
                else if w.imemError.b || w.dmemError.b { ru[b: 0] = S.ADR }
                else if w.icode[0...3] == I.HALT { ru[b: 0] = S.HLT }
                else { ru[b: 0] = S.AOK }
            },
            bytesCount: 1
        )

        _ = um.addHaltUnit(
            unitName: "Halt",
            inputWires: [w.halt]
        )

        _ = um.addGenericUnit(
            unitName: "MemAddr",
            inputWires: [w.icode, w.valE, w.valA],
            outputWires: [w.memAddr],
            logic: {
                let icode = w.icode[0...3]
                if [I.POPQ, I.RET].contains(icode) { w.memAddr.v = w.valA.v }
                else if [I.MRMOVQ, I.RMMOVQ, I.PUSHQ, I.CALL].contains(icode) { w.memAddr.v = w.valE.v }
            }
        )

        _ = um.addGenericUnit(
            unitName: "MemData",
            inputWires: [w.icode, w.valP, w.valA],
            outputWires: [w.memData],
            logic: {
                let icode = w.icode[0...3]
                if [I.RMMOVQ, I.PUSHQ].contains(icode) { w.memData.v = w.valA.v }
                else if [I.CALL].contains(icode) { w.memData.v = w.valP.v }
            }
        )

        _ = um.addGenericUnit(
            unitName: "MemControl",
            inputWires: [w.icode],
            outputWires: [w.memRead, w.memWrite],
            logic: {
                let icode = w.icode[0...3]
                if [I.RMMOVQ, I.PUSHQ, I.CALL].contains(icode) { w.memWrite.b = true; w.memRead.b = false }
                else if [I.MRMOVQ, I.POPQ, I.RET].contains(icode) { w.memWrite.b = false; w.memRead.b = true }
                else { w.memWrite.b = false; w.memRead.b = false }
            }
        )
    }
}
