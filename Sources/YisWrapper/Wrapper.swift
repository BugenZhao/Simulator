//
//  Wrapper.swift
//  YisWrapper
//
//  Created by Bugen Zhao on 2020/5/4.
//

import Foundation
import CYis

public class Yis {
    let yoPath: String

    var statePtr: UnsafeMutablePointer<state_rec>
    var statPtr: UnsafeMutablePointer<stat_t>

    public let memSize: Int
    public let registerSize = 8 * 16

    public init(_ yoPath: String) {
        self.yoPath = yoPath
        self.memSize = Int(calculate_len(MEM_SIZE))
        self.statePtr = new_state(Int32(memSize))
        self.statPtr = .allocate(capacity: MemoryLayout<stat_t>.size)

        self.statPtr.pointee = CYis.STAT_AOK
    }

    @discardableResult public func run() -> Int {
        return Int(run_yis(yoPath, statPtr, statePtr))
    }

    public var memory: Data? {
        let dataPointer = UnsafeMutableBufferPointer(start: statePtr.pointee.m.pointee.contents, count: memSize)
        return Data(buffer: dataPointer)
    }

    public var register: Data? {
        let dataPointer = UnsafeMutableBufferPointer(start: statePtr.pointee.r.pointee.contents, count: registerSize)
        return Data(buffer: dataPointer)
    }

    deinit {
        free_state(statePtr)
        statPtr.deallocate()
    }
}
