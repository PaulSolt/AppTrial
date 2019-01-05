//
//  ViewController.swift
//  AppTrialDemo
//
//  Created by Paul Solt on 12/18/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import Cocoa
import AppTrial

class ViewController: NSViewController {

    var trial = AppTrial()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if trial.isExpired() {
            print("Expired Trial: \(trial.dateExpired())\n Now \(Date())")
        } else {
            print("The trial expires in \(trial.daysRemaining) days")
            print("Not expired: \(trial.dateExpired())\n Now: \(Date())")
        }
        
//        trial.sett
    }

}

