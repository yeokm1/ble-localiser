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

class ManualVC: UIViewController{
    
    var piComm: PiComm!
    
    var leftColorPicker: ChromaColorPicker!
    var middleColorPicker: ChromaColorPicker!
    var rightColorPicker: ChromaColorPicker!
    
    let colourRange = 255.0
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftColorPicker = createColorPicker(xPos: 5, yPos: 10, valueChangedSelector: #selector(leftColourPickerValueChanged))
        view.addSubview(leftColorPicker)
        
        middleColorPicker = createColorPicker(xPos: 195, yPos: 10, valueChangedSelector: #selector(middleColourPickerValueChanged))
        view.addSubview(middleColorPicker)
        
        rightColorPicker = createColorPicker(xPos: 385, yPos: 10, valueChangedSelector: #selector(rightColourPickerValueChanged))
        view.addSubview(rightColorPicker)
        
        piComm = PiComm()
        piComm.openSocket()
    }
    
    func createColorPicker(xPos: Int, yPos: Int, valueChangedSelector: Selector) -> ChromaColorPicker{
        let colorPicker = ChromaColorPicker(frame: CGRect(x: xPos, y: yPos, width: 175, height: 175))
        colorPicker.padding = 0
        colorPicker.stroke = 15
        colorPicker.hexLabel.isHidden = true
        colorPicker.addTarget(self, action: valueChangedSelector, for: UIControlEvents.valueChanged)
        return colorPicker
        
    }
    

    
    func leftColourPickerValueChanged(){
        let rgbColour = convertUIColorTo8bitRGB(color: leftColorPicker.currentColor)
        print("Left: \(rgbColour)")
    }
    
    func middleColourPickerValueChanged(){
        let rgbColour = convertUIColorTo8bitRGB(color: middleColorPicker.currentColor)
        print("Middle: \(rgbColour)")
    }
    
    func rightColourPickerValueChanged(){
        let rgbColour = convertUIColorTo8bitRGB(color: rightColorPicker.currentColor)
        print("Right: \(rgbColour)")
    }
    
    
    func convertUIColorTo8bitRGB(color: UIColor) -> (r: Int, g: Int, b:Int){
        let cgColor = color.cgColor
        let redFloat = Double(cgColor.components![0])
        let greenFloat = Double(cgColor.components![1])
        let blueFloat = Double(cgColor.components![2])
        
        let red: Int = Int(colourRange * redFloat)
        let green: Int = Int(colourRange * greenFloat)
        let blue: Int = Int(colourRange * blueFloat)
        
        return (r: red, g: green, b: blue)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        piComm.closeSocket()
    }
    

    
    
    
}
