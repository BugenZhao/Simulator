import Foundation
import SimulatorLib
import Y86_64GenericLib
import Y86_64PipeLib
import Y86_64SeqLib

let system: Y86_64Pipe = Y86_64Pipe()

#if Xcode
let yo = "/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/abs-asum-cmov.yo"
#else
let yo = FileManager.default.currentDirectoryPath + "/Resources/Objects/abs-asum-cmov.yo"
#endif

system.loadYO(yo)

let time = evaluate {
    system.run()
}

let cycle = system.um.cycle
print("Performance of \(type(of: system)) [\(yo)]: ")
print("\t\(cycle) cycles in \(time) sec, \(Double(cycle) / time) cycles per sec")
