//
//  Accumulator.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/23.
//

import Foundation
import SimulatorLib

class Accumulator: Machine {
    public var unitManager = UnitManager()

    public func run() {
        repeat {
            unitManager.clock()
        } while !unitManager.halted
    }

    public init(_ range: ClosedRange<UInt64>) {
        unitManager.addRegisterUnit(
            unitName: "PC",
            inputWires: ["wpcin"],
            outputWires: ["wpcout"],
            logic: { wm, ru in wm.wpcout[0...31] = ru[l: 0] },
            onRising: { wm, ru in
                var ru = ru
                ru[l: 0] = wm.wpcin[0...31]
            },
            bytesCount: 4
        )
        unitManager.addMemoryUnit(
            unitName: "memory",
            inputWires: ["wpcout"],
            outputWires: ["wmem"],
            logic: { wm, mu in
                let addr = wm.wpcout[0...31]
                wm.wmem[0...63] = mu[q: addr]
            },
            onRising: { _, _ in return },
            bytesCount: 8 * (range.count + 10)
        )
        unitManager.addGenericUnit(
            unitName: "pcadder",
            inputWires: ["wpcout"],
            outputWires: ["wpcin"],
            logic: { wm in
                wm.wpcin[0...31] = wm.wpcout[0...31] + 8
            }
        )
        unitManager.addGenericUnit(
            unitName: "adder",
            inputWires: ["wadderin", "wans"],
            outputWires: ["wadder"],
            logic: { wm in
                wm.wadder[0...63] = wm.wadderin[0...63] + wm.wans[0...63]
            }
        )
        unitManager.addGenericUnit(
            unitName: "isnot0",
            inputWires: ["wmem"],
            outputWires: ["whalt", "wadderin"],
            logic: { wm in
                let cond = wm.wmem[0...63] == ~0.u64
                wm.whalt.b = cond
                wm.wadderin[0...63] = cond ? 0 : wm.wmem[0...63]
            }
        )
        unitManager.addRegisterUnit(
            unitName: "ANS",
            inputWires: ["wadder"],
            outputWires: ["wans"],
            logic: { wm, ru in wm.wans[0...31] = ru[q: 0] },
            onRising: { wm, ru in
                var ru = ru
                ru[q: 0] = wm.wadder[0...63]
            },
            bytesCount: 8
        )
        unitManager.addPrinterUnit(
            unitName: "printer",
            inputWires: ["wans"]
        )
        unitManager.addHaltUnit(
            unitName: "halt",
            inputWires: ["whalt"]
        )

        _ = unitManager.wireManager.examine()

        var memory = unitManager.memory as! MemoryUnit
        for (addr, data) in zip(0..<range.count.u64, range) {
            memory[q: addr * 8] = data
        }
        memory[q: range.count.u64 * 8] = ~0.u64
    }
}
