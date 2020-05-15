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

    #if Xcode
        let isaYoDirPath = "/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/ISA/"
    #else
        let isaYoDirPath = FileManager.default.currentDirectoryPath + "/Resources/Objects/ISA/"
    #endif


    let included: [String] = [
    ]

    let excluded: [String] = [
        "perf.yo", // Too slow
    ]

    override func setUp() {
        super.setUp()
        self.continueAfterFailure = false
    }

    func doTest(_ yoPath: String, debug: Bool = false) {
        print(">>>\(yoPath)")
        
        let yis = Yis(yoPath)
        yis.run()

        let seq = Y86_64Seq()
        seq.loadYO(yoPath)
        seq.run(debug: debug)

        // MARK: Memory
        XCTAssertEqual(yis.memory![0..<0x2000], seq.memory!.data[0..<0x2000])

        // MARK: Register
        XCTAssertEqual(yis.register!, seq.register!.data, "\(yoPath)")

        // MARK: CC
        let yisCC = yis.cc
        let seqCC = (zf: seq.cc![b: 0] != 0, sf: seq.cc![b: 1] != 0, of: seq.cc![b: 2] != 0)
        XCTAssertEqual(yisCC.zf, seqCC.zf)
        XCTAssertEqual(yisCC.sf, seqCC.sf)
        XCTAssertEqual(yisCC.of, seqCC.of)

        // MARK: Stat
        let yisStat = yis.stat
        let seqStat = seq.stat![b: 0]
        XCTAssertEqual(yisStat, seqStat)

        // MARK: PC
        let yisPC = yis.pc
        let seqPC = seq.pc![0]
        XCTAssert(yisPC...(yisPC + 10) ~= seqPC)
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

    func testISA() {
        let fileManager = FileManager.default
        try? fileManager.contentsOfDirectory(atPath: isaYoDirPath).forEach { yoName in
            guard !excluded.contains(yoName) else { return }
            guard included.isEmpty || included.contains(yoName) else { return }
            guard yoName.hasSuffix(".yo") else { return }

            let debug = included.contains(yoName)
            doTest(isaYoDirPath + yoName, debug: debug)
        }
    }
}
