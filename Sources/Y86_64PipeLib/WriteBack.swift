//
//  WriteBack.swift
//  Y86_64PipeLib
//
//  Created by Bugen Zhao on 5/14/20.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Pipe {
    func addWriteBack() {
        let w = self.wires

        Wregs = um.addQuadStageRegisterUnit(
            unitName: "Wregs",
            inputWires: [w.Micode, w.Mifun, w.mstat, w.MvalE, w.mvalM, w.MdstE, w.MdstM, w.MsrcA, w.MsrcB],
            outputWires: [w.Wicode, w.Wifun, w.Wstat, w.WvalE, w.WvalM, w.WdstE, w.WdstM, w.WsrcA, w.WsrcB]
        )

        stat = um.addRegisterUnit(
            unitName: "Stat",
            inputWires: [w.Wstat],
            outputWires: [w.halt],
            logic: { ru in
                w.halt.b = ru[b: 0] > S.AOK
            },
            onRising: { ru in var ru = ru
                let stat = w.Wstat[0...7]
                ru[b:0] = stat == S.BUB ? S.AOK : stat
            },
            bytesCount: 1
        )
        
        _ = um.addHaltUnit(
            unitName: "Halt",
            inputWires: [w.halt],
            onlyOnRising: false
        )
    }
}
