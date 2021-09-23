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

class Stream {
    
    var title: String
    
    var url: URL
    
    var isValid: Bool {
        get {
            self.title.count > 0 && self.url.absoluteString.count > 0
        }
    }
    
    init(title: String?, url: String?) {
        self.title = title ?? ""
        self.url = URL(string: url ?? "") ?? URL(fileURLWithPath: "")
    }
    
}

class Streams {
    
    var streams: [Stream] {
        get {
            var res: [Stream] = []
            for key in [
                [Defaults.Keys.stream1Label.name, Defaults.Keys.stream1Url.name],
                [Defaults.Keys.stream2Label.name, Defaults.Keys.stream2Url.name],
                [Defaults.Keys.stream3Label.name, Defaults.Keys.stream3Url.name]
            ] {
                let stream = Stream(title: UserDefaults.standard.string(forKey: key[0]), url: UserDefaults.standard.string(forKey: key[1]))
                if (stream.isValid) {
                    res.append(stream)
                }
            }
            return res
        }
    }
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
    
    var streams = Streams()
    
    override var actions: Array<NSMenuItem> { get {
        var res: [NSMenuItem] = []
        for stream in streams.streams {
            res.append(StreamItem(title: stream.title,  action: #selector(onStream(sender:)), keyEquivalent: "1", media: VLCMedia(url: stream.url)))
        }

        res += [
            NSMenuItem.separator(),
            CrapItem(title: "Open file...", action: #selector(onOpenFile(sender:)), keyEquivalent: "o"),
            CrapItem(title: "Open url...", action: #selector(onOpenUrl(sender:)), keyEquivalent: "u"),
            CrapItem(title: "Preferences", action: #selector(onPreferences(sender:)), keyEquivalent: ",")
        ]
        
        return res
        
        }
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
            CrapItem(title: "Toggle sound", action: #selector(onAudioMute(sender:)), keyEquivalent: "m"),
        ]
    }}

}

class VideoMenu: CrapMenu {
    
    override var actions: Array<NSMenuItem> { get {
         [
            CrapItem(title: "Always on top", action: #selector(onAlwaysOnTop(sender:)), keyEquivalent: "a"),
            CrapItem(title: "Toggle full screen", action: #selector(onToggleFullscreen(sender:)), keyEquivalent: "f"),
            CrapItem(title: "Minimize", action: #selector(onMinimize(sender:)), keyEquivalent: "\u{1b}"),
        ]
    }}
    
}

class CrapMenu: NSMenu {
    
    let player: Player = Player.instance
    
    var actions: Array<NSMenuItem> {
        get { return [] }
    }
    
    var parent: Menu
    
    var window: MainWindow
    
    init(_ _title: String, _ _parent: Menu) {
        parent = _parent
        window = _parent.window
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
        parent.urlmodal.show()
        if (window.isFloating) {
            parent.urlmodal.window?.level = .floating
        }
        parent.urlmodal.window?.orderFrontRegardless()
        parent.window.orderBack(nil)
        parent.urlmodal.becomeFirstResponder()
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
    
    override func addItem(_ newItem: NSMenuItem) {
        mainMenu.addItem(newItem)
    }
            
    override func addItem(withTitle string: String, action selector: Selector?, keyEquivalent charCode: String) -> NSMenuItem {
        return mainMenu.addItem(withTitle: string, action: selector, keyEquivalent: charCode)
    }
    
    
    func _init() {
        _ = mainMenu.items.dropFirst().filter{ $0.title != "Edit" }.map{ $0.menu?.removeItem($0) }
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
