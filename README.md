# Simulator

![Language](https://img.shields.io/badge/Language-Swift%205.2-orange.svg)

Bugen's logic-circuit-level CPU Simulator, in a description manner. (WIP)

## Example
An overkill example of a *Max Machine*, that is, `out = max(a, b)`, is shown below:

```swift
unitManager.addOutputUnit(
    unitName: "a",
    outputWires: ["wa"],
    outputValue: a
)
unitManager.addOutputUnit(
    unitName: "b",
    outputWires: ["wb"],
    outputValue: b
)
unitManager.addGenericUnit(
    unitName: "logical_comparator",
    inputWires: ["wa", "wb"],
    outputWires: ["wselect"],
    logic: { wm in
        wm.wselect.b = wm.wa.v < wm.wb.v
    }
)
unitManager.addGenericUnit(
    unitName: "mux",
    inputWires: ["wa", "wb", "wselect"],
    outputWires: ["wout"],
    logic: { wm in
        wm.wout.v = wm.wselect.b ? wm.wb.v : wm.wa.v
    }
)
unitManager.clock()
```
## Build and Run
This project is built with *Swift Package Manager*, to run the simulator, just run:

```bash
swift run
```
