# Simulator

![Language](https://img.shields.io/badge/Language-Swift%205.2-orange.svg)
![Actions](https://github.com/bugenzhao/Simulator/workflows/Simulator/badge.svg)

Bugen's logic-circuit-level CPU Simulator, in a descriptive manner. (WIP)

## CPU Simulation

- [x] *CS:APP* Y86-64 Seq ([Sources](Sources/Y86_64SeqLib))

  ![Y86_64Seq](Resources/Y86_64Seq.png)

- [ ] *CS:APP* Y86-64 Pipe

- [ ] MIPS for teaching

- [ ] ...

## Get Started
An example of Accumulator is shown below:

![Accumulator Circuit](Resources/accumulator.png)

```swift
var unitManager = StaticUnitManager()
let range = 0...10000.u64   // Input range
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

// Check illegal access
_ = unitManager.ready()

// Fill the input into memory
for (addr, data) in zip(0..<range.count.u64, range) {
    memory[addr] = data
}
// End of input
memory[range.count.u64] = ~0.u64

// Run until halted
repeat {
    unitManager.clock()
} while !unitManager.halted

print("Sum of \(range) is \(ans[0])")
```
## Build and Run
This project is built with *Swift Package Manager*, to run the simulator, simply execute:

```bash
swift run -c release Simulator
swift run -c release Y86_64
```

## Copyleft

**BugenZhao, Apr. 2020**