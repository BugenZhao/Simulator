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

    public let memSize = Int(MEM_SIZE)
    public let registerSize = 8 * 16

    init(_ yoPath: String) {
        self.yoPath = yoPath
        self.statePtr = new_state(Int32(memSize))
        self.statPtr = .allocate(capacity: MemoryLayout<stat_t>.size)
        
        self.statPtr.pointee = STAT_AOK
    }

    public func run() -> Int {
        return Int(runYis(yoPath, statPtr, statePtr))
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
