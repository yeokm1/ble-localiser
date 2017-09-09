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


let redMacAddress = "B3"
let greenMacAddress = "39"
let blueMacAddress = "27"

class ViewController: UIViewController, BLEHandlerDelegate{
    
    let TAG: String = "ViewController"
    let NUM_LEDS: Int = 64
    
    var bleHandler: BLEHandler!
    
    let portNumber: Int = 55555
    
    var sendSocket: Socket?
    
    var brightness: Int = 0
    var maxDistance: Double = 5.0
    
    @IBOutlet weak var bleScanSwitch: UISwitch!
    
    @IBOutlet weak var brightnessStepper: UIStepper!
    @IBOutlet weak var brightnessValueLabel: UILabel!
    
    @IBOutlet weak var maxDistanceSlider: UISlider!
    @IBOutlet weak var maxDistanceValueLabel: UILabel!
    
    
    @IBOutlet weak var redStatusLabel: UILabel!
    @IBOutlet weak var greenStatusLabel: UILabel!
    @IBOutlet weak var blueStatusLabel: UILabel!
    
    @IBOutlet weak var mapOfBeaconsView: UIView!
    
    let rpiWidth: Double = 20
    let rpiHeight: Double = 10
    let pixelPerMeter: Double = 75
    

    let piColourAssignment: Dictionary<String, Array<Int>> = [redMacAddress: [1,0,0], greenMacAddress: [0, 1, 0], blueMacAddress: [0, 0, 1]]
    let piIPAddrAssignment: Dictionary<String, String> = [redMacAddress: "192.168.2.19", greenMacAddress: "192.168.2.162", blueMacAddress: "192.168.2.186"]
    
    let piPositionAssignment: Dictionary<String, Array<Double>> = [redMacAddress: [0, 0.435], greenMacAddress: [-0.5, -0.435], blueMacAddress: [0.5, -0.435]]
    
    var labelAssignment: Dictionary<String, UILabel> = Dictionary<String, UILabel>()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleScanSwitch.addTarget(self, action: #selector(bleScanSwitchValueDidChange), for: .valueChanged)
        brightnessStepper.addTarget(self, action: #selector(brightnessStepperValueDidChange), for: .valueChanged)
        
        maxDistanceSlider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)

        labelAssignment["B3"] = redStatusLabel
        labelAssignment["39"] = greenStatusLabel
        labelAssignment["27"] = blueStatusLabel
        
        brightnessStepperValueDidChange(sender: brightnessStepper)
        distanceSliderValueDidChange(sender: maxDistanceSlider)
        
        
        let redPiView = createRPiView(xPosM: piPositionAssignment[redMacAddress]![0], yPosM: piPositionAssignment[redMacAddress]![1], colour: UIColor.red)
        mapOfBeaconsView.addSubview(redPiView)
        
        let greenPiView = createRPiView(xPosM: piPositionAssignment[greenMacAddress]![0], yPosM: piPositionAssignment[greenMacAddress]![1], colour: UIColor.green)
        mapOfBeaconsView.addSubview(greenPiView)
        
        let bluePiView = createRPiView(xPosM: piPositionAssignment[blueMacAddress]![0], yPosM: piPositionAssignment[blueMacAddress]![1], colour: UIColor.blue)
        mapOfBeaconsView.addSubview(bluePiView)
        
        
        //Start BLEHandler and ask it to pass callbacks to UI (here)
        bleHandler = BLEHandler(delegate: self)
        
        do {
            sendSocket = try Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp)
        } catch {
            print("Error creating socket \(error)")
        }
    
        
    }
    
    func generatePositionBasedOnCenterOfMap(xPosM: Double, yPosM: Double) -> (Double, Double){
        //Our coordinate system assumes origin is bottom left however UIView is based on top left
        //y coordinate has to be adjusted as a result
        return (Double(mapOfBeaconsView.frame.width / 2) + (xPosM * pixelPerMeter), Double(mapOfBeaconsView.frame.height) - (Double(mapOfBeaconsView.frame.height / 2) + (yPosM * pixelPerMeter)))
    }
    
    func createRPiView(xPosM: Double, yPosM: Double, colour: UIColor) -> UIView {
        
        let centeredCoord = generatePositionBasedOnCenterOfMap(xPosM: xPosM, yPosM: yPosM)
        
        let newView = UIView(frame: CGRect(x: centeredCoord.0 - (rpiWidth / 2), y: centeredCoord.1 - (rpiHeight / 2), width: rpiWidth, height: rpiHeight))

        newView.backgroundColor = colour
        
        return newView
        
    }
    
    func bleScanSwitchValueDidChange(sender:UISwitch) {
        
        if sender.isOn {
            bleHandler.bleScan(start: true)
        } else {
            bleHandler.bleScan(start: false)
        }

    }
    
    
    func brightnessStepperValueDidChange(sender: UIStepper){
        brightness = Int(sender.value)
        brightnessValueLabel.text = String(brightness)
    }
    
    
    func distanceSliderValueDidChange(sender: UISlider){
        maxDistance = Double(sender.value)
        maxDistanceValueLabel.text = String(format: "%.1f", maxDistance)
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
    
    func newDeviceScanned(name: String, uuid: UUID, rssi: Double, distance: Double, advertisementData: [NSObject : AnyObject]!) {
    
        
        let components: [String] = name.components(separatedBy: "-")
        
        if components.count < 2{
            return
        }

        let id: String = components[1]
        
        var colourAssignment: Array<Int>? = piColourAssignment[id]
        
        if colourAssignment == nil {
            colourAssignment = [1,1,1]
        }
        
    
        if let labelToUpdate = labelAssignment[id]{
            DispatchQueue.main.async {
                
                let newText: String = self.generateStatusLabelText(distance: distance, rssi: rssi)
                labelToUpdate.text = newText
            
            }
                
        }

        
        
        if let ipAddrAssignment = piIPAddrAssignment[id] {
            sendPacket(ipAddress: ipAddrAssignment, distance: distance, maxDistance: maxDistance, red: colourAssignment![0] * brightness, green: colourAssignment![1] * brightness, blue: colourAssignment![2] * brightness)
        }
        
    
    }
    
    func generateStatusLabelText(distance: Double, rssi: Double) -> String{
        let output: String = String(format: "%.2fm, %.0fdbm", distance, rssi)
        return output
    }
    
    
    func sendPacket(ipAddress: String, distance: Double, maxDistance: Double, red: Int, green: Int, blue: Int){
        
        do{
            

            
            var ledsToTurnOn: Int = Int(((maxDistance - distance) / maxDistance) * Double(NUM_LEDS))
        
            if ledsToTurnOn > NUM_LEDS {
                ledsToTurnOn = NUM_LEDS
            }

            
            let dataStr: String = String.localizedStringWithFormat("%d %d %d %d", ledsToTurnOn, red, green, blue)
 

            if let address: Socket.Address = Socket.createAddress(for: ipAddress, on: Int32(portNumber)){
                try sendSocket?.write(from: dataStr, to: address)
            }
            
            
        } catch {
            print("Error in sending \(error)")
        }
        
    }    

}

