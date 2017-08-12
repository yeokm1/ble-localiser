//
//  Queue.swift
//  Modified from https://github.com/raywenderlich/swift-algorithm-club/blob/master/Queue/Queue-Simple.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 12/8/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation

class FixedQueue {
    var array: Array<Double>!
    var maxSize: Int!
    
    init(maxSize: Int){
        array = Array()
        self.maxSize = maxSize

    }
    
    
    func enqueue(element: Double) {
        if array.count >= maxSize {
            array.removeFirst()
        }
        array.append(element)
    }
    
    func getAverage() -> Double {
        return array.average
    }
    
    
}

extension Array where Element == Double {
    /// Returns the sum of all elements in the array
    var total: Element {
        return reduce(0, +)
    }
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(reduce(0, +)) / Double(count)
    }
}
