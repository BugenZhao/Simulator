//
//  YisTests.swift
//  Y86_64SeqTests
//
//  Created by Bugen Zhao on 2020/5/4.
//

import XCTest
@testable import YisWrapper
@testable import Y86_64SeqLib

class YisTests: XCTestCase {
    func testHello() {
        #if Xcode
            let yo = "/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/asumi.yo"
        #else
            let yo = FileManager.default.currentDirectoryPath + "/Resources/Objects/asumi.yo"
        #endif

        let yis = Yis(yo)
        _ = yis.run()

        yis.memory?.dump(at: 0...200)
        yis.register?.dump()

        let system = Y86_64Seq()
        system.loadYO(yo)
        system.run()

        system.memory?.dump(at: 0...200)
        system.register?.dump()

        XCTAssertEqual(yis.memory?[0...200], system.memory?.data[0...200])
        XCTAssertEqual(yis.register, system.register?.data)
    }
}
