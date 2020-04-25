//
//  ExecuteTests.swift
//  Y86_64SeqTests
//
//  Created by Bugen Zhao on 2020/4/25.
//

import XCTest
@testable import Y86_64SeqLib

class ExecuteTests: XCTestCase {
    var CPU: Y86_64Seq?

    override func setUp() {
        CPU = Y86_64Seq(fetch: true, decodeWriteBack: true, execute: true)
        // fill register with its id
        (R.RAX...R.R14).forEach { CPU!.register![$0] = $0 }
        CPU!.register![15] = 15
    }

    func testAND() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0x62, 0x31]) // and %rbx, %rcx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.aluFun.v, F.AND)
        XCTAssertEqual(CPU.wires.aluA.v, R.RBX)
        XCTAssertEqual(CPU.wires.aluB.v, R.RCX)
        XCTAssertEqual(CPU.wires.valE.v, R.RBX & R.RCX)
        XCTAssertEqual(CPU.wires.setCC.b, true)
    }

    func testSUB1() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0x61, 0x31]) // sub %rbx, %rcx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.aluFun.v, F.SUB)
        XCTAssertEqual(CPU.wires.aluA.v, R.RBX)
        XCTAssertEqual(CPU.wires.aluB.v, R.RCX)
        XCTAssertEqual(CPU.wires.valE.v, (-2).nu64)
        XCTAssertEqual(CPU.wires.zfi.b, false)
        XCTAssertEqual(CPU.wires.sfi.b, true)
        XCTAssertEqual(CPU.wires.ofi.b, true)
        XCTAssertEqual(CPU.wires.setCC.b, true)
    }

    func testSUB2() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0x61, 0x33]) // sub %rbx, %rbx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.aluFun.v, F.SUB)
        XCTAssertEqual(CPU.wires.aluA.v, R.RBX)
        XCTAssertEqual(CPU.wires.aluB.v, R.RBX)
        XCTAssertEqual(CPU.wires.valE.v, 0)
        XCTAssertEqual(CPU.wires.zfi.b, true)
        XCTAssertEqual(CPU.wires.sfi.b, false)
        XCTAssertEqual(CPU.wires.ofi.b, false)
        XCTAssertEqual(CPU.wires.setCC.b, true)
    }

    func testADD() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0x60, 0x33]) // sub %rbx, %rbx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.aluFun.v, F.ADD)
        XCTAssertEqual(CPU.wires.aluA.v, R.RBX)
        XCTAssertEqual(CPU.wires.aluB.v, R.RBX)
        XCTAssertEqual(CPU.wires.valE.v, 6)
        XCTAssertEqual(CPU.wires.zfi.b, false)
        XCTAssertEqual(CPU.wires.sfi.b, false)
        XCTAssertEqual(CPU.wires.ofi.b, false)
        XCTAssertEqual(CPU.wires.setCC.b, true)
    }

    func testPUSHQ() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0xa0, 0x6f]) // push %rsi
        CPU.register?[R.RSP] = 0x100
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.aluFun.v, F.ADD)
        XCTAssertEqual(CPU.wires.aluA.v, (-8).nu64)
        XCTAssertEqual(CPU.wires.aluB.v, 0x100)
        XCTAssertEqual(CPU.wires.valE.v, 0x100 - 8)
        XCTAssertEqual(CPU.wires.zfi.b, false)
        XCTAssertEqual(CPU.wires.sfi.b, false)
        XCTAssertEqual(CPU.wires.ofi.b, false)
        XCTAssertEqual(CPU.wires.setCC.b, false)
    }

    func testPOPQ() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0xb0, 0x7f]) // pop %rdi
        CPU.register?[R.RSP] = 0x100
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.aluFun.v, F.ADD)
        XCTAssertEqual(CPU.wires.aluA.v, 8)
        XCTAssertEqual(CPU.wires.aluB.v, 0x100)
        XCTAssertEqual(CPU.wires.valE.v, 0x100 + 8)
        XCTAssertEqual(CPU.wires.zfi.b, false)
        XCTAssertEqual(CPU.wires.sfi.b, false)
        XCTAssertEqual(CPU.wires.ofi.b, false)
        XCTAssertEqual(CPU.wires.setCC.b, false)
    }

    func testMRMOVQ() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0x50, 0x12, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]) // mrmovq 0xefcd_ab89_6745_2301(%rcx), %rdx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.aluFun.v, F.ADD)
        XCTAssertEqual(CPU.wires.aluA.v, 0xefcd_ab89_6745_2301)
        XCTAssertEqual(CPU.wires.aluB.v, R.RDX)
        XCTAssertEqual(CPU.wires.valE.v, 0xefcd_ab89_6745_2301 + R.RDX)
        XCTAssertEqual(CPU.wires.zfi.b, false)
        XCTAssertEqual(CPU.wires.sfi.b, true)
        XCTAssertEqual(CPU.wires.ofi.b, false)
        XCTAssertEqual(CPU.wires.setCC.b, false)
    }
}

