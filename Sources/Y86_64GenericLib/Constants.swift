//
//  Constants.swift
//  Y86_64GenericLib
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation


// Instructions
public struct I {                      // A  , B  , E  , M
    public static let HALT   = 0x0.u64 // ---, ---, ---, ---
    public static let NOP    = 0x1.u64 // ---, ---, ---, ---
    public static let RRMOVQ = 0x2.u64 // rA , ---, rB , ---
    public static let IRMOVQ = 0x3.u64 // ---, ---, rB , ---
    public static let RMMOVQ = 0x4.u64 // rA , rB , ---, ---
    public static let MRMOVQ = 0x5.u64 // ---, rB , ---, rA  !!
    public static let OPQ    = 0x6.u64 // rA , rB , rB , ---
    public static let JXX    = 0x7.u64 // ---, ---, ---, ---
    public static let CALL   = 0x8.u64 // ---, rsp, rsp, ---
    public static let RET    = 0x9.u64 // rsp, rsp, rsp, ---
    public static let PUSHQ  = 0xa.u64 // rA , rsp, rsp, ---
    public static let POPQ   = 0xb.u64 // rsp, rsp, rsp, rA
    public static let IADDQ  = 0xc.u64 // ---, rB , rB , ---
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
    public static let JL  = 2.u64
    public static let JE  = 3.u64
    public static let JNE = 4.u64
    public static let JGE = 5.u64
    public static let JG  = 6.u64
}

// Registers
public struct R {
    public static let RAX = 0x0.u64
    public static let RCX = 0x1.u64
    public static let RDX = 0x2.u64
    public static let RBX = 0x3.u64
    public static let RSP = 0x4.u64
    public static let RBP = 0x5.u64
    public static let RSI = 0x6.u64
    public static let RDI = 0x7.u64
    public static let R8  = 0x8.u64
    public static let R9  = 0x9.u64
    public static let R10 = 0xa.u64
    public static let R11 = 0xb.u64
    public static let R12 = 0xc.u64
    public static let R13 = 0xd.u64
    public static let R14 = 0xe.u64

    public static let NONE = 0xf.u64

    public static let names = [
        "RAX",
        "RCX",
        "RDX",
        "RBX",
        "RSP",
        "RBP",
        "RSI",
        "RDI",
        "R8 ",
        "R9 ",
        "R10",
        "R11",
        "R12",
        "R13",
        "R14",
        "None"
    ]
}

// Statuses
public struct S {
    public static let BUB = 0.u64
    public static let AOK = 1.u64
    public static let ADR = 2.u64
    public static let INS = 3.u64
    public static let HLT = 4.u64
    public static let PIP = 5.u64

    public static let names = [
        "BUB",
        "AOK",
        "ADR",
        "INS",
        "HLT",
        "PIP"
    ]
}
