//
//  ManualVC.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 10/9/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit
import ChromaColorPicker

let colourRange = 255.0
let maxBrightness = 10.0

class ManualVC: UIViewController{
    
    var piComm: PiComm!
    
    var leftColorPicker: ChromaColorPicker!
    var middleColorPicker: ChromaColorPicker!
    var rightColorPicker: ChromaColorPicker!
    
    //red, green, blue and numLEDs state
    var lastLeftState = [colourRange, colourRange, colourRange, 8]
    var lastMiddleState = [colourRange, colourRange, colourRange, 8]
    var lastRightState = [colourRange, colourRange, colourRange, 8]
    


    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftColorPicker = createColorPicker(xPos: 3, yPos: 10, valueChangedSelector: #selector(leftColourPickerValueChanged))
        view.addSubview(leftColorPicker)
        
        middleColorPicker = createColorPicker(xPos: 190, yPos: 10, valueChangedSelector: #selector(middleColourPickerValueChanged))
        view.addSubview(middleColorPicker)
        
        rightColorPicker = createColorPicker(xPos: 373, yPos: 10, valueChangedSelector: #selector(rightColourPickerValueChanged))
        view.addSubview(rightColorPicker)
        
        piComm = PiComm()
        piComm.openSocket()
    }
    
    func createColorPicker(xPos: Int, yPos: Int, valueChangedSelector: Selector) -> ChromaColorPicker{
        let colorPicker = ChromaColorPicker(frame: CGRect(x: xPos, y: yPos, width: 185, height: 185))
        colorPicker.padding = 0
        colorPicker.stroke = 15
        colorPicker.hexLabel.isHidden = true
        colorPicker.shadeSlider.isHidden = true
        colorPicker.addTarget(self, action: valueChangedSelector, for: UIControlEvents.valueChanged)
        return colorPicker
        
    }
    

    func leftColourPickerValueChanged(){
        let rgbColour = convertUIColorTo8bitRGB(color: leftColorPicker.currentColor)
        
        lastLeftState[0] = rgbColour.r
        lastLeftState[1] = rgbColour.g
        lastLeftState[2] = rgbColour.b
        
        print("Left: \(rgbColour)")
        updateLeftToNetwork()
    }
    
    func middleColourPickerValueChanged(){
        let rgbColour = convertUIColorTo8bitRGB(color: middleColorPicker.currentColor)
        
        lastMiddleState[0] = rgbColour.r
        lastMiddleState[1] = rgbColour.g
        lastMiddleState[2] = rgbColour.b
        
        print("Middle: \(rgbColour)")
        updateMiddleToNetwork()
    }
    
    func rightColourPickerValueChanged(){
        let rgbColour = convertUIColorTo8bitRGB(color: rightColorPicker.currentColor)
        
        lastRightState[0] = rgbColour.r
        lastRightState[1] = rgbColour.g
        lastRightState[2] = rgbColour.b
        
        print("Right: \(rgbColour)")
        updateRightToNetwork()
    }
    
    func updateLeftToNetwork(){
        prepareToSendToNetwork(id: leftMacAddress, ledsToTurnOn: Int(lastLeftState[3]), red: lastLeftState[0], green: lastLeftState[1], blue: lastLeftState[2])
    }
    
    func updateMiddleToNetwork(){
        prepareToSendToNetwork(id: middleMacAddress, ledsToTurnOn: Int(lastMiddleState[3]), red: lastMiddleState[0], green: lastMiddleState[1], blue: lastMiddleState[2])
    }
    
    func updateRightToNetwork(){
        prepareToSendToNetwork(id: rightMacAddress, ledsToTurnOn: Int(lastRightState[3]), red: lastRightState[0], green: lastRightState[1], blue: lastRightState[2])
    }
    
    
    func convertUIColorTo8bitRGB(color: UIColor) -> (r: Double, g: Double, b:Double){
        let cgColor = color.cgColor
        let redFloat = Double(cgColor.components![0])
        let greenFloat = Double(cgColor.components![1])
        let blueFloat = Double(cgColor.components![2])
        
        let red = colourRange * redFloat
        let green = colourRange * greenFloat
        let blue = colourRange * blueFloat
        
        return (r: red, g: green, b: blue)
    }
    
    func prepareToSendToNetwork(id: String, ledsToTurnOn: Int, red: Double, green: Double, blue: Double){
        
        let newRed = Int((red / colourRange) * maxBrightness)
        let newGreen = Int((green / colourRange) * maxBrightness)
        let newBlue = Int((blue / colourRange) * maxBrightness)
        
        piComm.sendPacket(id: id, ledsToTurnOn: ledsToTurnOn, red: newRed, green: newGreen, blue: newBlue)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        piComm.closeSocket()
    }
    

    
    
    
}
