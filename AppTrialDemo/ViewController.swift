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
    lazy var trial = AppTrial()
    
    @IBOutlet weak var dateInstalled: NSTextField!
    @IBOutlet weak var dateExpired: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reloadDates()
    }
    
    func reloadDates() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium

        dateInstalled.stringValue = formatter.string(from: trial.dateInstalled())
        dateExpired.stringValue = formatter.string(from: trial.dateExpired())
    }
    
    override func viewDidAppear() {
        view.window?.center()
        
    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        trial.resetTrialPeriod()
        reloadDates()
    }
    
    @IBAction func expireTrialButtonPressed(_ sender: Any) {
        trial.expireTrial()
        reloadDates()
    }
    
    @IBAction func showDialogButtonPressed(_ sender: Any) {
        showDialog()
    }
    
    func showDialog() {
        let image = NSImage(named: "Icon256")!
        
        // let presenter = ...
        
//        let expireString = trial.daysRemaining()
        var expireMessage = "Super Easy Timer trial expires in \(trial.daysRemaining())."
        
        if trial.isExpired() {
            expireMessage = "Super Easy Timer is expired."
        }
        
        let model = Model(actionButtonTitle: "Open App Store",
                          cancelButtonTitle: "Try the App",
                          message: "Download the full app from the App Store",
                          image: image,
                          windowTitle: expireMessage)
        

        let shareView = ShareView(withModel: model, delegate: self)
        
        presentAsSheet(shareView)
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

extension ViewController: ShareViewDelegate {
    func shareView(didPressActionButton shareView: ShareView) {
        dismiss(shareView)
        
        // Do action here (or extend trial if they took action)
    }
    
    func shareView(didPressCancelButton shareView: ShareView) {
        dismiss(shareView)
    }
}
