import XCTest

import SimulatorTests

var tests = [XCTestCaseEntry]()
tests += SimulatorTests.allTests()
XCTMain(tests)
