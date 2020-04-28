//
//  Constants.swift
//  Y86_64GenericLib
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation


// Instructions
public struct I {                     // A  , B  , E  , M
    public static let HALT = 0.u64    // ---, ---, ---, ---
    public static let NOP = 1.u64     // ---, ---, ---, ---
    public static let RRMOVQ = 2.u64  // rA , ---, rB , ---
    public static let IRMOVQ = 3.u64  // ---, ---, rB , ---
    public static let RMMOVQ = 4.u64  // rA , rB , ---, ---
    public static let MRMOVQ = 5.u64  // ---, rB , ---, rA  !!
    public static let OPQ = 6.u64     // rA , rB , rB , ---
    public static let JXX = 7.u64     // ---, ---, ---, ---
    public static let CALL = 8.u64    // ---, rsp, rsp, ---
    public static let RET = 9.u64     // rsp, rsp, rsp, ---
    public static let PUSHQ = 0xa.u64 // rA , rsp, rsp, ---
    public static let POPQ = 0xb.u64  // rsp, rsp, rsp, rA
    public static let IADDQ = 0xc.u64 // ---, rB , rB , ---
}

// Functions
public struct F {
    public static let NONE = 0.u64

    public static let ADD = 0.u64
    public static let SUB = 1.u64
    public static let AND = 2.u64
    public static let XOR = 3.u64

    public static let JMP = 0.u64
    public static let JLE = 1.u64
    public static let JL = 2.u64
    public static let JE = 3.u64
    public static let JNE = 4.u64
    public static let JGE = 5.u64
    public static let JG = 6.u64
}

// Registers
public struct R {
    public static let RAX = 0.u64
    public static let RCX = 1.u64
    public static let RDX = 2.u64
    public static let RBX = 3.u64
    public static let RSP = 4.u64
    public static let RBP = 5.u64
    public static let RSI = 6.u64
    public static let RDI = 7.u64
    public static let R8 = 8.u64
    public static let R9 = 9.u64
    public static let R10 = 0xa.u64
    public static let R11 = 0xb.u64
    public static let R12 = 0xc.u64
    public static let R13 = 0xd.u64
    public static let R14 = 0xe.u64

    public static let NONE = 0xf.u64
}

// Statuses
public struct S {
    public static let AOK = 1.u64
    public static let ADR = 2.u64
    public static let INS = 3.u64
    public static let HLT = 4.u64
}
