//
//  Wrapper.swift
//  YisWrapper
//
//  Created by Bugen Zhao on 2020/5/4.
//

import Foundation
import CYis
import Y86_64GenericLib

public class Yis {
    let yoPath: String

    var statePtr: UnsafeMutablePointer<state_rec>
    var statPtr: UnsafeMutablePointer<stat_t>

    public let memSize: Int
    public let registerSize = 8 * 16
    
    private(set) public var cycle: Int? = nil

    public init(_ yoPath: String) {
        self.yoPath = yoPath
        self.memSize = Int(calculate_len(MEM_SIZE))
        self.statePtr = new_state(Int32(memSize))
        self.statPtr = .allocate(capacity: MemoryLayout<stat_t>.size)

        self.statPtr.pointee = CYis.STAT_AOK
    }

    @discardableResult public func run() -> Int {
        cycle = Int(run_yis(yoPath, statPtr, statePtr))
        return cycle!
    }

    public var memory: Data? {
        let dataPointer = UnsafeMutableBufferPointer(start: statePtr.pointee.m.pointee.contents, count: memSize)
        return Data(buffer: dataPointer)
    }

    public var register: Data? {
        let dataPointer = UnsafeMutableBufferPointer(start: statePtr.pointee.r.pointee.contents, count: registerSize)
        return Data(buffer: dataPointer)
    }

    public var cc: (zf: Bool, sf: Bool, of: Bool) {
        let ccWord = statePtr.pointee.cc
        return ((ccWord >> 2)&1 == 1, (ccWord >> 1)&1 == 1, (ccWord >> 0)&1 == 1)
    }

    public var stat: UInt64 {
        switch statPtr.pointee {
        case STAT_AOK:
            return S.AOK
        case STAT_INS:
            return S.INS
        case STAT_ADR:
            return S.ADR
        case STAT_HLT:
            return S.HLT
        default:
            return 666
        }
    }
    
    public var pc: UInt64 {
        return statePtr.pointee.pc.u64
    }

    deinit {
        free_state(statePtr)
        statPtr.deallocate()
    }
}
