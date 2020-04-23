//
//  UnitTests.swift
//  SimulatorTests
//
//  Created by Bugen Zhao on 2020/4/23.
//

import XCTest
@testable import SimulatorLib

class UnitTests: XCTestCase {
    func testUnitCopy() {
        let unit = GenericUnit("one", [], [], { _ in return })
        let unitCopied = unit.copied()
        unitCopied.name = "another"
        XCTAssertEqual(unit.name, "one")
        XCTAssertEqual(unitCopied.name, "another")
    }
}
