//
//  wipyApp.swift
//  wipy
//
//  Created by Alex on 17/09/2021.
//

import SwiftUI
import AppKit
import Combine
import Preferences
import Defaults

@main
struct wipyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
        }
    }
}

extension Notification.Name {
    static let closeWindow = NSNotification.Name("close_window")
    static let openWindow = NSNotification.Name("open_window")
    static let fullscreen = NSNotification.Name("fullscreen")
    static let updatestreams = NSNotification.Name("updatestream")
    static let hack = NSNotification.Name("hack")
}



enum WindowController {
    case urlmodal,main,prefences
}


extension NSWindow.StyleMask {
    static var defaultWindow: NSWindow.StyleMask {
        var styleMask: NSWindow.StyleMask = .closable
        styleMask.formUnion(.fullSizeContentView)
        styleMask.formUnion(.resizable)
        return styleMask
    }
}


extension Preferences.PaneIdentifier {
    static let streams = Self("streams")
    static let urlinput = Self("urlinput")
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: MainWindow

    let windowController: MainWindowController

    var fixedRatio = NSSize(width: 1920, height: 1080)
    
    var lastOffset: CGFloat = 1.0
    
    override init() {
        window  = MainWindow(
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
        let contentViewController = NSHostingController(rootView: contentView)
        

        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = contentViewController.view
        window.aspectRatio = fixedRatio
        window.contentAspectRatio = fixedRatio
        window.collectionBehavior = .fullScreenPrimary
        window.backgroundColor = .clear
        window.hasShadow = false
        window.showsResizeIndicator = true
        windowController.window?.delegate = windowController
        windowController.showWindow(self)
        window.makeKeyAndOrderFront(nil)
        
        _ = Menu(delegate: self)
        window.isFloating.toggle()
        
        let center = NotificationCenter.default
        let mainQueue = OperationQueue.main
        
        center.addObserver(forName: .closeWindow, object: nil, queue: mainQueue) {(note) in
            let obj: WindowController = note.object as! WindowController
            switch obj {
            case .urlmodal:
                self.urlModalController.close()
                break
            case .prefences:
                self.preferencesWindowController.close()
            default:
                break
            }
        }
        
        center.addObserver(forName: .hack, object: nil, queue: mainQueue) {(note) in
            var size = self.window.frame.size
            size.width += self.lastOffset
            size.height += self.lastOffset
            self.window.setContentSize(size)
        }
        


    }
    
    let StreamsPreferencesView: () -> PreferencePane = {
        /// Wrap your custom view into `Preferences.Pane`, while providing necessary toolbar info.
        let paneView = Preferences.Pane(
            identifier: .streams,
            title: "Streams",
            toolbarIcon: NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: "Streams preferences")!
        ) {
            PreferencesView()
        }
        
        return Preferences.PaneHostingController(pane: paneView)
    }
    
    let UrlInputVuew: () -> PreferencePane = {
        /// Wrap your custom view into `Preferences.Pane`, while providing necessary toolbar info.
        let paneView = Preferences.Pane(
            identifier: .urlinput,
            title: "Url",
            toolbarIcon: NSImage(systemSymbolName: "person.crop.circle", accessibilityDescription: "Streams preferences")!
        ) {
            UrlModal()
        }

        return Preferences.PaneHostingController(pane: paneView)
    }
    
    lazy var contentView = ContentView()
    
    private lazy var urlmodal: [PreferencePane] = [
        UrlInputVuew(),
    ]
    
    lazy var urlModalController = PreferencesWindowController(
        preferencePanes: urlmodal,
        style: .segmentedControl,
        animated: true,
        hidesToolbarForSingleItem: true
    )
    
    private lazy var preferences: [PreferencePane] = [
        StreamsPreferencesView(),
    ]
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: preferences,
        style: .segmentedControl,
        animated: true,
        hidesToolbarForSingleItem: true
    )
}
