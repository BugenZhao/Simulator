//
//  Memory.swift
//  Y86_64PipeLib
//
//  Created by Bugen Zhao on 5/14/20.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Pipe {
    func addMemory() {
        let w = self.wires

        Mregs = um.addQuadStageRegisterUnit(
            unitName: "Mregs",
            inputWires: [w.Eicode, w.Eifun, w.Estat, w.econd, w.evalE, w.EvalA, w.edstE, w.EdstM, w.EsrcA, w.EsrcB],
            outputWires: [w.Micode, w.Mifun, w.Mstat, w.Mcond, w.MvalE, w.MvalA, w.MdstE, w.MdstM, w.MsrcA, w.MsrcB],
            controlWires: [w.Mbubble],
            defaultOnRisingWhen: !w.Mbubble.b,
            else: { ru in var ru = ru
                if w.Mbubble.b {
                    ru[0] = I.NOP
                    ru[1] = F.NONE
                    ru[6] = R.NONE
                    ru[7] = R.NONE
                    ru[8] = R.NONE
                    ru[9] = R.NONE
                }
            }
        )

        _ = um.addGenericUnit(
            unitName: "MStat",
            inputWires: [w.Mstat, w.dmemError],
            outputWires: [w.mstat],
            logic: {
                w.mstat[0...7] = w.dmemError.b ? S.ADR : w.Mstat[0...7]
            }
        )

        _ = um.addGenericUnit(
            unitName: "MemAddr",
            inputWires: [w.Micode, w.MvalE, w.MvalA],
            outputWires: [w.memAddr],
            logic: {
                let icode = w.Micode[0...3]
                if [I.POPQ, I.RET].contains(icode) { w.memAddr.v = w.MvalA.v }
                else if [I.MRMOVQ, I.RMMOVQ, I.PUSHQ, I.CALL].contains(icode) { w.memAddr.v = w.MvalE.v }
            }
        )

        _ = um.addGenericUnit(
            unitName: "MemData",
            inputWires: [w.MvalA],
            outputWires: [w.memData],
            logic: {
                w.memData.v = w.MvalA.v
            }
        )

        _ = um.addGenericUnit(
            unitName: "MemControl",
            inputWires: [w.Micode],
            outputWires: [w.memRead, w.memWrite],
            logic: {
                let icode = w.Micode[0...3]
                if [I.RMMOVQ, I.PUSHQ, I.CALL].contains(icode) { w.memWrite.b = true; w.memRead.b = false }
                else if [I.MRMOVQ, I.POPQ, I.RET].contains(icode) { w.memWrite.b = false; w.memRead.b = true }
                else { w.memWrite.b = false; w.memRead.b = false }
            }
        )
    }
}
