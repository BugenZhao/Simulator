//
//  SimulatorError.swift
//  Simulator
//
//  Created by Bugen Zhao on 2020/4/22.
//

import Foundation

public enum SimulatorError: String {
    case WireFromIsFinalError = "Wire: from is final"
    case WireToIsFinalError = "Wire: to is final"
    case WireOutOfRangeError = "Wire: out of range"
}
