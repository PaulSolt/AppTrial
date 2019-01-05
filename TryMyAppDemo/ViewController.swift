//
//  ViewController.swift
//  TryMyAppDemo
//
//  Created by Paul Solt on 12/18/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import Cocoa
import TryMyApp

class ViewController: NSViewController {

    var trial = TryMyApp()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if trial.isExpired() {
            print("Expired Trial: \(trial.dateExpired())\n Now \(Date())")
        } else {
            print("Not expired: \(trial.dateExpired())\n Now: \(Date())")
        }
        
//        trial.sett
    }

}

