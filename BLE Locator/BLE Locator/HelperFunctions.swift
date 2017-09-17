//
//  HelperFunctions.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 9/9/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation

//Referenced from https://gist.github.com/AngeloGiurano/7a6ee79535b835aa1791
func trilateration(x1:Double, y1:Double, d1:Double, x2:Double, y2:Double, d2:Double, x3:Double, y3:Double, d3: Double) -> (xPos: Double, yPos: Double) {
    
    
    var P1 = [x1, y1]
    var P2 = [x2, y2]
    var P3 = [x3, y3]
    
    let DistA = d1
    let DistB = d2
    let DistC = d3
    
    var ex: [Double] = []
    var tmp: Double = 0
    var P3P1: [Double] = []
    var ival: Double = 0
    var ey: [Double] = []
    var P3P1i: Double = 0
    var ez: [Double] = []
    var ezx: Double = 0
    var ezy: Double = 0
    var ezz: Double = 0
    
    // ex = (P2 - P1)/||P2-P1||
    for i in 0 ..< P1.count {
        let t1 = P2[i]
        let t2 = P1[i]
        let t:Double = t1-t2
        tmp += (t*t)
    }
    
    for i in 0 ..< P1.count {
        let t1 = P2[i]
        let t2 = P1[i]
        let exx: Double = (t1-t2)/sqrt(tmp)
        ex.append(exx)
    }
    
    // i = ex(P3 - P1)
    for i in 0 ..< P3.count {
        let t1 = P3[i]
        let t2 = P1[i]
        let t3 = t1-t2
        P3P1.append(t3)
    }
    
    for i in 0 ..< ex.count {
        let t1 = ex[i]
        let t2 = P3P1[i]
        ival += (t1*t2)
    }
    //ey = (P3 - P1 - i · ex) / ‖P3 - P1 - i · ex‖
    for i in 0 ..< P3.count {
        let t1 = P3[i]
        let t2 = P1[i]
        let t3 = ex[i] * ival
        let t = t1 - t2 - t3
        P3P1i += (t*t)
    }
    
    
    for i in 0 ..< P3.count {
        let t1 = P3[i]
        let t2 = P1[i]
        let t3 = ex[i] * ival
        let eyy = (t1 - t2 - t3)/sqrt(P3P1i)
        ey.append(eyy)
    }
    
    if P1.count == 3 {
        ezx = ex[1]*ey[2] - ex[2]*ey[1]
        ezy = ex[2]*ey[0] - ex[0]*ey[2]
        ezz = ex[0]*ey[1] - ex[1]*ey[0]
    }
    
    ez.append(ezx)
    ez.append(ezy)
    ez.append(ezz)
    
    //d = ‖P2 - P1‖
    let d:Double = sqrt(tmp)
    var j:Double = 0
    
    //j = ey(P3 - P1)
    for i in 0 ..< ey.count {
        let t1 = ey[i]
        let t2 = P3P1[i]
        j += (t1*t2)
    }
    //x = (r12 - r22 + d2) / 2d
    let x = (pow(DistA,2) - pow(DistB,2) + pow(d,2))/(2*d)
    //y = (r12 - r32 + i2 + j2) / 2j - ix / j
    let y = ((pow(DistA,2) - pow(DistC,2) + pow(ival,2) + pow(j,2))/(2*j)) - ((ival/j)*x)
    
    var z: Double = 0
    if P1.count == 3 {
        z = sqrt(pow(DistA,2) - pow(x,2) - pow(y,2))
    }
    
    var unknownPoint:[Double] = []
    
    for i in 0 ..< P1.count {
        let t1 = P1[i]
        let t2 = ex[i] * x
        let t3 = ey[i] * y
        let t4 = ez[i] * z
        let unknownPointCoord = t1 + t2 + t3 + t4
        unknownPoint.append(unknownPointCoord)
    }
    
    return (xPos: unknownPoint[0], yPos: unknownPoint[1])
}


