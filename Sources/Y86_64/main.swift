import Y86_64SeqLib
import Y86_64GenericLib
import SimulatorLib
import Foundation

let system: Y86_64System = Y86_64Seq()

#if Xcode
let yo = "/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/asumi.yo"
#else
let yo = FileManager.default.currentDirectoryPath + "/Resources/Objects/asumi.yo"
#endif

system.loadYO(yo)

let time = evaluate {
    system.run()
}
let cycle = system.um.cycle
print("Performance of \(type(of: system)) [\(yo)]: ")
print("\t\(cycle) cycles in \(time) sec, \(Double(cycle) / time) cycles per sec")

/*
system.loadYO("/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/asumr.yo")

for i in 1...1000 {
    system.reset()
    system.loadYO("/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/asumr.yo")
    system.run()

    print(i)
    
    assert(system.pc![0] == 0x14)
    assert(system.register![R.RAX] == 0x0000abcdabcdabcd)
    assert(system.register![R.RCX] == 0)
    assert(system.register![R.RBX] == 0)
    assert(system.register![R.RDX] == 0)
    assert(system.register![R.RSP] == 512)
    assert(system.register![R.RBP] == 0)
    assert(system.register![R.RSI] == 0)
    assert(system.register![R.RDI] == 56)
    assert(system.register![R.R8] == 0)
    assert(system.register![R.R9] == 0)
    assert(system.register![R.R10] == 8)
    assert(system.register![R.R11] == 0)
    assert(system.register![R.R12] == 0)
    assert(system.register![R.R13] == 0)
    assert(system.register![R.R14] == 0)
    assert(system.cc![b: 0] == 0)
    assert(system.cc![b: 1] == 0)
    assert(system.cc![b: 2] == 0)
}
*/
