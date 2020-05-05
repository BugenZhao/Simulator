import Y86_64SeqLib
import Y86_64GenericLib
import SimulatorLib
import Foundation

let system: Y86_64System = Y86_64Seq()

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
