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

let initialDistanceFromPis = 0.6

class ViewController: UIViewController, BLEHandlerDelegate{
    
    let TAG: String = "ViewController"
    let NUM_LEDS: Int = 64
    
    var bleHandler: BLEHandler!
    
    
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
    
    let maximumCirclePixelDiameter: Double = 200
    
    let rpiWidth: Double = 20
    let rpiHeight: Double = 10
    let pixelsPerMeter: Double = 50

//    let piPositionAssignment: Dictionary<String, Array<Double>> = [middleMacAddress: [0, 0.435], leftMacAddress: [-0.5, -0.435], rightMacAddress: [0.5, -0.435]]
    
    let piPositionAssignment: Dictionary<String, Array<Double>> = [middleMacAddress: [0, 0.87], leftMacAddress: [-1, -0.87], rightMacAddress: [1, -0.87]]
    
    let piColourAssignment: Dictionary<String, Array<Int>> = [middleMacAddress: [1,0,0], leftMacAddress: [0, 1, 0], rightMacAddress: [0, 0, 1]]
    
    var labelAssignment: Dictionary<String, UILabel> = Dictionary<String, UILabel>()
    
    var circleAssignment: Dictionary<String, UIView> = Dictionary<String, UIView>()
    
    
    var distanceFromPis: Dictionary<String, Double> = [middleMacAddress: initialDistanceFromPis, leftMacAddress: initialDistanceFromPis, rightMacAddress: initialDistanceFromPis]
    
    var piComm: PiComm!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bleScanSwitch.addTarget(self, action: #selector(bleScanSwitchValueDidChange), for: .valueChanged)
        brightnessStepper.addTarget(self, action: #selector(brightnessStepperValueDidChange), for: .valueChanged)
        
        maxDistanceSlider.addTarget(self, action: #selector(distanceSliderValueDidChange), for: .valueChanged)

        labelAssignment[middleMacAddress] = redStatusLabel
        labelAssignment[leftMacAddress] = greenStatusLabel
        labelAssignment[rightMacAddress] = blueStatusLabel
        
        brightnessStepperValueDidChange(sender: brightnessStepper)
        distanceSliderValueDidChange(sender: maxDistanceSlider)
        
        
        let redPiView = createRPiView(xPosM: piPositionAssignment[middleMacAddress]![0], yPosM: piPositionAssignment[middleMacAddress]![1], colour: UIColor.red)
        mapOfBeaconsView.addSubview(redPiView)
        
        let greenPiView = createRPiView(xPosM: piPositionAssignment[leftMacAddress]![0], yPosM: piPositionAssignment[leftMacAddress]![1], colour: UIColor.green)
        mapOfBeaconsView.addSubview(greenPiView)
        
        let bluePiView = createRPiView(xPosM: piPositionAssignment[rightMacAddress]![0], yPosM: piPositionAssignment[rightMacAddress]![1], colour: UIColor.blue)
        mapOfBeaconsView.addSubview(bluePiView)
        
   
        
        let redDistanceCircle = createCircleView(id: middleMacAddress, radius: distanceFromPis[middleMacAddress]!, colour: UIColor.red)
        circleAssignment[middleMacAddress] = redDistanceCircle
        mapOfBeaconsView.addSubview(redDistanceCircle)
        
        let greenDistanceCircle = createCircleView(id: leftMacAddress, radius: distanceFromPis[leftMacAddress]!, colour: UIColor.green)
        circleAssignment[leftMacAddress] = greenDistanceCircle
        mapOfBeaconsView.addSubview(greenDistanceCircle)
        
        let blueDistanceCircle = createCircleView(id: rightMacAddress, radius: distanceFromPis[rightMacAddress]!, colour: UIColor.blue)
        circleAssignment[rightMacAddress] = blueDistanceCircle
        mapOfBeaconsView.addSubview(blueDistanceCircle)
        
        placePositionLabel(xPosM: 0, yPosM: 0)
        
        updateUIWithNewdata(id: middleMacAddress, distance: initialDistanceFromPis, rssi: -100)
        updateUIWithNewdata(id: leftMacAddress, distance: initialDistanceFromPis, rssi: -100)
        updateUIWithNewdata(id: rightMacAddress, distance: initialDistanceFromPis, rssi: -100)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        piComm = PiComm()
        
        piComm.openSocket()
        
        //Start BLEHandler and ask it to pass callbacks to UI (here)
        bleScanSwitch.isOn = false
        
        bleHandler = BLEHandler(delegate: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        piComm.closeSocket()
        piComm = nil
        bleHandler.bleScan(start: false)
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
    
    //Our coordinate system assumes origin is the center however UIView is based on top left
    //x and y coordinates has to be adjusted as a result
    func generatePositionBasedOnCenterOfMap(xPosM: Double, yPosM: Double) -> (Double, Double){
        
        let newCoord = (Double(mapOfBeaconsView.frame.width / 2) + (xPosM * pixelsPerMeter)
            
            , Double(mapOfBeaconsView.frame.height) - (Double(mapOfBeaconsView.frame.height / 2)
            + (yPosM * pixelsPerMeter)))
        
        return newCoord
    }
    
    func createRPiView(xPosM: Double, yPosM: Double, colour: UIColor) -> UIView {
        
        let centeredCoord = generatePositionBasedOnCenterOfMap(xPosM: xPosM, yPosM: yPosM)
        
        let newView = UIView(frame: CGRect(x: centeredCoord.0 - (rpiWidth / 2), y: centeredCoord.1 - (rpiHeight / 2), width: rpiWidth, height: rpiHeight))

        newView.backgroundColor = colour
        
        return newView
        
    }
    
    @objc func bleScanSwitchValueDidChange(sender:UISwitch) {
        
        if sender.isOn {
            bleHandler.bleScan(start: true)
        } else {
            bleHandler.bleScan(start: false)
        }

    }
    
    
    @objc func brightnessStepperValueDidChange(sender: UIStepper){
        brightness = Int(sender.value)
        brightnessValueLabel.text = String(brightness)
    }
    
    
    @objc func distanceSliderValueDidChange(sender: UISlider){
        maxDistance = Double(sender.value)
        maxDistanceValueLabel.text = String(format: "%.1f", maxDistance)
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
        
        
        let newPosition = trilateration(x1: piPositionAssignment[middleMacAddress]![0],
                                        y1: piPositionAssignment[middleMacAddress]![1],
                                        d1: distanceFromPis[middleMacAddress]!,
                                        x2: piPositionAssignment[leftMacAddress]![0],
                                        y2: piPositionAssignment[leftMacAddress]![1],
                                        d2: distanceFromPis[leftMacAddress]!,
                                        x3: piPositionAssignment[rightMacAddress]![0],
                                        y3: piPositionAssignment[rightMacAddress]![1],
                                        d3: distanceFromPis[rightMacAddress]!)
        
        
        placePositionLabel(xPosM: newPosition.xPos, yPosM: newPosition.yPos)
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

        let ledsToTurnOn: Int = Int(((maxDistance - distance) / maxDistance) * Double(NUM_LEDS))


        let redValue = colourAssignment![0] * brightness
        let greenValue = colourAssignment![1] * brightness
        let blueValue = colourAssignment![2] * brightness
        
        piComm.sendPacket(id: id, ledsToTurnOn: ledsToTurnOn, red: redValue, green: greenValue, blue: blueValue)
    
    }
    
    func generateStatusLabelText(distance: Double, rssi: Double) -> String{
        let output: String = String(format: "%.2fm, %.0fdbm", distance, rssi)
        return output
    }
    
    

}

