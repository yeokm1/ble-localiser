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

let LEDs_MIN = 0
let LEDs_DEFAULT = 32.0
let LEDS_MAX = 64.0

let BRIGHT_MIN = 0
let BRIGHT_DEFAULT = 50.0
let BRIGHT_MAX = 255



class ManualVC: UIViewController{
    
    var piComm: PiComm!
    
    var leftColorPicker: ChromaColorPicker!
    var middleColorPicker: ChromaColorPicker!
    var rightColorPicker: ChromaColorPicker!
    
    var leftNumLEDSlider: UISlider!
    var leftNumLEDLabel: UILabel!

    
    //red, green, blue and numLEDs state
    var lastLeftState: [Double] = [0, 0, 0, LEDs_DEFAULT, BRIGHT_DEFAULT]
    var lastMiddleState: [Double] = [0, 0, 0, LEDs_DEFAULT, BRIGHT_DEFAULT]
    var lastRightState: [Double] = [0, 0, 0, LEDs_DEFAULT, BRIGHT_DEFAULT]


    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftColorPicker = createColorPicker(xPos: 3, yPos: 10, valueChangedSelector: #selector(leftColourPickerValueChanged))
        view.addSubview(leftColorPicker)
        
        middleColorPicker = createColorPicker(xPos: 160, yPos: 10, valueChangedSelector: #selector(middleColourPickerValueChanged))
        view.addSubview(middleColorPicker)
        
        rightColorPicker = createColorPicker(xPos: 320, yPos: 10, valueChangedSelector: #selector(rightColourPickerValueChanged))
        view.addSubview(rightColorPicker)
        
        let leftNumLEDSliderAndLabel = createSliderAndLabel(xPos: 3, yPos: 200, minValue: 0, maxValue: 64, currentValue: 32, valueChangedSelector: #selector(leftLEDNumSliderValueChanged))
        leftNumLEDSlider = leftNumLEDSliderAndLabel.slider
        leftNumLEDLabel = leftNumLEDSliderAndLabel.label
        view.addSubview(leftNumLEDSlider)
        view.addSubview(leftNumLEDLabel)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        piComm = PiComm()
        piComm.openSocket()
        
        leftColourPickerValueChanged()
        middleColourPickerValueChanged()
        rightColourPickerValueChanged()
        
        updateLeftToNetwork()
        updateMiddleToNetwork()
        updateRightToNetwork()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        piComm.closeSocket()
    }
    
    
    func createSliderAndLabel(xPos: Int, yPos: Int, minValue: Float, maxValue: Float, currentValue: Int, valueChangedSelector: Selector) -> (slider: UISlider, label: UILabel){
        
        let label = UILabel(frame: CGRect(x: xPos, y: yPos, width: 30, height: 50))
        label.text = String(currentValue)
        
        let slider = UISlider(frame: CGRect(x: xPos + 30, y: yPos, width: 90, height: 50))
        
        slider.backgroundColor = UIColor.clear
        slider.minimumValue = minValue;
        slider.maximumValue = maxValue;
        slider.isContinuous = true;
        slider.value = Float(currentValue);
        slider.addTarget(self, action: valueChangedSelector, for: .valueChanged)
        
        return (slider: slider, label: label)
    }
    
    func createColorPicker(xPos: Int, yPos: Int, valueChangedSelector: Selector) -> ChromaColorPicker{
        let colorPicker = ChromaColorPicker(frame: CGRect(x: xPos, y: yPos, width: 160, height: 160))
        colorPicker.padding = 0
        colorPicker.stroke = 15
        colorPicker.hexLabel.isHidden = true
        colorPicker.shadeSlider.isHidden = true
        colorPicker.addTarget(self, action: valueChangedSelector, for: UIControlEvents.valueChanged)
        return colorPicker
        
    }
    

    func leftColourPickerValueChanged(){
        let rgbColour = convertUIColorToRGB(color: leftColorPicker.currentColor)
        
        lastLeftState[0] = rgbColour.r
        lastLeftState[1] = rgbColour.g
        lastLeftState[2] = rgbColour.b
        
        print("Left: \(rgbColour)")
        updateLeftToNetwork()
    }
    
    func middleColourPickerValueChanged(){
        let rgbColour = convertUIColorToRGB(color: middleColorPicker.currentColor)
        
        lastMiddleState[0] = rgbColour.r
        lastMiddleState[1] = rgbColour.g
        lastMiddleState[2] = rgbColour.b
        
        print("Middle: \(rgbColour)")
        updateMiddleToNetwork()
    }
    
    func rightColourPickerValueChanged(){
        let rgbColour = convertUIColorToRGB(color: rightColorPicker.currentColor)
        
        lastRightState[0] = rgbColour.r
        lastRightState[1] = rgbColour.g
        lastRightState[2] = rgbColour.b
        
        print("Right: \(rgbColour)")
        updateRightToNetwork()
    }
    
    func leftLEDNumSliderValueChanged(sender: UISlider){
        lastLeftState[3] = Double(sender.value)
        leftNumLEDLabel.text = String(Int(lastLeftState[3]))
        updateLeftToNetwork()
    }
    
    func updateLeftToNetwork(){
        prepareToSendToNetwork(id: leftMacAddress, ledsToTurnOn: Int(lastLeftState[3]), red: lastLeftState[0], green: lastLeftState[1], blue: lastLeftState[2], brightness: lastLeftState[4])
    }
    
    func updateMiddleToNetwork(){
        prepareToSendToNetwork(id: middleMacAddress, ledsToTurnOn: Int(lastMiddleState[3]), red: lastMiddleState[0], green: lastMiddleState[1], blue: lastMiddleState[2], brightness: lastMiddleState[4])
    }
    
    func updateRightToNetwork(){
        prepareToSendToNetwork(id: rightMacAddress, ledsToTurnOn: Int(lastRightState[3]), red: lastRightState[0], green: lastRightState[1], blue: lastRightState[2], brightness: lastRightState[4])
    }
    
    
    func convertUIColorToRGB(color: UIColor) -> (r: Double, g: Double, b:Double){
        let cgColor = color.cgColor
        let red = Double(cgColor.components![0])
        let green = Double(cgColor.components![1])
        let blue = Double(cgColor.components![2])
        
        return (r: red, g: green, b: blue)
    }
    
    func prepareToSendToNetwork(id: String, ledsToTurnOn: Int, red: Double, green: Double, blue: Double, brightness: Double){

        let newRed = Int(red * brightness)
        let newGreen = Int(green * brightness)
        let newBlue = Int(blue * brightness)
        
        piComm.sendPacket(id: id, ledsToTurnOn: ledsToTurnOn, red: newRed, green: newGreen, blue: newBlue)
     
    }
    
    
}
