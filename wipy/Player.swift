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


class Player: NSObject, ObservableObject  {
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
                    
    func play(_ u: VLCMedia) {
        initliazed = true
        media = u
        player.media = u
        player.play()
    }
    
    func stop() {
        player.stop()
        playing = false
        player.media = nil
    }
}
