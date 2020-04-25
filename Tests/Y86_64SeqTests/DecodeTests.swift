//
//  DecodeTests.swift
//  Y86_64SeqTests
//
//  Created by Bugen Zhao on 2020/4/25.
//

import XCTest
@testable import Y86_64SeqLib

class DecodeTests: XCTestCase {
    var CPU: Y86_64Seq?

    override func setUpWithError() throws {
        CPU = Y86_64Seq(fetch: true, decodeWriteBack: true)
        // fill register with its id
        (R.RAX...R.R14).forEach { CPU!.register![$0] = $0 }
        CPU!.register![15] = 15
    }

    func testAND() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0x62, 0x31]) // and %rbx, %rcx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.valA.v, R.RBX)
        XCTAssertEqual(CPU.wires.valB.v, R.RCX)
        XCTAssertEqual(CPU.wires.dstE.v, R.RCX)
        XCTAssertEqual(CPU.wires.dstM.v, R.NONE)
    }

    func testPUSHQ() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0xa0, 0x6f]) // push %rsi
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.valA.v, R.RSI)
        XCTAssertEqual(CPU.wires.valB.v, R.RSP)
        XCTAssertEqual(CPU.wires.dstE.v, R.RSP)
        XCTAssertEqual(CPU.wires.dstM.v, R.NONE)
    }

    func testPOPQ() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0xb0, 0x7f]) // push %rdi
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.valA.v, R.RSP)
        XCTAssertEqual(CPU.wires.valB.v, R.RSP)
        XCTAssertEqual(CPU.wires.dstE.v, R.RSP)
        XCTAssertEqual(CPU.wires.dstM.v, R.RDI)
    }

    func testMRMOVQ() {
        let CPU = self.CPU!
        CPU.imemory?.data[0...9] = Data([0x50, 0x12, 0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef]) // mrmovq 0xefcd_ab89_6745_2301(%rcx), %rdx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.valA.v, R.NONE)
        XCTAssertEqual(CPU.wires.valB.v, R.RDX)
        XCTAssertEqual(CPU.wires.dstE.v, R.NONE)
        XCTAssertEqual(CPU.wires.dstM.v, R.RCX)
    }
}
