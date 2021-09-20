//
//  Menu.swift
//  Menu
//
//  Created by Alex on 01/09/2021.
//

import Foundation
import SwiftUI
import AppKit
import IOKit
import IOKit.pwr_mgt

enum Streams: String {
    
    case mp4 = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
    case usman = "rtsp://192.168.0.105:8554/unicast"
    case bunny = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
}

class StreamItem: CrapItem {
    
    var media: VLCMedia
    
    init(title: String, action: Selector?, keyEquivalent: String, media: VLCMedia) {
        self.media = media
        super.init(title: title, action: action, keyEquivalent: keyEquivalent)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CrapItem: NSMenuItem, NSUserInterfaceValidations {
    
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        return true
    }
}

class StreamMenu: CrapMenu {
    
    override var actions: Array<NSMenuItem> { get {
         [
            StreamItem(title: "Usman", action: #selector(onStream(sender:)), keyEquivalent: "1", media: VLCMedia(url: _url(.usman))),
            StreamItem(title: "Bunny", action: #selector(onStream(sender:)), keyEquivalent: "2", media: VLCMedia(url: _url(.bunny))),
            StreamItem(title: "Mp4", action: #selector(onStream(sender:)), keyEquivalent: "3", media: VLCMedia(url: _url(.mp4))),
        ]
    }}
    
    func _url(_ u: Streams) -> URL {
        URL(string: u.rawValue)!
    }
    
    override func _init() {
        guard actions.count == 0 else {
            for item in actions {

                item.target = self
                self.addItem(item)
            }
            return

        }
    }
    
}

class AudioMenu: CrapMenu {
    
    override var actions: Array<NSMenuItem> { get {
         [
            NSMenuItem(title: "Toggle sound", action: #selector(onAudioMute(sender:)), keyEquivalent: "m"),
        ]
    }}

}

class VideoMenu: CrapMenu {
    
    override var actions: Array<NSMenuItem> { get {
         [
            NSMenuItem(title: "Always on top", action: #selector(onAlwaysOnTop(sender:)), keyEquivalent: "a"),
            NSMenuItem(title: "Toggle full screen", action: #selector(onToggleFullscreen(sender:)), keyEquivalent: "f"),
            NSMenuItem(title: "Minimize", action: #selector(onMinimize(sender:)), keyEquivalent: "\u{1b}"),
        ]
    }}
    
}

class CrapMenu: NSMenu {
    
    let player: Player = Player.instance
    
    var actions: Array<NSMenuItem> {
        get { return [] }
    }
    
    var parent: Menu
    
    init(_ _title: String, _ _parent: Menu) {
        parent = _parent
        super.init(title: _title)
        _init()
    }
    
    func _init() {
        guard actions.count == 0 else {
            for item in actions {
                item.keyEquivalentModifierMask.remove(.command)
                item.target = self
                self.addItem(item)
            }
            return

        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onToggleFullscreen(sender: NSMenuItem) {
        parent.isFullScreen.toggle()
        sender.state = parent.isFullScreen ? .on : .off
    }
    
    @objc func onAudioMute(sender: NSMenuItem) {
        parent.isMuted.toggle()
        sender.state = parent.isMuted ? .on : .off
    }

    @objc func onAlwaysOnTop(sender: NSMenuItem) {
        parent.isFloating.toggle()
        sender.state = parent.isFloating ? .on : .off
    }

    @objc func onQuit(sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
    
    @objc func didSelectDevices(_ sender: NSMenuItem) {
        print("this will never be called")
    }
    
    @objc func onMinimize(sender: NSMenuItem) {
        if parent.isFullScreen {
            return parent.isFullScreen.toggle()
        }
        parent.window.miniaturize(self)
    }
    
    @objc func onStream(sender: StreamItem) {
        player.stop()
        player.play(sender.media)
    }
    

    @objc func didSelectDevice(sender: NSMenuItem) {

    }
    
}

class Menu: NSMenu, NSMenuDelegate, NSMenuItemValidation, NSUserInterfaceValidations{
    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        return true
    }
    
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }
    
    var view: ContentView
    var window: NSWindow
    var mainMenu: NSMenu
    var player = Player.instance
    
    var noSleepAssertionID: IOPMAssertionID = 0
    var noSleepReturn: IOReturn?

    func disableScreenSleep(reason: String = "Unknown reason") -> Bool? {
        guard noSleepReturn == nil else { return nil }
        noSleepReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), reason as CFString, &noSleepAssertionID)
        return noSleepReturn == kIOReturnSuccess
    }

    func  enableScreenSleep() -> Bool {
        if noSleepReturn != nil {
            _ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
            noSleepReturn = nil
            return true
        }
        return false
    }
    
    var isFloating = false {
        didSet {
            guard isFullScreen else {
                window.level = isFloating ? .floating : .normal
                _ = isFloating ? disableScreenSleep() : enableScreenSleep()
                Player.instance.onTop = isFloating
                return
            }
        }
    }
    
    var isFullScreen = false {
        didSet {
            window.toggleFullScreen(self)
            if isFullScreen {
                NSCursor.hide()
                let _ = disableScreenSleep()
                isFloating = isFullScreen
                player.borderWidth = 0
            } else {
                let _ = enableScreenSleep()
                NSCursor.unhide()
                player.borderWidth = 5
            }
        }
    }
    
    var isMuted = false {
        didSet {
            Player.instance.mute(isMuted)
        }
    }
    
    init(_ _view: ContentView, _ _window: NSWindow) {
        view = _view
        window = _window
        mainMenu = NSApplication.shared.mainMenu ?? NSMenu()
        super.init(title: "")
        self._init()
        self.update()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addItem(_ newItem: NSMenuItem) {
        mainMenu.addItem(newItem)
    }
            
    override func addItem(withTitle string: String, action selector: Selector?, keyEquivalent charCode: String) -> NSMenuItem {
        return mainMenu.addItem(withTitle: string, action: selector, keyEquivalent: charCode)
    }
    
    func _init() {
        _ = mainMenu.items.dropFirst().map{ $0.menu?.removeItem($0) }
        mainMenu.delegate = self
        addMenu(StreamMenu("Stream", self))
        addMenu(VideoMenu("Video", self))
        addMenu(AudioMenu("Audio", self))
    }
    
    func addMenu(_ menu: CrapMenu) {
        let menuItem = addItem(withTitle: menu.title, action: nil,  keyEquivalent: "")
        menuItem.target = self
        menu.delegate = self
        menuItem.submenu = menu
    }
}
