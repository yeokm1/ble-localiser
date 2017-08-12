//
//  ViewController.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 12/8/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, BLEHandlerDelegate{
    
    let TAG : String = "ViewController"
    
    var bleHandler: BLEHandler!

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start BLEHandler and ask it to pass callbacks to UI (here)
        bleHandler = BLEHandler(delegate: self)

        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //BLEHandlerDelegate
    
    func newDeviceScanned(name: String, uuid: UUID, distance: Double, advertisementData: [NSObject : AnyObject]!) {
        
        NSLog("%@: discovered %@, distance:%f", TAG, name, distance)
    }
    

    


}

