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

let LEDs_MIN: Float = 0.0
let LEDs_DEFAULT: Float = 32.0
let LEDS_MAX: Float = 64.0

let BRIGHT_MIN: Float = 0.0
let BRIGHT_DEFAULT: Float = 50.0
let BRIGHT_MAX: Float = 255

class ManualVC: UIViewController{
    
    var piComm: PiComm!
    
    var leftColorPicker: ChromaColorPicker!
    var middleColorPicker: ChromaColorPicker!
    var rightColorPicker: ChromaColorPicker!
    
    var leftNumLEDSlider: UISlider!
    var leftNumLEDLabel: UILabel!
    var leftBrightSlider: UISlider!
    var leftBrightLabel: UILabel!
    
    var middleNumLEDSlider: UISlider!
    var middleNumLEDLabel: UILabel!
    var middleBrightSlider: UISlider!
    var middleBrightLabel: UILabel!
    
    var rightNumLEDSlider: UISlider!
    var rightNumLEDLabel: UILabel!
    var rightBrightSlider: UISlider!
    var rightBrightLabel: UILabel!
    
    
    //red, green, blue and numLEDs state
    var lastLeftState: [Float] = [0, 0, 0, LEDs_DEFAULT, BRIGHT_DEFAULT]
    var lastMiddleState: [Float] = [0, 0, 0, LEDs_DEFAULT, BRIGHT_DEFAULT]
    var lastRightState: [Float] = [0, 0, 0, LEDs_DEFAULT, BRIGHT_DEFAULT]


    
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
        
