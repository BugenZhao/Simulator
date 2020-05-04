//
//  Wrapper.swift
//  YisWrapper
//
//  Created by Bugen Zhao on 2020/5/4.
//

import Foundation
import CYis

public class Yis {
    var state = state_ptr(nil)
    var stat = STAT_AOK

    init(_ yoPath: String) {
        state = new_state(MEM_SIZE)
        print(state!.pointee.cc)
    }

    deinit {
        free_state(state)
    }
}
