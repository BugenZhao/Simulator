//
//  Accumulator.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/23.
//

import Foundation
import SimulatorLib

class Accumulator: Machine {
    public var unitManager = StaticUnitManager()

    var range: ClosedRange<UInt64>
    var ans: StaticRegisterUnit

    struct w {
        static let pcin = Wire("pcin")
        static let pcout = Wire("pcout")
        static let mem = Wire("mem")
        static let adderin = Wire("adderin")
        static let adder = Wire("adder")
        static let ans = Wire("ans")
        static let halt = Wire("halt")
    }

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
            inputWires: [w.pcin],
            outputWires: [w.pcout],
            logic: { ru in w.pcout[0...31] = ru[l: 0] },
            onRising: { ru in
                var ru = ru
                ru[l: 0] = w.pcin[0...31]
            },
            bytesCount: 4
        )
        var memory = unitManager.addMemoryUnit(
            unitName: "memory",
            inputWires: [w.pcout],
            outputWires: [w.mem],
            logic: { mu in
                let addr = w.pcout[0...31]
                w.mem.v = mu[q: addr]
            },
            onRising: { _ in },
            bytesCount: 8 * (range.count + 10)
        )
        _ = unitManager.addGenericUnit(
            unitName: "pcadder",
            inputWires: [w.pcout],
            outputWires: [w.pcin],
            logic: {
                w.pcin[0...31] = w.pcout[0...31] + 8
            }
        )
        _ = unitManager.addGenericUnit(
            unitName: "adder",
            inputWires: [w.adderin, w.ans],
            outputWires: [w.adder],
            logic: {
                w.adder.v = w.adderin.v + w.ans.v
            }
        )
        _ = unitManager.addGenericUnit(
            unitName: "isnot0",
            inputWires: [w.mem],
            outputWires: [w.halt, w.adderin],
            logic: {
                let cond = w.mem.v == ~0.u64
                w.halt.b = cond
                w.adderin.v = cond ? 0 : w.mem.v
            }
        )
        ans = unitManager.addRegisterUnit(
            unitName: "ANS",
            inputWires: [w.adder],
            outputWires: [w.ans],
            logic: {  ru in w.ans.v = ru[q: 0] },
            onRising: { ru in
                var ru = ru
                ru[q: 0] = w.adder.v
            },
            bytesCount: 8
        )
        _ = unitManager.addHaltUnit(
            unitName: "halt",
            inputWires: [w.halt]
        )

        _ = unitManager.ready()


        for (addr, data) in zip(0..<range.count.u64, range) {
            memory[q: addr * 8] = data
        }
        memory[q: range.count.u64 * 8] = ~0.u64

        memory.dump(at: 0...0x100)
    }
}
