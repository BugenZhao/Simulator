//
//  Control.swift
//  Y86_64PipeLib
//
//  Created by Bugen Zhao on 5/14/20.
//

import Foundation
import Y86_64GenericLib

extension Y86_64Pipe {
    func addControl() {
        let w = self.wires

        _ = um.addGenericUnit(
            unitName: "Control",
            inputWires: [w.Dicode, w.Eicode, w.Micode,
                         w.dsrcA, w.dsrcB, w.EdstM,
                         w.econd,
                         w.Wstat, w.mstat],
            outputWires: [w.Fstall, w.Dstall, w.Wstall,
                          w.Dbubble, w.Ebubble, w.Mbubble],
            logic: {
                let ret = [w.Dicode[0...3], w.Eicode[0...3], w.Micode[0...3]].contains(I.RET)
                let loadAndUse = [I.MRMOVQ, I.POPQ].contains(w.Eicode[0...3]) && [w.dsrcA[0...3], w.dsrcB[0...3]].contains(w.EdstM[0...3])
                let mispridicted = w.Eicode[0...3] == I.JXX && !w.econd.b

                let WException = [S.ADR, S.INS, S.HLT].contains(w.Wstat[0...7])
                let mException = [S.ADR, S.INS, S.HLT].contains(w.mstat[0...7])

                w.Fstall.b = ret || loadAndUse
                w.Dstall.b = loadAndUse
                w.Wstall.b = WException // avoid next WB if exception has occurred

                w.Dbubble.b = mispridicted || (ret && !loadAndUse)
                w.Ebubble.b = mispridicted || loadAndUse
                w.Mbubble.b = WException || mException // avoid next MEM if exception has occurred
            }
        )
    }
}
