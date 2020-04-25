//
//  NewPC.swift
//  Y86_64SeqLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Seq {
    func addNewPC() {
        let w = self.wires

        _ = um.addGenericUnit(
            unitName: "NewPC",
            inputWires: [w.icode, w.cond, w.valC, w.valM, w.valP],
            outputWires: [w.newPC],
            logic: {
                let icode = w.icode[0...3]
                if icode == I.CALL { w.newPC.v = w.valC.v }
                else if icode == I.JXX && w.cond.b { w.newPC.v = w.valC.v }
                else if icode == I.RET { w.newPC.v = w.valM.v }
                else { w.newPC.v = w.valP.v }
            }
        )
    }
}
