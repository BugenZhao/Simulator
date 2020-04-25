//
//  Constants.swift
//  Y86_64Seq
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation


// Instructions
struct I {                     // A  , B  , E  , M
    static let HALT = 0.u64    // ---, ---, ---, ---
    static let NOP = 1.u64     // ---, ---, ---, ---
    static let RRMOVQ = 2.u64  // rA , ---, rB , ---
    static let IRMOVQ = 3.u64  // ---, ---, rB , ---
    static let RMMOVQ = 4.u64  // rA , rB , ---, ---
    static let MRMOVQ = 5.u64  // ---, rB , ---, rA  !!
    static let OPQ = 6.u64     // rA , rB , rB , ---
    static let JXX = 7.u64     // ---, ---, ---, ---
    static let CALL = 8.u64    // ---, rsp, rsp, ---
    static let RET = 9.u64     // rsp, rsp, rsp, ---
    static let PUSHQ = 0xa.u64 // rA , rsp, rsp, ---
    static let POPQ = 0xb.u64  // rsp, rsp, rsp, rA
}

// Functions
struct F {
    static let NONE = 0.u64

    static let ADD = 0.u64
    static let SUB = 1.u64
    static let AND = 2.u64
    static let XOR = 3.u64

    static let JMP = 0.u64
    static let JLE = 1.u64
    static let JL = 2.u64
    static let JE = 3.u64
    static let JNE = 4.u64
    static let JGE = 5.u64
    static let JG = 6.u64
}

// Registers
struct R {
    static let RAX = 0.u64
    static let RCX = 1.u64
    static let RDX = 2.u64
    static let RBX = 3.u64
    static let RSP = 4.u64
    static let RBP = 5.u64
    static let RSI = 6.u64
    static let RDI = 7.u64
    static let R8 = 8.u64
    static let R9 = 9.u64
    static let R10 = 0xa.u64
    static let R11 = 0xb.u64
    static let R12 = 0xc.u64
    static let R13 = 0xd.u64
    static let R14 = 0xe.u64

    static let NONE = 0xf.u64
}

// Statuses
struct S {
    static let AOK = 1.u64
    static let ADR = 2.u64
    static let INS = 3.u64
    static let HLT = 4.u64
}
