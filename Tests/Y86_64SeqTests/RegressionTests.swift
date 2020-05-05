//
//  RegressionTests.swift
//  Y86_64SeqTests
//
//  Created by Bugen Zhao on 2020/5/4.
//

import XCTest
@testable import YisWrapper
@testable import Y86_64SeqLib


class RegressionTests: XCTestCase {
    #if Xcode
        let yoDirPath = "/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/"
    #else
        let yoDirPath = FileManager.default.currentDirectoryPath + "/Resources/Objects/"
    #endif


    let included: [String] = [
    ]

    let excluded: [String] = [
        "perf.yo", // Too slow
        "abs-asum-cmov.yo", // TODO: cmov not implemented
    ]


    func doTest(_ yoPath: String) {
        let yis = Yis(yoPath)
        yis.run()
        yis.register?.dump()

        let seq = Y86_64Seq()
        seq.loadYO(yoPath)
        seq.run(verbose: true)

        XCTAssertEqual(yis.memory![0...0x1000], seq.memory!.data[0...0x1000])
        XCTAssertEqual(yis.register!, seq.register!.data, "\(yoPath)")

        // TODO: incorrect initial cc
    }

    func testRegression() {
        let fileManager = FileManager.default
        try? fileManager.contentsOfDirectory(atPath: yoDirPath).forEach { yoName in
            guard !excluded.contains(yoName) else { return }
            guard included.isEmpty || included.contains(yoName) else { return }
            guard yoName.hasSuffix(".yo") else { return }

            doTest(yoDirPath + yoName)
        }
    }
}
