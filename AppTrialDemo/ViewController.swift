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

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        dateInstalled.stringValue = formatter.string(from: trial.dateInstalled())
        dateExpired.stringValue = formatter.string(from: trial.dateExpired())
        
        
        if trial.isExpired() {
            print("Expired Trial: \(trial.dateExpired())\n Now \(Date())")
            print("The Super Easy Timer trial period has expired.")
        } else {
            
//            print("The trial expires in \(trial.daysRemaining()) days")
            
            print("Not expired: \(trial.dateExpired())\n Now: \(Date())")
        }
        
        
//        view.translatesAutoresizingMaskIntoConstraints = false

    }
    
    override func viewDidAppear() {
        view.window?.center()
        
//        showDialog()
        
//        showAlert()
    }
    
    func saveExpired() {
        let trialSettings = TrialSettings(dateInstalled: Date(timeIntervalSinceNow: -1), trialPeriodInDays: 0)
        try? trial.saveSettings(settings: trialSettings)
    }
    
    func saveFreshInstall() {
        let trialSettings = TrialSettings(dateInstalled: Date(), trialPeriodInDays: 7)
        try? trial.saveSettings(settings: trialSettings)
    }
    
    
    func showDialog() {
        let image = NSImage(named: "Icon256")!
        
        // let presenter = ...
        
        let expireString = trial.daysRemaining()
        
        let model = Model(actionButtonTitle: "Share on Facebook",
                          cancelButtonTitle: "No Thanks",
                          message: "Share via Facebook to extend your trial by 7 days",
                          image: image,
                          windowTitle: "Super Eays Timer trial expires in \(expireString)")
        

        let shareView = ShareView(withModel: model, delegate: self)
        
//        presentAsSheet(shareView)
        presentAsModalWindow(shareView)
//        present(shareView, animator: NSViewController.TransitionOptions.crossfade)
            //(shareView)

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
        // TODO: share on social
        // TODO: extend the beta
        if trial.totalDays() < 21 {
            trial.extendTrial(byAdding: 7)
        }
        dismiss(shareView)
    }
    
    func shareView(didPressCancelButton shareView: ShareView) {
        dismiss(shareView)
    }
    
    
}
