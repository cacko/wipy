//
//  VideoView.swift
//  VideoView
//
//  Created by Alex on 21/09/2021.
//

import SwiftUI
import VLCKit

extension VLCVideoView {
    var fillScreen: Bool {
        true
    }
}

extension CATransaction {

    static func disableAnimations(_ completion: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        completion()
        CATransaction.commit()
    }

}

class VideoView: VLCVideoView, VLCMediaPlayerDelegate
{

    var player: Player = Player.instance
    
    private var lastOFfset = 1
    
    
    init() {
        super.init(frame: .zero)
        player.player.drawable = self
        player.player.delegate = self
        window?.isMovableByWindowBackground = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override public func mouseDown(with event: NSEvent) {
        guard window!.inLiveResize else {
            window?.performDrag(with: event)
            return
        }
      }
    
    private func hack() {
        let size = window?.frame.size
        lastOFfset *= -1
        window?.setContentSize(NSSize(width: size!.width, height: size!.height + CGFloat(lastOFfset)))
        player.opacity = 1
    }


    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        CATransaction.disableAnimations {
            switch player.player.state {
                case .buffering:
                    hack()
                    break
                case .playing:
                    hack()
                    break
                default: break
            }
            player.playing = true

        }

    }
    
}



struct VideoViewRep: NSViewRepresentable {
    
    func makeNSView(context: Context) -> VideoView {
        VideoView()
    }
    
    func updateNSView(_ nsView: VideoView, context: Context) {
    }
    
    
    typealias NSViewType = VideoView
}
