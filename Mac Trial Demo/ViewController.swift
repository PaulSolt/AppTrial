//
//  ViewController.swift
//  Mac Trial Demo
//
//  Created by Paul Solt on 12/8/18.
//  Copyright © 2018 Paul Solt. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


        
        let url = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        
        print("URL: \(url)")

    }



}

