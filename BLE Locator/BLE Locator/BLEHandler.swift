//
//  BLEHandler.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 12/8/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import CoreBluetooth


//We have to extend NSObject as well as there is some issues with only implementing the CBCentralManagerDelegate
//(Guessing it is Swift issue with implementing some Objective-C delegates)
class BLEHandler : NSObject, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    let TAG = "BLEHandler"
    let BLE_DEVICE_FILTER: String = "pib"
    let broadcasterDbAt1m: Double = -60.0
    let numRSSIValuesToAverage: Int = 10
    
    let trimRatio = 0.2

    
    //CBCentralManager: To manage BLE operations
    var centralManager : CBCentralManager!
    var delegate : BLEHandlerDelegate!
    
    var foundDevices : [UUID : FixedQueue]!
    

    
    
    init(delegate : BLEHandlerDelegate){
        super.init()
        
        foundDevices = [UUID : FixedQueue]()
        self.delegate = delegate
        
        //Nil queue means the main queue. You might not want to use the main queue if you are doing heavy work on receiving callbacks
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    
    func bleScan(start: Bool){
        if(start){
            //Step 1: Start scanning

            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            
            
        } else {
            centralManager.stopScan()
        }
    }
    
    
    
    //CBCentralDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi: NSNumber) {
        
        //Step 2 : Received advertisement packet
        
        let localName: String? = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        
        
        if(localName != nil && localName!.hasPrefix(BLE_DEVICE_FILTER)){
        
  
            let peripheralUUID: UUID = peripheral.identifier
            
            if foundDevices[peripheralUUID] == nil {
                print("New device found " + localName!)
                foundDevices[peripheralUUID] = FixedQueue(maxSize: numRSSIValuesToAverage)
            }
            
            let rssiQueue: FixedQueue = foundDevices[peripheralUUID]!
            
            rssiQueue.enqueue(element: rssi.doubleValue)
            
            let avgRSSI: Double = rssiQueue.getTrimmedMean(ratio: trimRatio)
            
            let distance = calculateDistance(rssi: avgRSSI)
            
            delegate.newDeviceScanned(name: localName!, uuid: peripheral.identifier, rssi: avgRSSI, distance: distance, advertisementData: advertisementData as [NSObject : AnyObject]!)
            
        }
        
    }
    
    
    
    
    //Referenced from https://stackoverflow.com/questions/20416218/understanding-ibeacon-distancing/20434019#20434019
    func calculateDistance(rssi: Double) -> Double {
        return pow(10, (broadcasterDbAt1m - rssi) / (10 * 2));
    }

    
    //CBCentralDelegate
    
    
    //Reference http://www.raywenderlich.com/52080/introduction-core-bluetooth-building-heart-rate-monitor
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Determine the state of the Central

        if (central.state.rawValue == CBManagerState.poweredOff.rawValue) {
            NSLog("%@ CoreBluetooth BLE hardware is powered off", TAG);
        }
        else if (central.state.rawValue == CBManagerState.poweredOn.rawValue) {
            NSLog("%@ CoreBluetooth BLE hardware is powered on and ready", TAG);
        }
        else if (central.state.rawValue == CBManagerState.unauthorized.rawValue) {
            NSLog("%@ CoreBluetooth BLE state is unauthorized", TAG);
        }
        else if (central.state.rawValue == CBManagerState.unknown.rawValue) {
            NSLog("%@ CoreBluetooth BLE state is unknown", TAG);
        }
        else if (central.state.rawValue == CBManagerState.unsupported.rawValue) {
            NSLog("%@ CoreBluetooth BLE hardware is unsupported on this platform", TAG);
        }
    }

    
}


