//
//  ManualVC.swift
//  BLE Locator
//
//  Created by Yeo Kheng Meng on 10/9/17.
//  Copyright © 2017 Yeo Kheng Meng. All rights reserved.
//

import Foundation
import UIKit

class ManualVC: UIViewController{
    
    var piComm: PiComm!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        piComm = PiComm()
        piComm.openSocket()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        piComm.closeSocket()
    }
    
    
    
}
