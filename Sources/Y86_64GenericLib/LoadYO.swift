//
//  LoadYO.swift
//  Y86_64GenericLib
//
//  Created by Bugen Zhao on 2020/4/25.
//

import Foundation

extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
}

public extension Y86_64System {
    func loadYO(_ path: String) {
        let data = try! String(contentsOfFile: path)
        let lines = data.components(separatedBy: .newlines)
        var lastAddr = 0
        lines.forEach { line in
            let tokens = line.split(whereSeparator: { ":|".contains($0) })
            if tokens.count >= 2 && tokens[0].hasPrefix("0x") {
                if let addr = Int(tokens[0].dropFirst(2), radix: 16) {
                    let bytes = String(tokens[1]).trimmingCharacters(in: .whitespaces).split(by: 2).map { UInt8($0, radix: 16)! }
                    lastAddr = addr + bytes.count
                    self.memory!.data[addr..<lastAddr] = Data(bytes)
                }
            }
        }
//        print("\(path):\n\(lastAddr) bytes loaded:")
//        self.memory!.dump(at: 0...lastAddr.u64)
    }
}
