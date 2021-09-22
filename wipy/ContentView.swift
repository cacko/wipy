//
//  ContentView.swift
//  tashak
//
//  Created by Alex on 16/09/2021.
//

import SwiftUI
import VLCKit
import AppKit
import Preferences
import Defaults


extension NSOpenPanel {

    func setVideo() {
        allowedContentTypes = [.video, .movie]
         allowsMultipleSelection = false
         canChooseDirectories = false
         canCreateDirectories = false
    }
    
}

struct ContentView: View {
    @ObservedObject var player = Player.instance
    @State var showFileChooser = false

    
    func openVideoFile(_ f: URL) {
        let media = VLCMedia(url: f)
        player.play(media)
    }
    
    func startVideo() {
        guard player.playing else {
            let stream1 = UserDefaults.standard.string(forKey: Defaults.Keys.stream1Url.name)
            if ((stream1) != nil) {
                player.play(VLCMedia(url: URL(string: stream1!)!))
            }
            return
        }

    }
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geo in
                VideoViewRep()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .onAppear(perform: startVideo)
            }
            HStack{
                Spacer()
                VStack(alignment: .center, spacing: 20) {
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Image(systemName: "wifi.circle").font(.largeTitle)
                            Text("Open URL").font(.headline)
                        }
                    }).buttonStyle(.plain)
                    Button(action: {
                        let panel = NSOpenPanel()
                        panel.setVideo()
                        if panel.runModal() == .OK {
                            openVideoFile(panel.url!.standardized)
                        }
                    }, label: {
                        HStack {
                            Image(systemName: "film").font(.largeTitle)
                            Text("Open file").font(.headline)
                        }
                    }).buttonStyle(.plain)
                }.padding()
                Spacer()
            }.frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            ).opacity(player.playing ? 0 : 1)
            HStack {
                Image(systemName: "speaker.slash")
                    .font(.title)
                    .padding()
                    .foregroundColor(.white)
                    .opacity(player.mute ? 0.8 : 0)
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
            .border(.clear, width: player.borderWidth)
            .cornerRadius(player.borderWidth)
            .opacity(player.opacity)
        
    }
}
