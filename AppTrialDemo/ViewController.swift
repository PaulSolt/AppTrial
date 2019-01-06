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
            print("The trial expires in \(trial.daysRemaining()) days")
            print("Not expired: \(trial.dateExpired())\n Now: \(Date())")
        }
        
//        view.translatesAutoresizingMaskIntoConstraints = false

    }
    
    override func viewDidAppear() {
        showDialog()
        
//        showAlert()
    }
    
    
    
    func showDialog() {
        let image = NSImage(named: "Icon256")!
        
        let model = Model(actionButtonTitle: "Share on Facebook",
                          cancelButtonTitle: "No Thanks",
                          message: "Share via Facebook to extend your trial by 7 days",
                          image: image,
                          windowTitle: "Super Easy Timer Expires in \(trial.daysRemaining()) days.")
        

        let shareView = ShareView(withModel: model)
        
        
        presentAsModalWindow(shareView)

    }

    func showAlert() {
        let a: NSAlert = NSAlert()
        a.messageText = "Delete the document?"
        a.informativeText = "Are you sure you would like to delete the document?"
        a.addButton(withTitle: "Delete")
        a.addButton(withTitle: "Cancel")
        a.alertStyle = NSAlert.Style.warning
        a.icon = NSImage(named: "Icon256")!
        
        a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse: NSApplication.ModalResponse) -> Void in
            if(modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn){
                print("Document deleted")
            }
        })
    }
    
}

