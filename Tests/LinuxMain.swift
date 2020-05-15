import XCTest

import SimulatorTests
import Y86_64PipeTests
import Y86_64SeqTests

var tests = [XCTestCaseEntry]()
tests += SimulatorTests.__allTests()
tests += Y86_64PipeTests.__allTests()
tests += Y86_64SeqTests.__allTests()

XCTMain(tests)
