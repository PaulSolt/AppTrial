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

//        let trial = TryMyApp()
//        do {
//            trial = try TryMyApp.loadSettings()
//        } catch {
//            
//        }
        
        
        let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        
        print("URL: \(url)")
    }

}

