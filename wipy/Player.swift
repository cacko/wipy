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
    
    let mediaOptions: [AnyHashable: Any] = [
        "network-caching": 0,
        "live-caching": 0,
        "file-caching": 0,
        "disc-caching": 0,
        "deinterlace": 0,
        "clock-jitter": 500,
        "clock-synchro": 1,
        "rtsp-frame-buffer-size": 1024 * 1024,
        "codec": "avcodec,all",
        "avcodec-skiploopfilter": 0,
        "avcodec-threads": 1,
        "avcodec-skip-frame": 2,
        "avcodec-skip-idct": 2,
        "canvas-width": 1920,
        "canvas-height": 1080,
        "swscale-mode": 1,
        "prefetch-buffer-size": 0,
        "rawaud-samplerate": 441000,
        "mjpeg-fps": 30,
    ]
        
    var player: VLCMediaPlayer = VLCMediaPlayer()
    
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
        
    func play(url: URL) {
        let media = VLCMedia(url: url)
        media.addOptions(mediaOptions)
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
