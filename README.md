# Simulator

![Language](https://img.shields.io/badge/Language-Swift%205.2-orange.svg)
![Simulator](https://github.com/BugenZhao/Simulator/workflows/Simulator/badge.svg)
![SimulatorLib](https://github.com/BugenZhao/Simulator/workflows/SimulatorLib/badge.svg)
![Y86_64Seq](https://github.com/BugenZhao/Simulator/workflows/Y86_64Seq/badge.svg)
![Y86_64Pipe](https://github.com/BugenZhao/Simulator/workflows/Y86_64Pipe/badge.svg)

Bugen's logic-circuit-level CPU Simulator, in a descriptive manner.

  ![Y86_64Seq](Resources/Y86_64Seq.png)

## CPU Simulation

- [x] *CS:APP* Y86-64 Seq ([Sources](Sources/Y86_64SeqLib)) ([Design](Resources/Y86_64SeqDesign.pdf)) *[ISA tests passed]*

- [x] *CS:APP* Y86-64 Pipe ([Sources](Sources/Y86_64PipeLib)) ([Design](Resources/Y86_64PipeDesign.pdf)) *[ISA tests passed]*

- [ ] ...

### Notes

- In order to test the correctness of the implementations of the Y86-64 simulators, I ported *YIS*, the instruction-level simulator provided by *CS:APP 3e*, and wrapped it in Swift. There may be a stack overflow bug during the Swift-C interoperation when we run it through SwiftPM, which has been roughly resolved by using global variables instead. For more details, check [CYis](Sources/CYis) and [YisWrapper](Sources/YisWrapper).
- The tester in *CS:APP 3e*'s architecture lab yields **~950** cases to test the correctness, including the `iadd` extension instruction. Actually, there are some bugs in the cases testing the pipeline control combinations, since the tester may inherit the code from *2e*, and generate Y86-64 objects with incorrect instruction length assumptions, resulting in some overlap between data and instructions which may not be expected and make no sense on testing the pipeline control combinations. 
All objects at [Resources/Objects/ISA](Resources/Objects/ISA) have been fixed to correct behaviors. And both Seq and Pipe simulators have passed them all.

  

## Get Started
An example of Accumulator is shown below, check [here](Sources/Simulator/Examples/Accumulator.swift) for more details.

![Accumulator Circuit](Resources/accumulator.png)



```swift
import Foundation
import SimulatorLib

class Accumulator: Machine {
    ...
    
    public init(_ range: ClosedRange<UInt64>) {
        self.range = range
        
        // Get a set of wires
        let w = self.wires

        // Add units
        _ = unitManager.addRegisterUnit(
            unitName: "PC",
            inputWires: [w.pcin],
            outputWires: [w.pcout],
            logic: { ru in w.pcout[0...31] = ru[l: 0] },
            onRising: { ru in var ru = ru
                ru[l: 0] = w.pcin[0...31]
            },
            bytesCount: 4
        )
        memory = unitManager.addMemoryUnit(
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
            logic: { ru in w.ans.v = ru[q: 0] },
            onRising: { ru in var ru = ru
                ru[q: 0] = w.adder.v
            },
            bytesCount: 8
        )
        _ = unitManager.addHaltUnit(
            unitName: "halt",
            inputWires: [w.halt]
        )

        // Check if there's any illegal wire
        _ = unitManager.ready()

        // Fill the input range into memory
        for (addr, data) in zip(0..<range.count.u64, range) {
            memory[addr] = data
        }
        
        // End flag: ~0
        memory[range.count.u64] = ~0.u64
    }
}


let accumulator = Accumulator(0...100000.u64)
accumulator.run()
```

```
Sum of 0...100000 is 5000050000
Performance of Accumulator:
    100002 cycles in 0.44538172 sec, 224530.9933241086 cycles per sec
```


## Build and Run
This project is built with *Swift Package Manager*, to run the simulator, simply execute:

```bash
swift run -c release Simulator
swift run -c release Y86_64
```

## Copyleft

**BugenZhao, Apr. 2020**
