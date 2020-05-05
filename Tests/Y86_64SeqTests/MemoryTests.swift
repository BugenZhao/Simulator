//
//  MemoryTests.swift
//  Y86_64SeqTests
//
//  Created by Bugen Zhao on 2020/4/25.
//

import XCTest
@testable import Y86_64SeqLib
@testable import Y86_64GenericLib

class MemoryTests: XCTestCase {
    var CPU: Y86_64Seq?

    override func setUp() {
        CPU = Y86_64Seq(fetch: true, decodeWriteBack: true, execute: true, memory: true)
        // fill register with its id
        (R.RAX...R.R14).forEach { CPU!.register![$0] = $0 }
        CPU!.register![15] = 15
    }

    func testAND() {
        let CPU = self.CPU!
        CPU.memory?.data[0...9] = Data([0x62, 0x31]) // and %rbx, %rcx
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.memRead.b, false)
        XCTAssertEqual(CPU.wires.memWrite.b, false)
    }

    func testPUSHQ() {
        let CPU = self.CPU!
        CPU.memory?.data[0...9] = Data([0xa0, 0x6f]) // push %rsi
        CPU.register?[R.RSP] = 0x100
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.memAddr.v, 0x100 - 8)
        XCTAssertEqual(CPU.wires.memData.v, R.RSI)
        XCTAssertEqual(CPU.wires.memRead.b, false)
        XCTAssertEqual(CPU.wires.memWrite.b, true)

        CPU.um.clock()
        XCTAssertEqual(CPU.memory![q: 0x100 - 8], R.RSI)
    }

    func testPOPQ() {
        let CPU = self.CPU!
        CPU.memory?.data[0...9] = Data([0xb0, 0x7f]) // pop %rdi
        CPU.register?[R.RSP] = 0x100
        CPU.memory![q: 0x100] = 0x8888
        CPU.um.clock()

        XCTAssertEqual(CPU.wires.memAddr.v, 0x100)
        XCTAssertEqual(CPU.wires.memRead.b, true)
        XCTAssertEqual(CPU.wires.memWrite.b, false)
        XCTAssertEqual(CPU.register![R.RDI], 0x8888)
        XCTAssertEqual(CPU.register![R.RSP], 0x100 + 8)
        XCTAssertEqual(CPU.stat![b: 0], S.AOK)
    }

    func testHALT() {
        let CPU = self.CPU!
        CPU.memory?.data[0...9] = Data([0x00]) // halt
        CPU.um.clock()
        CPU.um.clock()
        XCTAssertEqual(CPU.halted, true)
    }
}

