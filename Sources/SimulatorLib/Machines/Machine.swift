//
//  Machine.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public protocol Machine {
    var unitManager: UnitManager { get }
    func run()
}
