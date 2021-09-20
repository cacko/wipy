//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import SwiftUI
import VLCKit
import AVFoundation

extension VLCVideoView {
    
    var fillScreen: Bool {
            true
    }
    var backColor: NSColor {
        .green
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override public func mouseDown(with event: NSEvent) {
        if window!.inLiveResize {
            return
        }
        window?.performDrag(with: event)
      }


    func mediaPlayerStateChanged(_ aNotification: Notification!) {
        CATransaction.disableAnimations {
            let size = window?.frame.size
            lastOFfset *= -1
            switch player.player.state {
            case .buffering:
                window?.setContentSize(NSSize(width: size!.width, height: size!.height + CGFloat(lastOFfset)))
                break
            case .playing:
                window?.setContentSize(NSSize(width: size!.width, height: size!.height + CGFloat(lastOFfset)))
                break
            default: break
            }
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



struct ContentView: View {
    @ObservedObject var player = Player.instance

//    func playVideo() {
//        guard player.initliazed else {
//            player.play(_url(player.media))
//            return
//        }
//
//    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                VideoViewRep()
//                .onAppear(perform: playVideo)
                    .frame(width: geo.size.width, height: geo.size.height)
//                                  .scaledToFill()
            }
            
//            GeometryReader { geo in
//                  PlayerContainerView(captureSession: player.captureSession)
//                      .aspectRatio(16/9, contentMode: ContentMode.fill)
//                  .frame(width: geo.size.width, height: geo.size.height)
//                  .scaledToFill()
//                  .cornerRadius(player.cornerRadius)
//                  .fixedSize()
//              }
            HStack {
                Image(systemName: "speaker.slash")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                    .opacity(player.muted ? 0.8 : 0)
                Spacer()
                Image(systemName: "paperclip")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                    .opacity(player.onTop ? 0.5 : 0)
            }
        }
        .alert(item: $player.error) { err in
            Alert(title: Text("Device error") , message: Text(err.msg), dismissButton: .cancel())
        }.aspectRatio(16/9, contentMode: .fit)
    }
}
