//
//  HelperFunctions.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 9/9/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation

//Referenced from https://stackoverflow.com/a/10331372
func generateLocation(tx1: Double, ty1: Double,
                      tx2: Double, ty2: Double,
                      tx3: Double, ty3: Double,
                      s1: Double, s2: Double, s3: Double)
    -> (x: Double, y: Double){
        
    let totalWeight = s1 + s2 + s3
        
    let w1 = (totalWeight - s1) / totalWeight
    let w2 = (totalWeight - s2) / totalWeight
    let w3 = (totalWeight - s3) / totalWeight
        
    let x = (w1 * tx1) + (w2 * tx2) + (w3 * tx3)
    let y = (w1 * ty1) + (w2 * ty2) + (w3 * ty3)
    

    return (x: x, y: y)
    
}
