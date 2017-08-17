//
//  ViewController.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 12/8/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import UIKit
import CoreLocation
import Socket

class ViewController: UIViewController, BLEHandlerDelegate{
    
    let TAG: String = "ViewController"
    let MAX_DIST: Double = 3.0
    
    var bleHandler: BLEHandler!
    
    let portNumber: Int = 55555
    
    var sendSocket: Socket?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start BLEHandler and ask it to pass callbacks to UI (here)
        bleHandler = BLEHandler(delegate: self)
        
        do {
            sendSocket = try Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp)
        } catch {
            print("Error creating socket \(error)")
        }
        
        //scheduledTimerWithTimeInterval()
        bleHandler.bleScan(start: true)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sendSocket?.close()
        bleHandler.bleScan(start: false)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //BLEHandlerDelegate
    
    func newDeviceScanned(name: String, uuid: UUID, distance: Double, advertisementData: [NSObject : AnyObject]!) {
    
        
        let components: [String] = name.components(separatedBy: "-")
        
        if components.count != 3{
            return
        }

        //NSLog("%@: discovered %@, distance:%f", TAG, name, distance)
        //let colour: String = components[1]
        let ipAddr: String = components[2]
        
        sendPacket(ipAddress: ipAddr, distance: distance, maxDistance: MAX_DIST)
        
        
    }
    
    
    func sendPacket(ipAddress: String, distance: Double, maxDistance: Double){
        
        do{
        
            let dataStr = String(format:"%0.2f", distance) + " " + String(maxDistance)
        

            if let address: Socket.Address = Socket.createAddress(for: ipAddress, on: Int32(portNumber)){
                try sendSocket?.write(from: dataStr, to: address)
            }
            
            
        } catch {
            print("Error in sending \(error)")
        }
        
    }
    

}

