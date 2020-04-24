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

    var range: ClosedRange<UInt64>
    var ans: RegisterUnit

    public func run() {
        let time = evaluate {
            repeat {
                unitManager.clock()
            } while !unitManager.halted
            print("Sum of \(range) is \(ans[q: 0])")
        }
        let cycle = unitManager.cycle
        print("Performance of \(type(of: self)): ")
        print("\t\(cycle) cycles in \(time) sec, \(Double(cycle) / time) cycles per sec")
    }

    public init(_ range: ClosedRange<UInt64>) {
        self.range = range

        _ = unitManager.addRegisterUnit(
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
        var memory = unitManager.addMemoryUnit(
            unitName: "memory",
            inputWires: ["wpcout"],
            outputWires: ["wmem"],
            logic: { wm, mu in
                let addr = wm.wpcout[0...31]
                wm.wmem.v = mu[q: addr]
            },
            onRising: { _, _ in return },
            bytesCount: 8 * (range.count + 10)
        )
        _ = unitManager.addGenericUnit(
            unitName: "pcadder",
            inputWires: ["wpcout"],
            outputWires: ["wpcin"],
            logic: { wm in
                wm.wpcin[0...31] = wm.wpcout[0...31] + 8
            }
        )
        _ = unitManager.addGenericUnit(
            unitName: "adder",
            inputWires: ["wadderin", "wans"],
            outputWires: ["wadder"],
            logic: { wm in
                wm.wadder.v = wm.wadderin.v + wm.wans.v
            }
        )
        _ = unitManager.addGenericUnit(
            unitName: "isnot0",
            inputWires: ["wmem"],
            outputWires: ["whalt", "wadderin"],
            logic: { wm in
                let cond = wm.wmem.v == ~0.u64
                wm.whalt.b = cond
                wm.wadderin.v = cond ? 0 : wm.wmem.v
            }
        )
        ans = unitManager.addRegisterUnit(
            unitName: "ANS",
            inputWires: ["wadder"],
            outputWires: ["wans"],
            logic: { wm, ru in wm.wans.v = ru[q: 0] },
            onRising: { wm, ru in
                var ru = ru
                ru[q: 0] = wm.wadder.v
            },
            bytesCount: 8
        )
        _ = unitManager.addHaltUnit(
            unitName: "halt",
            inputWires: ["whalt"]
        )

        _ = unitManager.wireManager.examine()


        for (addr, data) in zip(0..<range.count.u64, range) {
            memory[q: addr * 8] = data
        }
        memory[q: range.count.u64 * 8] = ~0.u64
    }
}
