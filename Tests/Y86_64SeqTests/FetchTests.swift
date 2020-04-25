//
//  FetchTests.swift
//  Y86_64SeqTests
//
//  Created by Bugen Zhao on 2020/4/24.
//

import XCTest
@testable import Y86_64SeqLib
@testable import Y86_64GenericLib


class FetchTests: XCTestCase {
    func testNOP() {
        let CPU = Y86_64Seq(fetch: true)
        CPU.memory?.data[0...9] = Data([0x10]) // NOP
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.instValid.b, true)
        XCTAssertEqual(CPU.wires.icode.v, I.NOP)
        XCTAssertEqual(CPU.wires.ifun.v, F.NONE)
        XCTAssertEqual(CPU.wires.rA.v, R.NONE)
        XCTAssertEqual(CPU.wires.rB.v, R.NONE)
        XCTAssertEqual(CPU.wires.valP.v, 1)
    }

    func testAND() {
        let CPU = Y86_64Seq(fetch: true)
        CPU.memory?.data[0...9] = Data([0x62, 0x31]) // and %rbx, %rcx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.instValid.b, true)
        XCTAssertEqual(CPU.wires.icode.v, I.OPQ)
        XCTAssertEqual(CPU.wires.ifun.v, F.AND)
        XCTAssertEqual(CPU.wires.rA.v, R.RBX)
        XCTAssertEqual(CPU.wires.rB.v, R.RCX)
        XCTAssertEqual(CPU.wires.valP.v, 2)
    }

    func testJNE() {
        let CPU = Y86_64Seq(fetch: true)
        CPU.memory?.data[0...9] = Data([0x74, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]) // jne 0xefcd_ab89_6745_2301
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.instValid.b, true)
        XCTAssertEqual(CPU.wires.icode.v, I.JXX)
        XCTAssertEqual(CPU.wires.ifun.v, F.JNE)
        XCTAssertEqual(CPU.wires.rA.v, R.NONE)
        XCTAssertEqual(CPU.wires.rB.v, R.NONE)
        XCTAssertEqual(CPU.wires.valC.v, 0xefcd_ab89_6745_2301)
        XCTAssertEqual(CPU.wires.valP.v, 9)
    }

    func testRMMOVQ() {
        let CPU = Y86_64Seq(fetch: true)
        CPU.memory?.data[0...9] = Data([0x40, 0x03, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]) // rmmovq %rax, 0xefcd_ab89_6745_2301(%rbx)
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.instValid.b, true)
        XCTAssertEqual(CPU.wires.icode.v, I.RMMOVQ)
        XCTAssertEqual(CPU.wires.ifun.v, F.NONE)
        XCTAssertEqual(CPU.wires.rA.v, R.RAX)
        XCTAssertEqual(CPU.wires.rB.v, R.RBX)
        XCTAssertEqual(CPU.wires.valC.v, 0xefcd_ab89_6745_2301)
        XCTAssertEqual(CPU.wires.valP.v, 10)
    }
    
    func testInvalid() {
        let CPU = Y86_64Seq(fetch: true)
        CPU.memory?.data[0...9] = Data([0xf0, 0x03, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]) // invalid 0xf0
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.instValid.b, false)
    }
}
