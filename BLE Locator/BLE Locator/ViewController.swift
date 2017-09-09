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

let initialDistanceFromPis = 0.6

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
    @IBOutlet weak var currentPositionLabel: UILabel!
    
    let positionLabelSize: Double = 20
    
    let maximumCirclePixelDiameter: Double = 250
    
    let rpiWidth: Double = 20
    let rpiHeight: Double = 10
    let pixelsPerMeter: Double = 60

    

    let piColourAssignment: Dictionary<String, Array<Int>> = [redMacAddress: [1,0,0], greenMacAddress: [0, 1, 0], blueMacAddress: [0, 0, 1]]
    let piIPAddrAssignment: Dictionary<String, String> = [redMacAddress: "192.168.2.19", greenMacAddress: "192.168.2.162", blueMacAddress: "192.168.2.186"]
    
    let piPositionAssignment: Dictionary<String, Array<Double>> = [redMacAddress: [0, 0.435], greenMacAddress: [-0.5, -0.435], blueMacAddress: [0.5, -0.435]]
    
    var labelAssignment: Dictionary<String, UILabel> = Dictionary<String, UILabel>()
    
    var circleAssignment: Dictionary<String, UIView> = Dictionary<String, UIView>()
    
    
    var distanceFromPis: Dictionary<String, Double> = [redMacAddress: initialDistanceFromPis, greenMacAddress: initialDistanceFromPis, blueMacAddress: initialDistanceFromPis]
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleScanSwitch.addTarget(self, action: #selector(bleScanSwitchValueDidChange), for: .valueChanged)
        brightnessStepper.addTarget(self, action: #selector(brightnessStepperValueDidChange), for: .valueChanged)
        
        maxDistanceSlider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)

        labelAssignment[redMacAddress] = redStatusLabel
        labelAssignment[greenMacAddress] = greenStatusLabel
        labelAssignment[blueMacAddress] = blueStatusLabel
        
        brightnessStepperValueDidChange(sender: brightnessStepper)
        distanceSliderValueDidChange(sender: maxDistanceSlider)
        
        
        let redPiView = createRPiView(xPosM: piPositionAssignment[redMacAddress]![0], yPosM: piPositionAssignment[redMacAddress]![1], colour: UIColor.red)
        mapOfBeaconsView.addSubview(redPiView)
        
        let greenPiView = createRPiView(xPosM: piPositionAssignment[greenMacAddress]![0], yPosM: piPositionAssignment[greenMacAddress]![1], colour: UIColor.green)
        mapOfBeaconsView.addSubview(greenPiView)
        
        let bluePiView = createRPiView(xPosM: piPositionAssignment[blueMacAddress]![0], yPosM: piPositionAssignment[blueMacAddress]![1], colour: UIColor.blue)
        mapOfBeaconsView.addSubview(bluePiView)
        
   
        
        let redDistanceCircle = createCircleView(id: redMacAddress, radius: distanceFromPis[redMacAddress]!, colour: UIColor.red)
        circleAssignment[redMacAddress] = redDistanceCircle
        mapOfBeaconsView.addSubview(redDistanceCircle)
        
        let greenDistanceCircle = createCircleView(id: greenMacAddress, radius: distanceFromPis[greenMacAddress]!, colour: UIColor.green)
        circleAssignment[greenMacAddress] = greenDistanceCircle
        mapOfBeaconsView.addSubview(greenDistanceCircle)
        
        let blueDistanceCircle = createCircleView(id: blueMacAddress, radius: distanceFromPis[blueMacAddress]!, colour: UIColor.blue)
        circleAssignment[blueMacAddress] = blueDistanceCircle
        mapOfBeaconsView.addSubview(blueDistanceCircle)
        
        placePositionLabel(xPosM: 0, yPosM: 0)
        
        updateUIWithNewdata(id: redMacAddress, distance: initialDistanceFromPis, rssi: -100)
        updateUIWithNewdata(id: greenMacAddress, distance: initialDistanceFromPis, rssi: -100)
        updateUIWithNewdata(id: blueMacAddress, distance: initialDistanceFromPis, rssi: -100)
    
        
        
        //Start BLEHandler and ask it to pass callbacks to UI (here)
        bleHandler = BLEHandler(delegate: self)
        
        do {
            sendSocket = try Socket.create(family: Socket.ProtocolFamily.inet, type: Socket.SocketType.datagram, proto: Socket.SocketProtocol.udp)
        } catch {
            print("Error creating socket \(error)")
        }
    
        
    }
    
    func placePositionLabel(xPosM: Double, yPosM: Double){
        
        let centeredCoord = generatePositionBasedOnCenterOfMap(xPosM: xPosM, yPosM: yPosM)
        
        let newFramePosition = CGRect(x: centeredCoord.0 - (positionLabelSize / 2), y: centeredCoord.1 - (positionLabelSize / 2), width: positionLabelSize, height: positionLabelSize)
        
        
        currentPositionLabel.frame = newFramePosition
        
    }
    
    func createCircleView(id: String, radius: Double, colour: UIColor) -> UIView {
        
        let circleData = generateCGRectForCircle(id: id, radius: radius)
        
        let circle = UIView(frame: circleData.rect)
        
        circle.layer.cornerRadius = circleData.cornerRadius
        circle.backgroundColor = colour
        circle.alpha = 0.1
        circle.clipsToBounds = true
    
        
        return circle
    }
    
    func generateCGRectForCircle(id: String, radius: Double) -> (rect: CGRect, cornerRadius: CGFloat){
        let xPosM = piPositionAssignment[id]![0]
        let yPosM = piPositionAssignment[id]![1]

        let centeredCoord = generatePositionBasedOnCenterOfMap(xPosM: xPosM, yPosM: yPosM)
        var pixelDiameter = radius * 2 * pixelsPerMeter
        
        if pixelDiameter > maximumCirclePixelDiameter {
            pixelDiameter = maximumCirclePixelDiameter
        }
        
        let rect = CGRect(x: centeredCoord.0 - (pixelDiameter / 2), y: centeredCoord.1 - (pixelDiameter / 2), width: pixelDiameter, height: pixelDiameter)
        
        return (rect: rect, cornerRadius: CGFloat(pixelDiameter / 2))
    }
    
    func generatePositionBasedOnCenterOfMap(xPosM: Double, yPosM: Double) -> (Double, Double){
        //Our coordinate system assumes origin is bottom left however UIView is based on top left
        //y coordinate has to be adjusted as a result
        return (Double(mapOfBeaconsView.frame.width / 2) + (xPosM * pixelsPerMeter), Double(mapOfBeaconsView.frame.height) - (Double(mapOfBeaconsView.frame.height / 2) + (yPosM * pixelsPerMeter)))
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
    
    func updateUIWithNewdata(id: String, distance: Double, rssi: Double){
        
        if let labelToUpdate = labelAssignment[id]{
            let newText: String = generateStatusLabelText(distance: distance, rssi: rssi)
            labelToUpdate.text = newText
        }
        
        distanceFromPis[id] = distance
        
        if let circleView = circleAssignment[id]{
            let newCircleData = generateCGRectForCircle(id: id, radius: distance)
            circleView.frame = newCircleData.rect
            circleView.layer.cornerRadius = newCircleData.cornerRadius
        }
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
        

        DispatchQueue.main.async {
            self.updateUIWithNewdata(id: id, distance: distance, rssi: rssi)
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

