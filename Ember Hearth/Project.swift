//
//  Project.swift
//  Ember Hearth
//
//  Created by Thomas Sunde Nielsen on 30.03.15.
//  Copyright (c) 2015 Thomas Sunde Nielsen. All rights reserved.
//

import Cocoa

enum ServerStatus {
    case running
    case stopped
    case booting
    case errored
}

class Project: Equatable {
    var name: String?
    var path: String?
    var serverTask: NSTask?
    var serverStatus = ServerStatus.stopped {
        didSet {
            let postName: String
            let userNotificationTitle: String?
            let userNotificationMessage: String?
            switch serverStatus {
            case .booting:
                userNotificationTitle = "Starting Ember server"
                userNotificationMessage = "Starting Ember server for \(name!)"
                postName = "serverStarting"
            case .running:
                userNotificationTitle = "Ember server started"
                userNotificationMessage = "\(name!) running at localhost"
                postName = "serverStarted"
            case .stopped:
                userNotificationTitle = "Ember server stopped"
                userNotificationMessage = "Ember server stopped for \(name!)"
                postName = "serverStopped"
            case .errored:
                userNotificationTitle = "Ember server failed to start"
                userNotificationMessage = "Could not start server for \(name!)."
                postName = "serverStoppedWithError"
            }
            NSNotificationCenter.defaultCenter().postNotificationName(postName, object: self)

            // Don't show message to user when server is booting, and only show stop-message if server was running.
            if serverStatus != .booting &&
                    serverStatus != .stopped &&
                    !(NSApplication.sharedApplication().mainWindow?.keyWindow ?? false) {
                let userNotification = NSUserNotification()
                userNotification.title = userNotificationTitle
                userNotification.informativeText = userNotificationMessage
                if serverStatus == .running {
                    userNotification.identifier = "OpenInBrowser"
                    userNotification.hasActionButton = true
                    userNotification.actionButtonTitle = "Open in browser"
                }
                NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(userNotification)
            }
        }
    }
    
    var package: NSDictionary?
    
    convenience init(dict: Dictionary<String, Any>) {
        self.init()
        name = dict["name"] as! String?
        path = dict["path"] as! String?
    }
    
    convenience init(dict: Dictionary<String, AnyObject>) {
        self.init()
        name = dict["name"] as! String?
        path = dict["path"] as! String?
    }
    
    convenience init(name: String?, path: String?) {
        self.init()
        self.name = name
        self.path = path
    }
    
    func dictionaryRepresentation() -> Dictionary<String, AnyObject> {
        var dict: Dictionary<String, AnyObject> = [:]
        if name != nil {
            dict["name"] = name!
        }
        if path != nil {
            dict["path"] = path!
        }
        return dict
    }
    
    func loadNameFromPath() -> String? {
        if path == nil {
            return nil
        }
        
        let pathToFile = path!.stringByAppendingPathComponent("package.json")
        let url = NSURL(string: pathToFile)
        if url == nil {
            return nil
        }
        let packagejson = NSData(contentsOfURL: NSURL(fileURLWithPath: pathToFile)!)
        if packagejson != nil {
            package = NSJSONSerialization.JSONObjectWithData(packagejson!, options: nil, error: nil) as? NSDictionary
        }
        
        name = package?["name"] as? String
        return name
    }
    
    func stopServer() {
        serverTask?.terminate()
        if serverStatus != .errored {
            serverStatus = .stopped
        }
        serverTask = nil
    }
}

func ==(left: Project, right: Project) -> Bool {
    return left.path == right.path
}