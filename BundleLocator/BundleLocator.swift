//
//  BundleLocator.swift
//  Pictureflow
//
//  Created by Frank van Boheemen on 18/06/2019.
//  Copyright © 2019 Frank van Boheemen. All rights reserved.
//

import Cocoa

public enum BundleLocatorError: Swift.Error {
    case failedToLocateApplications(message: String)
}

class BundleLocator {
    
    let bundleURL: URL
    let applicationsURL: URL?
    let askToMoveUserDefaultsKey: String = "askToMoveBundle"
    let originalLocationUserDefaultsKey: String = "originalLocation"
    
    init() {
        self.bundleURL = Bundle.main.bundleURL
        if let path = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .localDomainMask, true).first {
            applicationsURL = URL(fileURLWithPath: path, isDirectory: true)
        } else {
            applicationsURL = nil
        }
    }
    
    func shouldMoveBundleToApplications() throws -> Bool {
        guard let applicationsURL = applicationsURL else {
            throw BundleLocatorError.failedToLocateApplications(message: "Can't locate Applications")
        }

        if bundleURL.deletingLastPathComponent() == applicationsURL {
            //Reset the UserDefaults Bool when the application is in Applications for future uses of this functionality.
            UserDefaults.standard.set(false, forKey: askToMoveUserDefaultsKey)
            return false
        }
        
        if FileManager.default.fileExists(atPath: applicationsURL.appendingPathComponent(bundleURL.lastPathComponent).path) {
            //It is possible to add closeBundleAndReopen(from url: URL) here to force opening the bundle already location in Applications
            return false
        }
        
        let askToMove = !UserDefaults.standard.bool(forKey: askToMoveUserDefaultsKey)
        
        return askToMove
    }
    
    func askToMoveBundle() {
        let result = presentAlert(title: "Do you want to move this App to 'Applications'?", message: "Explanation why this is needed", buttonTitle: "Move to 'Applications'", showCancel: true, alertStyle: .informational, showSuppressionButton: true)
        
        UserDefaults.standard.set(result.1, forKey: askToMoveUserDefaultsKey)
        
        if result.0 {
            copyBundle()
        } else {
            return
        }
    }
    
    private func copyBundle() {
        let paths = NSSearchPathForDirectoriesInDomains(.applicationDirectory, .localDomainMask, true)

        if let applicationDirectory = paths.first {
            let newURL = URL(fileURLWithPath: applicationDirectory, isDirectory: true).appendingPathComponent(bundleURL.lastPathComponent)
            print(newURL)
            do {
                try FileManager.default.copyItem(at: bundleURL, to: newURL)
            } catch let error as NSError {
                let title = error.localizedDescription
                _ = presentAlert(title: title, message: "Some explanation of the situation and how to remedy it", buttonTitle: "OK", showCancel: false, alertStyle: .critical, showSuppressionButton: false)
                return
            }

            UserDefaults.standard.set(bundleURL, forKey: originalLocationUserDefaultsKey)
            
            closeBundleAndReopen(from: newURL)

        }
    }
    
    private func closeBundleAndReopen(from url: URL) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = [url.path]
        task.launch()
        exit(0)
    }
    
    func removeOriginalBundleIfNeeded() {
        //Only remove original bundle when the bundle is originally copied to Applications.
        guard let url = UserDefaults.standard.url(forKey: originalLocationUserDefaultsKey),
            FileManager.default.fileExists(atPath: url.path)
            else {
                return
        }
        
        //This will throw an error when your application initialy is a read-only directory
        try? FileManager.default.removeItem(at: url)
        
        //Remove the original URL from UserDefaults to prevent this method for being executed on every launch
        UserDefaults.standard.set(nil, forKey: originalLocationUserDefaultsKey)
    }
    
    private func presentAlert(title: String, message: String, buttonTitle: String, showCancel: Bool, alertStyle: NSAlert.Style, showSuppressionButton: Bool) -> (Bool, Bool) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        
        alert.alertStyle = alertStyle
        alert.addButton(withTitle: buttonTitle)
        if showCancel {
            alert.addButton(withTitle: "Cancel")
        }
        alert.showsSuppressionButton = showSuppressionButton
    
        let result = (alert.runModal() == .alertFirstButtonReturn, alert.suppressionButton!.state == .on)
        
        return result
    }
}
