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
        printStatus()
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
        case STAT_BUB:
            return S.BUB
        case STAT_PIP:
            return S.PIP
        default:
            return 0
        }
    }
    
    public func printStatus() {
        R.names
            .enumerated()
            .dropLast()
            .forEach { idx, name in
                let value = get_reg_val(statePtr.pointee.r, reg_id_t(rawValue: reg_id_t.RawValue(idx)))
                print("\(name):\t\(String(format: "0x%016llx %lld", value, value))") }
        print("\n")
    }
    
    public var pc: UInt64 {
        return statePtr.pointee.pc.u64
    }

    deinit {
        free_state(statePtr)
        statPtr.deallocate()
    }
}
