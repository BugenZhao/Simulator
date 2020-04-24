import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Y86_64SeqTests.allTests),
    ]
}
#endif
