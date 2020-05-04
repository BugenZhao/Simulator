//
//  YisTests.swift
//  Y86_64SeqTests
//
//  Created by Bugen Zhao on 2020/5/4.
//

import XCTest
@testable import YisWrapper

class YisTests: XCTestCase {
    func testHello() {
        #if Xcode
            let yo = "/Users/bugenzhao/Codes/Swift/Simulator/Resources/Objects/asumi.yo"
        #else
            let yo = FileManager.default.currentDirectoryPath + "/Resources/Objects/asumi.yo"
        #endif

        let yis = Yis(yo)
        let result = yis.run()
        print("Result: \(result)")

        yis.memory?.dump()
        yis.register?.dump()
    }
}
