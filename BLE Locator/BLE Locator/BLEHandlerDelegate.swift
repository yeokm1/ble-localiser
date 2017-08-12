//
//  BLEHandlerDelegate.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 12/8/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol BLEHandlerDelegate {
    
    func newDeviceScanned(name : String, uuid: UUID, distance : Double, advertisementData : [NSObject : AnyObject]!)

}
