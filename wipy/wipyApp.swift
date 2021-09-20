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

    var window: NSWindow

    let windowController: MainWindowController

    var fixedRatio = NSSize(width: 1920, height: 1080)

    override init() {
        window  = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 0, height: 0),
            styleMask: [.closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        windowController = MainWindowController(
             window: window)
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {

        let app:NSApplication = notification.object as! NSApplication
        let crapwindow = app.windows.first
            crapwindow?.setIsVisible(false)

        let contentView = ContentView()

        let contentViewController = NSHostingController(rootView: contentView)

        let menu = Menu(contentView, window)

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
