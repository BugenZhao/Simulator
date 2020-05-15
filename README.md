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

### Notes on Y86-64 Testing

```bash
swift test
```

- In order to test the correctness of the implementations of the Y86-64 simulators, I ported *YIS*, the instruction-level simulator provided by *CS:APP 3e*, and wrapped it in Swift. There may be a stack overflow bug during the Swift-C interoperation when we run it through SwiftPM, which has been roughly resolved by using global variables instead. For more details, check [CYis](Sources/CYis) and [YisWrapper](Sources/YisWrapper).
- The tester in *CS:APP 3e*'s architecture lab yields **~950** cases to test the correctness, including the `iadd` extension instruction. Actually, there are some bugs in the cases testing the pipeline control combinations, since the tester may inherit the code from *2e*, and generate Y86-64 objects with incorrect instruction length assumptions, resulting in some overlap between data and instructions which may not be expected and make no sense on testing the pipeline control combinations. 
All objects at [Resources/Objects/ISA](Resources/Objects/ISA) have been fixed to correct behaviors, and both Seq and Pipe simulators have passed them all.

## Design

### SimulatorLib

The logic circuit behaves quite differently from the general imperative programming paradigm. In programming, we organize the workflow sequentially, that is, we tell the machine to do one thing first, another next, and then finally another. In a logic circuit with tens of units and hundreds of wires, however, the procedures may be difficult to organize into topological order. Thus, the best and most general way for us to do simulation is to **express the logic in a natural and descriptive manner**, and solve it by a corresponding library.

To create such a library firstly, I abstract the logic circuit into two basic types: ***Wire*** and ***Unit***. 

[*Wire*](Sources/SimulatorLib/Wires/Wire.swift) is a simple object with a temporary value, representing the signals on it currently. Thanks to the Swift's powerful features like ranges, extensions, custom subscripts, and computed properties, we can read and write the wires in a fairly natural way.

```swift
let wire = Wire("foo")
wire.v = 0b1010_0101
wire[0...3] 					// 0b0101
wire[0] = 0
wire.b      					// false
```

[*Unit*](Sources/SimulatorLib/Units/Static/) is the entity that performs arithmetic and logical computations. The behaviors of different units may vary a lot, but they all follow the [***protocol***](Sources/SimulatorLib/Units/Static/StaticUnit.swift) that, they can calculate the corresponding output based on their input signals in general time, and as the clock rises, they may change the state latched in themselves, depending on the input signal at that moment. 

For better reuse of code, I make *Unit* a protocol and derive a series of unit types with some default behaviors, like `GenericUnit` and `RegisterUnit`. Besides, to separate the logic of different machines from the *SimulatorLib*, I create a [*UnitManager*](Sources/SimulatorLib/Units/Static/StaticUnitManager.swift) class and **represent the logic code as `@escaping` closures**. Here's an example of the CC register, where `ru` will represent `cc` itself when the closure is called.

```swift
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
```

After we succeed in representing the logic, how can *SimulatorLib* run and compute the whole circuits? One possible approach is to perform evaluation in a reversed sequence by using *lazy* variables or computed properties, with a somewhat *FP* style. Here I take another intuitive approach, that is, **to simulate the parallel propagation of signals by repeatedly calling their logic code until they're all stable, and then rise the clock**. Thus, I also create a [*WireManager*](Sources/SimulatorLib/Wires/Static/StaticWireManager.swift) to manage a set of wires and check the stability by making checkpoints. 

Here's some code snippets from [*UnitManager*](Sources/SimulatorLib/Units/Static/StaticUnitManager.swift), as you can guess, the core of any machine or simulator.

```swift
func stablize() {
    repeat {
        guard !halted else { return }
        units.forEach { $0.logic() }
    } while (wireManager.doCheckpoint() == false) // false => status changed
}

func rise() {
    guard !halted else { return }
    units.forEach { $0.onRising() }
    wireManager.clearCheckpoint()
}

public func clock() {
    stablize()
    rise()
    cycle += 1
}
```

### Y86-64 Simulator

After the construction of *SimulatorLib*, it is quite easy now to create a Y86-64 simulator based on it. First, I make a [*Y86_64GenericLib*](Sources/Y86_64GenericLib) module, where I define some constants of Y86-64 ISA and make a protocol named `Y86_64System` with necessary properties like `memory`, `register`, `pc`, `cc`, and `stat`, as well as an object loader. Within every *Y86_64System*, there must also be a set of wires, which can be up to 100 in the pipeline version. 

Next, we just need to write the logic of each unit very *happily*, one stage after another. Here's an example of  the pipeline control unit. As you can see, because we can pass closures as the logic code, we can also make some temporary variables within it and make the logic *much clearer*.

```swift
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
        let loadAndUse = [I.MRMOVQ, I.POPQ].contains(w.Eicode[0...3]) &&
                         [w.dsrcA[0...3], w.dsrcB[0...3]].contains(w.EdstM[0...3])
        let mispredicted = w.Eicode[0...3] == I.JXX && !w.econd.b

        let WException = [S.ADR, S.INS, S.HLT].contains(w.Wstat[0...7])
        let mException = [S.ADR, S.INS, S.HLT].contains(w.mstat[0...7])

        w.Fstall.b = ret || loadAndUse
        w.Dstall.b = loadAndUse
        w.Wstall.b = WException // avoid next WB if exception has occurred

        w.Dbubble.b = mispredicted || (ret && !loadAndUse)
        w.Ebubble.b = mispredicted || loadAndUse
        w.Mbubble.b = WException || mException // avoid next MEM if exception has occurred
    }
)
```

The majority of designs for both *Seq* and *Pipe* are based on the HCL of *CS:APP 3e*. However, all units have the same place in our design, from the PC predictor to ALU, which becomes **a good playground for us to add, modify, and practice some designs of *Computer Architecture*.**

Besides, I also wrap *YIS*, the instruction-level simulator for Y86-64, into the project and fix some bugs in order to make a comprehensive comparison test for *Seq* and *Pipe*. Except for the different definitions on PC register, both simulators have passed the [*~1000 test cases*](Resources/Objects).

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