        let leftSliderAndLabel = createSlidersAndLabels(xPos: 3, yPos: 175, ledMinValue: LEDs_MIN, ledMaxValue: LEDS_MAX, ledCurrentValue: LEDs_DEFAULT, ledValueChangedSelector: #selector(leftLEDNumSliderValueChanged), brightMinValue: BRIGHT_MIN, brightMaxValue: BRIGHT_MAX, brightCurrentValue: BRIGHT_DEFAULT, brightValueChangedSelector: #selector(leftBrightSlidervalueChanged))
        
        leftNumLEDSlider = leftSliderAndLabel.ledNumSlider
        leftNumLEDLabel = leftSliderAndLabel.ledNumLabel
        
        leftBrightSlider = leftSliderAndLabel.brightNumSlider
        leftBrightLabel = leftSliderAndLabel.brightNumLabel
        
        view.addSubview(leftNumLEDSlider)
        view.addSubview(leftNumLEDLabel)
        view.addSubview(leftBrightSlider)
        view.addSubview(leftBrightLabel)
        
        
        let middleSliderAndLabel = createSlidersAndLabels(xPos: 160, yPos: 175, ledMinValue: LEDs_MIN, ledMaxValue: LEDS_MAX, ledCurrentValue: LEDs_DEFAULT, ledValueChangedSelector: #selector(middleLEDNumSliderValueChanged), brightMinValue: BRIGHT_MIN, brightMaxValue: BRIGHT_MAX, brightCurrentValue: BRIGHT_DEFAULT, brightValueChangedSelector: #selector(middleBrightSlidervalueChanged))
        
        middleNumLEDSlider = middleSliderAndLabel.ledNumSlider
        middleNumLEDLabel = middleSliderAndLabel.ledNumLabel
        
        middleBrightSlider = middleSliderAndLabel.brightNumSlider
        middleBrightLabel = middleSliderAndLabel.brightNumLabel
        
        view.addSubview(middleNumLEDSlider)
        view.addSubview(middleNumLEDLabel)
        view.addSubview(middleBrightSlider)
        view.addSubview(middleBrightLabel)
        
        
        let rightSliderAndLabel = createSlidersAndLabels(xPos: 320, yPos: 175, ledMinValue: LEDs_MIN, ledMaxValue: LEDS_MAX, ledCurrentValue: LEDs_DEFAULT, ledValueChangedSelector: #selector(rightLEDNumSliderValueChanged), brightMinValue: BRIGHT_MIN, brightMaxValue: BRIGHT_MAX, brightCurrentValue: BRIGHT_DEFAULT, brightValueChangedSelector: #selector(rightBrightSlidervalueChanged))
        
        rightNumLEDSlider = rightSliderAndLabel.ledNumSlider
        rightNumLEDLabel = rightSliderAndLabel.ledNumLabel
        
        rightBrightSlider = rightSliderAndLabel.brightNumSlider
        rightBrightLabel = rightSliderAndLabel.brightNumLabel
        
        view.addSubview(rightNumLEDSlider)
        view.addSubview(rightNumLEDLabel)
        view.addSubview(rightBrightSlider)
        view.addSubview(rightBrightLabel)
        
        let numLEDsLabel = UILabel(frame: CGRect(x: 120, y: 150, width: 100, height: 50))
        numLEDsLabel.text = "Num LEDs"
        view.addSubview(numLEDsLabel)
        
        let brightnessLabel = UILabel(frame: CGRect(x: 120, y: 200, width: 100, height: 50))
        brightnessLabel.text = "Brightness"
        view.addSubview(brightnessLabel)
        
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
    
    
    func createSlidersAndLabels(xPos: Int,
                                yPos: Int,
                                ledMinValue: Float,
                                ledMaxValue: Float,
                                ledCurrentValue: Float,
                                ledValueChangedSelector: Selector,
                                
                                brightMinValue: Float,
                                brightMaxValue: Float,
                                brightCurrentValue: Float,
                                brightValueChangedSelector: Selector)
        -> (ledNumSlider: UISlider, ledNumLabel: UILabel, brightNumSlider: UISlider, brightNumLabel: UILabel){
        
        let ledNumLabel = UILabel(frame: CGRect(x: xPos, y: yPos, width: 35, height: 50))
        
        // We want to strip away the decimal point
        ledNumLabel.text = String(Int(ledCurrentValue))
        
        let ledNumSlider = UISlider(frame: CGRect(x: xPos + 30, y: yPos, width: 90, height: 50))
        
        ledNumSlider.backgroundColor = UIColor.clear
        ledNumSlider.minimumValue = ledMinValue;
        ledNumSlider.maximumValue = ledMaxValue;
        ledNumSlider.isContinuous = true;
        ledNumSlider.value = ledCurrentValue;
        ledNumSlider.addTarget(self, action: ledValueChangedSelector, for: .valueChanged)

        
        let brightNumLabel = UILabel(frame: CGRect(x: xPos, y: yPos + 50, width: 35, height: 50))
        
        // We want to strip away the decimal point
        brightNumLabel.text = String(Int(brightCurrentValue))
        
        let brightNumSlider = UISlider(frame: CGRect(x: xPos + 30, y: yPos + 50, width: 90, height: 50))
        
        brightNumSlider.backgroundColor = UIColor.clear
        brightNumSlider.minimumValue = brightMinValue;
        brightNumSlider.maximumValue = brightMaxValue;
        brightNumSlider.isContinuous = true;
        brightNumSlider.value = brightCurrentValue;
        brightNumSlider.addTarget(self, action: brightValueChangedSelector, for: .valueChanged)
        
        return (ledNumSlider: ledNumSlider, ledNumLabel: ledNumLabel, brightNumSlider: brightNumSlider, brightNumLabel: brightNumLabel)
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
    

    @objc func leftColourPickerValueChanged(){
        let rgbColour = convertUIColorToRGB(color: leftColorPicker.currentColor)
        
        lastLeftState[0] = rgbColour.r
        lastLeftState[1] = rgbColour.g
        lastLeftState[2] = rgbColour.b
        
        print("Left: \(rgbColour)")
        updateLeftToNetwork()
    }
    
    @objc func middleColourPickerValueChanged(){
        let rgbColour = convertUIColorToRGB(color: middleColorPicker.currentColor)
        
        lastMiddleState[0] = rgbColour.r
        lastMiddleState[1] = rgbColour.g
        lastMiddleState[2] = rgbColour.b
        
        print("Middle: \(rgbColour)")
        updateMiddleToNetwork()
    }
    
    @objc func rightColourPickerValueChanged(){
        let rgbColour = convertUIColorToRGB(color: rightColorPicker.currentColor)
        
        lastRightState[0] = rgbColour.r
        lastRightState[1] = rgbColour.g
        lastRightState[2] = rgbColour.b
        
        print("Right: \(rgbColour)")
        updateRightToNetwork()
    }
    
    @objc func leftLEDNumSliderValueChanged(sender: UISlider){
        lastLeftState[3] = Float(sender.value)
        leftNumLEDLabel.text = String(Int(lastLeftState[3]))
        updateLeftToNetwork()
    }
    
    @objc func leftBrightSlidervalueChanged(sender: UISlider){
        lastLeftState[4] = Float(sender.value)
        leftBrightLabel.text = String(Int(lastLeftState[4]))
        updateLeftToNetwork()
    }
    
    
    @objc func middleLEDNumSliderValueChanged(sender: UISlider){
        lastMiddleState[3] = Float(sender.value)
        middleNumLEDLabel.text = String(Int(lastMiddleState[3]))
        updateMiddleToNetwork()
    }
    
    @objc func middleBrightSlidervalueChanged(sender: UISlider){
        lastMiddleState[4] = Float(sender.value)
        middleBrightLabel.text = String(Int(lastMiddleState[4]))
        updateMiddleToNetwork()
    }
    
    @objc func rightLEDNumSliderValueChanged(sender: UISlider){
        lastRightState[3] = Float(sender.value)
        rightNumLEDLabel.text = String(Int(lastRightState[3]))
        updateRightToNetwork()
    }
    
    @objc func rightBrightSlidervalueChanged(sender: UISlider){
        lastRightState[4] = Float(sender.value)
        rightBrightLabel.text = String(Int(lastRightState[4]))
        updateRightToNetwork()
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
    
    
    func convertUIColorToRGB(color: UIColor) -> (r: Float, g: Float, b: Float){
        let cgColor = color.cgColor
        let red = Float(cgColor.components![0])
        let green = Float(cgColor.components![1])
        let blue = Float(cgColor.components![2])
        
        return (r: red, g: green, b: blue)
    }
    
    func prepareToSendToNetwork(id: String, ledsToTurnOn: Int, red: Float, green: Float, blue: Float, brightness: Float){

        let newRed = Int(red * brightness)
        let newGreen = Int(green * brightness)
        let newBlue = Int(blue * brightness)
        
        piComm.sendPacket(id: id, ledsToTurnOn: ledsToTurnOn, red: newRed, green: newGreen, blue: newBlue)
     
    }
    
    
}
