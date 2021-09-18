//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import SwiftUI
import VLCKit
import AVFoundation

class VideoView: NSView
{

    var player: Player = Player.instance
    var vlcLayer: VLCVideoLayer = VLCVideoLayer()
        
    init() {
        super.init(frame: .zero)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initPlayer() {
        player.drawable = self
    }
    
    
    override public func mouseDown(with event: NSEvent) {
        if window!.inLiveResize {
            return
        }
        window?.performDrag(with: event)
      }
        
    static let instance: VideoView = { VideoView() }()

}

enum Streams: String {
    
    case mp4 = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
    case usman = "rtsp://192.168.0.105:8554/unicast"
    case rtsp_bunny = "rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov"
    case rtmp = "rtmp://192.168.0.105:1935/tv/usman"
}

struct VideoViewRep: NSViewRepresentable {
    func makeNSView(context: Context) -> VideoView {
        VideoView.instance
    }
    
    func updateNSView(_ nsView: VideoView, context: Context) {
    }
    
    typealias NSViewType = VideoView
}



struct ContentView: View {
    @ObservedObject var player = Player.instance

    func playVideo() {
        guard player.initliazed else {
            VideoView.instance.initPlayer()
            player.play(_url(.usman))
            return
        }

    }
    
    func _url(_ u: Streams) -> URL {
        URL(string: u.rawValue)!
    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                VideoViewRep()
                .onAppear(perform: playVideo)
                .aspectRatio(16/9, contentMode: ContentMode.fill)
                .frame(width: geo.size.width, height: geo.size.height)
                .cornerRadius(player.cornerRadius)
                .scaledToFill()
                .fixedSize()
            }
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

        }.alert(item: $player.error) { err in
            Alert(title: Text("Device error") , message: Text(err.msg), dismissButton: .cancel())
        }.aspectRatio(player.resolution, contentMode: .fit)
    }
}
