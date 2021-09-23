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
    @Published var resolution: CGSize = CGSize(width: 1920, height: 1080)
    @Published var state: VLCMediaPlayerState = .stopped
    @Published var initliazed: Bool = false
    @Published var onTop: Bool = true
    @Published var media: VLCMedia = VLCMedia()
    @Published var playing: Bool = false
    @Published var opacity = 0.5
    @Published var allowOpen = false
    @Published var mute = false {
        didSet {
            player.audio.volume = mute ? 0 : 100
        }
    }
    
    static let instance: Player = { Player() }()
    
    var player = VLCMediaPlayer()
    
    var drawable: VideoView {
        get {
            player.drawable as! VideoView
        }
        set {
            player.drawable = newValue
        }
    }
                    
    func play(_ u: VLCMedia) {
        initliazed = true
        media = u
        player.delegate = self
        player.media = u
        player.play()
    }
    
    func stop() {
        player.stop()
        playing = false
        player.media = nil
    }
    
    private let contentWidth: Double = 450.0
    
    func play(url: URL) {
        let media = VLCMedia(url: url)
        play(media)
        NotificationCenter.default.post(Notification(name: .closeWindow, object: WindowController.urlmodal))
    }
        
    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        CATransaction.disableAnimations {
            
            if player.state == .error {
                error = DeviceError(id: .trackFailed, msg: "ff")
            }
            
            guard media.state != .playing || playing else {
                let size = player.videoSize
                guard size.width == 0 else {
                    playing = true
                    NotificationCenter.default.post(Notification(name: .hack, object: nil))
                    return
                }
                return
            }
        }
    }
}
