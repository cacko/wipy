//
//  wipyApp.swift
//  wipy
//
//  Created by Alex on 17/09/2021.
//

import SwiftUI
import AppKit
import Combine

@main
struct wipyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
        }
    }
}


class MainWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()

        self.window?.delegate = self

    }
    
}

extension NSWindow.StyleMask {
    static var defaultWindow: NSWindow.StyleMask {
        var styleMask: NSWindow.StyleMask = .closable
        styleMask.formUnion(.fullSizeContentView)
        styleMask.formUnion(.resizable)
        return styleMask
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    
    var window: NSWindow? = nil

    let windowController = MainWindowController(
         window: NSWindow(contentRect: NSMakeRect(640, 360, NSScreen.main!.frame.width/2, NSScreen.main!.frame.width*9/16),
                          styleMask: .defaultWindow,
                          backing: .buffered,
        defer: false))

    let _rootView = ContentView()
    
    var fixedRatio = NSSize(width: 1920, height: 1080)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let app:NSApplication = notification.object as! NSApplication
        let crapwindow = app.windows.first
            crapwindow?.setIsVisible(false)
        
        let contentViewController = NSHostingController(rootView: _rootView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 360),
            styleMask: [.closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
            
        let menu = Menu(_rootView, window)
                
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = contentViewController.view
        window.makeKeyAndOrderFront(nil)
        window.aspectRatio = fixedRatio
        window.contentAspectRatio = fixedRatio
        window.collectionBehavior = .fullScreenPrimary
        window.backgroundColor = .clear
        window.hasShadow = false
        windowController.window?.delegate = windowController
        windowController.showWindow(self)
        menu.isFloating.toggle()
        
        
 
    }
    
}
