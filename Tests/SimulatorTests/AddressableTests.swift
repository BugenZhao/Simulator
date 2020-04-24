//
//  AddressableTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/23.
//

import XCTest
import Nimble
@testable import SimulatorLib

class AddressableTests: XCTestCase {
    class Memory64B: Addressable {
        var data: Data

        init() { data = Data(count: 64) }
    }
    
    class Memory70B: Addressable {
        var data: Data

        init() { data = Data(count: 70) }
    }

    func testAddressing() {
        var memory = Memory64B()
        XCTAssertEqual(memory.data.count, 64)

        memory.data[0...15] = Data(repeating: 0x88, count: 16)
        XCTAssertEqual(memory[b: 16], 0x00)
        XCTAssertEqual(memory[w: 15], 0x88)
        XCTAssertEqual(memory[l: 13], 0x88_8888)
        XCTAssertEqual(memory[q: 11], 0x88_8888_8888)

        memory[q: 16] = 0x0123_4567_89ab_cdef
        XCTAssertEqual(memory[b: 16], 0xef)
        XCTAssertEqual(memory[w: 17], 0xabcd)
        XCTAssertEqual(memory[l: 18], 0x4567_89ab)
        XCTAssertEqual(memory[q: 17], 0x0001_2345_6789_abcd)
    }

    func testAddressingError() {
        var memory = Memory64B()
        expect { _ = memory[l: 64] }.to(throwAssertion())
        expect { _ = memory[q: 57] }.to(throwAssertion())
        expect { memory[l: 64] = 0x88 }.to(throwAssertion())
        expect { memory[q: 57] = 0x88 }.to(throwAssertion())
    }

    func testRegister() {
        let registerUnit = RegisterUnit("reg", [], [], { _, _ in return }, { _, _ in return }, 128)
        _ = registerUnit[l: 0]
    }
    
    func testDump() {
        var memory = Memory70B()
        memory.dump(at: 0...0)
        memory.dump(at: 16...47)
        memory.dump(at: 48...69)
    }
}
