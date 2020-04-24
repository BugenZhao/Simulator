//
//  Evaluation.swift
//  SimulatorLib
//
//  Created by Bugen Zhao on 2020/4/24.
//

import Foundation

public func evaluate(_ block: () -> ()) -> Double
{
    let start = DispatchTime.now()
    block()
    let end = DispatchTime.now()

    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
    let timeInterval = Double(nanoTime) / 1_000_000_000
    
    return timeInterval
}
