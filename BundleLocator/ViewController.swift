//
//  ViewController.swift
//  BundleLocator
//
//  Created by Frank van Boheemen on 19/06/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.stringValue = "\(Bundle.main.bundleURL)"
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

