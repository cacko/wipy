//
//  Player.swift
//  Player
//
//  Created by Alex on 17/09/2021.
//

import VLCKit
import Combine
import AppKit
import SwiftUI

struct DeviceError: Error, Identifiable {
    var id: Errors
    
    
    enum Errors {
        case deviceLoad
        case accessDenied
        case unexpected
        case trackFailed
    }

//    let kind: Errors
    let msg: String
}


class Player: NSObject, ObservableObject, VLCMediaPlayerDelegate  {
    
    
    @Published var borderWidth: CGFloat = 5
    @Published var error: DeviceError? = nil
    @Published var cornerRadius: CGFloat = 0
    @Published var muted: Bool = false
    @Published var resolution: CGSize = CGSize(width: 1920, height: 1080)
    @Published var state: VLCMediaPlayerState = .stopped
    
    static let instance: Player = { Player() }()
    
    var player = VLCMediaPlayer()
        
    var layer = VLCVideoLayer()
    
    var media = VLCMedia()
        
    var drawable : NSView {
        get {
            player.drawable as! NSView
        }
        set {
            player.drawable = newValue
            player.delegate = self
        }
    }

    func play(_ u: URL) {
        media = VLCMedia(url: u)
        player.media = media
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func mute(_ mode: Bool = true)
    {
        player.audio.volume = mode ? 0 : 1
        muted = mode
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        state = player.state
     }
}
