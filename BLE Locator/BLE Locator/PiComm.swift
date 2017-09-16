//
//  PiComm.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 10/9/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import Socket


class PiComm {
    // class definition goes here

    let NUM_LEDS: Int = 64
    let portNumber: Int = 55555

    let piIPAddrAssignment: Dictionary<String, String> = [leftMacAddress: "192.168.2.162",
                                                          middleMacAddress: "192.168.2.19",
                                                          rightMacAddress: "192.168.2.157"]


    var sendSocket: Socket?
    func openSocket(){
        
        do {
            sendSocket = try Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp)
        } catch {
            print("Error creating socket \(error)")
        }
        
    }
    
    func closeSocket(){
        sendSocket?.close()
    }


    func sendPacket(id: String, ledsToTurnOn: Int, red: Int, green: Int, blue: Int){
    
        if let ipAddress = piIPAddrAssignment[id] {
        
    
            do{
       
                var ledsToUse : Int!
                
                if ledsToTurnOn > NUM_LEDS {
                    ledsToUse = NUM_LEDS
                } else {
                    ledsToUse = ledsToTurnOn
                }
        
        
                let dataStr: String = String.localizedStringWithFormat("%d %d %d %d", ledsToUse, red, green, blue)
        
            
                if let address: Socket.Address = Socket.createAddress(for: ipAddress, on: Int32(portNumber)){
                    try sendSocket?.write(from: dataStr, to: address)
                }
        
        
            } catch {
                print("Error in sending \(error)")
            }
    }
    
}
}
