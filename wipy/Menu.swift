//
//  Menu.swift
//  Menu
//
//  Created by Alex on 01/09/2021.
//

import Foundation
import SwiftUI
import AppKit
import Preferences
import Defaults

class StreamItem: CrapItem {
    
    var media: VLCMedia {
        VLCMedia(url: stream.url)
    }
    
    var stream: Stream
    
    init(action: Selector?, keyEquivalent: String, stream: Stream) {
        self.stream = stream
        super.init(title: stream.title, action: action, keyEquivalent: keyEquivalent)
        self.isHidden = !stream.isValid
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

class StreamMenu: WipyMenu {
    
    var streams = Streams.instance
        
    override var actions: [NSMenuItem] {
        [
            NSMenuItem.separator(),
            NSMenuItem(title: "Open file...", action: #selector(onOpenFile(sender:)), keyEquivalent: "o"),
            NSMenuItem(title: "Open url...", action: #selector(onOpenUrl(sender:)), keyEquivalent: "u"),
            NSMenuItem(title: "Preferences", action: #selector(onPreferences(sender:)), keyEquivalent: ",")
        ]
        
    }
    
    override func _init() {
        for (idx, stream) in streams.streams.enumerated() {
                let item = StreamItem(action: #selector(onStream(sender:)), keyEquivalent: String(idx + 1), stream: stream)
                item.target = self
                item.isHidden = !stream.isValid
                self.addItem(item)
            }
        super._init()
        
        
        let center = NotificationCenter.default
        let mainQueue = OperationQueue.main
        

        center.addObserver(forName: NSWindow.willCloseNotification, object: parent.preferences.window, queue: mainQueue) {(note) in
            self.updateMenus()
        }
        
        center.addObserver(forName: .updatestreams, object: nil, queue: mainQueue) {(note) in
            self.updateMenus()
        }
        
    }
    
    func updateMenus() {
        let streams = self.streams.streams
        for (idx, item) in self.items.enumerated() {
            if (item is StreamItem) {
                let st = streams[idx]
                item.title = st.title
                (item as! StreamItem).stream = st
                item.isHidden = !st.isValid
            }
        }
    }
    
}

class AudioMenu: WipyMenu {
    
    override var actions: [NSMenuItem] { get {
         [
            CrapItem(title: "Toggle sound", action: #selector(onAudioMute(sender:)), keyEquivalent: "m"),
        ]
    }}

}
    

class VideoMenu: WipyMenu {
    
    override var actions: [NSMenuItem] { get {
         [
            CrapItem(title: "Always on top", action: #selector(onAlwaysOnTop(sender:)), keyEquivalent: "a"),
            CrapItem(title: "Toggle full screen", action: #selector(onToggleFullscreen(sender:)), keyEquivalent: "f"),
            CrapItem(title: "Minimize", action: #selector(onMinimize(sender:)), keyEquivalent: "\u{1b}"),
        ]
    }}
    
}

class WipyMenu: NSMenu {
        
    let player: Player = Player.instance
    
    var actions: [NSMenuItem] {
        get { return [] }
    }
    
    var parent: Menu
    
    var window: MainWindow
    
    init(title: String, parent: Menu) {
        self.parent = parent
        self.window = parent.window
        super.init(title: title)
        _init()
    }
    
    func _init() {
        guard actions.count == 0 else {
            for item in actions {
                if (item is CrapItem) {
                    item.keyEquivalentModifierMask.remove(.command)
                }
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
        window.isFullScreen.toggle()
        sender.state = window.isFullScreen ? .on : .off
    }
    


    @objc func onAlwaysOnTop(sender: NSMenuItem) {
        window.isFloating.toggle()
        sender.state = window.isFloating ? .on : .off
    }

    @objc func onQuit(sender: NSMenuItem) {
        NSApplication.shared.terminate(sender)
    }
    
    
    @objc func onMinimize(sender: NSMenuItem) {
        if window.isFullScreen {
            return window.isFullScreen.toggle()
        }
        window.miniaturize(self)
    }
    
    @objc func onAudioMute(sender: NSMenuItem) {
        player.mute.toggle()
        sender.state = player.mute ? .on : .off
    }
    
    
    @objc func onStream(sender: StreamItem) {
        player.stop()
        player.play(sender.media)
    }
    
    @objc func onOpenFile(sender: StreamItem) {
        parent.view.showOpenFile()
    }
    
    @objc func onOpenUrl(sender: StreamItem) {
        NotificationCenter.default.post(name: .openUrl, object: nil)
    }
    
    @objc func onPreferences(sender: StreamItem) {
        parent.preferences.show()
        if (window.isFloating) {
            parent.preferences.window?.level = .floating
        }
        parent.preferences.window?.orderFrontRegardless()
        parent.window.orderBack(nil)
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
    var window: MainWindow
    var mainMenu: NSMenu
    var preferences: PreferencesWindowController
    var urlmodal: PreferencesWindowController
    var player = Player.instance
    

    init(delegate: AppDelegate) {
        self.view = delegate.contentView
        self.window = delegate.window
        self.preferences = delegate.preferencesWindowController
        self.urlmodal = delegate.urlModalController
        mainMenu = NSApplication.shared.mainMenu ?? NSMenu()
        super.init(title: "")
        self._init()
        self.update()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func addItem(_ newItem: NSMenuItem){
        mainMenu.addItem(newItem)
    }
            
    override func addItem(withTitle string: String, action selector: Selector?, keyEquivalent charCode: String) -> NSMenuItem {
        return mainMenu.addItem(withTitle: string, action: selector, keyEquivalent: charCode)
    }
    
    
    func _init() {
        _ = mainMenu.items.dropFirst().filter{ $0.title != "Edit" }.map{ $0.menu?.removeItem($0) }
        mainMenu.delegate = self
        addMenu(StreamMenu(title: "Stream", parent: self))
        addMenu(VideoMenu(title: "Video", parent: self))
        addMenu(AudioMenu(title: "Audio", parent: self))
    }
    
    func addMenu(_ menu: WipyMenu) {
        let menuItem = addItem(withTitle: menu.title, action: nil,  keyEquivalent: "")
        menuItem.target = self
        menu.delegate = self
        menuItem.submenu = menu
    }
}
