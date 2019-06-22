//
//  AppDelegate.swift
//  BundleLocator
//
//  Created by Frank van Boheemen on 19/06/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var bundleLocator: BundleLocator?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        bundleLocator = BundleLocator()
        
        let shouldMove = try? bundleLocator?.shouldMoveBundleToApplications()
        
        if let shouldMove = shouldMove, shouldMove {
            bundleLocator?.askToMoveBundle()
        } else {
            bundleLocator?.removeOriginalBundleIfNeeded()
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        
        if let windowController = storyboard.instantiateController(withIdentifier: "Window") as? NSWindowController {
            windowController.loadWindow()
            windowController.showWindow(self)
        }

    }
}

