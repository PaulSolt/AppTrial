//
//  ShareView.swift
//  AppTrialDemo
//
//  Created by Paul Solt on 1/6/19.
//  Copyright © 2019 Paul Solt. All rights reserved.
//

import Cocoa

struct Model {
    var actionButtonTitle: String
    var cancelButtonTitle: String
    var message: String
    var image: NSImage
    var windowTitle: String
    
    init(actionButtonTitle: String, cancelButtonTitle: String,
         message: String, image: NSImage, windowTitle: String) {
        self.actionButtonTitle = actionButtonTitle
        self.cancelButtonTitle = cancelButtonTitle
        self.message = message
        self.image = image
        self.windowTitle = windowTitle
    }
}

protocol ShareViewDelegate {
    func shareView(didPressActionButton shareView: ShareView)
    func shareView(didPressCancelButton shareView: ShareView)
}

class ShareView: NSViewController {
    let defaultSize = NSRect(x: 0, y: 0, width: 220, height: 300)
    let defaultButtonWithReturnKey = "\r"
    let titleFontSize: CGFloat = 20
    
    var model: Model
    var delegate: ShareViewDelegate?
    
    var titleLabel: NSTextField!
    var imageView: NSImageView!
    var messageLabel: NSTextField!
    var actionButton: NSButton!
    var cancelButton: NSButton!
    
    init(withModel model: Model, delegate: ShareViewDelegate? = nil) {
        self.model = model
        self.delegate = delegate
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    override func loadView() {
        view = NSView(frame: defaultSize)
        //let mask: [NSWindow.StyleMask] = []
     
        
        updateUI(withModel: model)
    }
    
    
    override func viewDidAppear() {
        if let window = view.window {
            window.styleMask = [.borderless] //.remove(.resizable, .)
            window.isMovable = true
            window.isMovableByWindowBackground = true
            window.center()
        }
        
        
        super.viewDidAppear()
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {


    }
    
    fileprivate func updateUI(withModel model: Model) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        title = model.windowTitle
        titleLabel = createTitleLabel(withTitle: model.windowTitle)
        messageLabel = createMessageLabel(withMessage: model.message)
        actionButton = createActionButton(withTitle: model.actionButtonTitle)
        cancelButton = createCancelButton(withTitle: model.cancelButtonTitle)
        
        imageView = createImageView(withImage: model.image)
        //        actionButton.
//        view.addSubview(actionButton)
        
//        actionButton.pin(to: view, margin: 20)
        
        let buttonPanel = NSStackView(views: [actionButton, cancelButton])
        buttonPanel.orientation = .vertical
        buttonPanel.distribution = .fill
        buttonPanel.spacing = 8
        
//        actionButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1.0)
        
        let stackView = NSStackView(views: [imageView,
                                            titleLabel,
                                            messageLabel,
                                            buttonPanel,
                                            ])
        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.alignment = .centerX
        stackView.spacing = 20
        
        view.addSubview(stackView)
        
        imageView.pinAspectRatio(1.0, width: 128)
        actionButton.pinEqualWidths(to: [cancelButton])
        stackView.pin(to: view, margin: 20)

        
//        view.window?.contentLayoutGuide
//        let defaultSpacing: CGFloat = 20
//        let margins = view.layoutGuides.first

//        view.pin(to: stackView, margin: 20)
//        stackView.pin(to: view, margin: 20)
    }
    
    fileprivate func createImageView(withImage image: NSImage) -> NSImageView {
        let imageView = NSImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }
    
    fileprivate func createTitleLabel(withTitle title: String) -> NSTextField {
        let label = NSTextField.init(labelWithString: title)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.boldSystemFont(ofSize: titleFontSize)
        label.alignment = .center
        return label
    }

    fileprivate func createMessageLabel(withMessage message: String) -> NSTextField {
        let label = NSTextField.init(wrappingLabelWithString: message)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alignment = .center
        return label
    }
    
    fileprivate func createActionButton(withTitle title: String) -> NSButton {
        let button = NSButton(title: title, target: self, action: #selector(actionButtonPressed(_:)))
        button.keyEquivalent = defaultButtonWithReturnKey
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func actionButtonPressed(_ sender: NSButton) {
        print("Action")
        delegate?.shareView(didPressActionButton: self)
    }
    
    fileprivate func createCancelButton(withTitle title: String) -> NSButton {
        let button = NSButton(title: title, target: self, action: #selector(cancelButtonPressed(_:)))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc func cancelButtonPressed(_ sender: NSButton) {
        print("Cancel")
        delegate?.shareView(didPressCancelButton: self)
    }
}

public extension NSView {
    public func pin(to view: NSView, margin: CGFloat) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -margin),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            ])
    }
    
    public func pinEqualWidths(to views: [NSView]) {
        guard !views.isEmpty else { return }
        
        var constraints: [NSLayoutConstraint] = []
        
        for view in views {
            let constraint = widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0)
            constraints.append(constraint)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    public func pinAspectRatio(_ ratio: CGFloat, width: CGFloat) {
    
        NSLayoutConstraint.activate([
            NSLayoutConstraint.init(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0.0),
            widthAnchor.constraint(equalToConstant: width)
            ])
    }
}
