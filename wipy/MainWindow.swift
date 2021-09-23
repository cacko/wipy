//
//  MainWindow.swift
//  MainWindow
//
//  Created by Alex on 23/09/2021.
//

import SwiftUI
import IOKit
import IOKit.pwr_mgt


class MainWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.delegate = self
    }

}

class MainWindow: NSWindow {
    
     let player = Player.instance
    
    var noSleepAssertionID: IOPMAssertionID = 0
     var noSleepReturn: IOReturn?

    func disableScreenSleep(reason: String = "Unknown reason") {
         guard noSleepReturn == nil else { return }
         noSleepReturn = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep as CFString, IOPMAssertionLevel(kIOPMAssertionLevelOn), reason as CFString, &noSleepAssertionID)
     }

     func  enableScreenSleep(){
         if noSleepReturn != nil {
             _ = IOPMAssertionRelease(noSleepAssertionID) == kIOReturnSuccess
             noSleepReturn = nil
             return
         }
     }

    
    
    var isFullScreen = false {
        didSet {
            self.toggleFullScreen(self)
            if isFullScreen {
                NSCursor.hide()
                disableScreenSleep()
                isFloating = isFullScreen
                player.borderWidth = 0
                self.showsResizeIndicator = false
            } else {
                enableScreenSleep()
                NSCursor.unhide()
                player.borderWidth = 10
                self.showsResizeIndicator = true
            }
        }
    }
    
    
    var isFloating = false {
        didSet {
            guard isFullScreen else {
                self.level = isFloating ? .floating : .normal
                _ = isFloating ? disableScreenSleep() : enableScreenSleep()
                player.onTop = isFloating
                return
            }
        }
    }
    
}


