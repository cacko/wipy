//
//  UrlView.swift
//  UrlView
//
//  Created by Alex on 23/09/2021.
//

import Preferences
import SwiftUI
import Defaults


struct UrlModal: View {
    
    @State var url: String = ""
    
    private let contentWidth: Double = 450.0
    private let padding: Double = 15.0
    let player = Player.instance
    
    func play() {

        NotificationCenter.default.post(Notification(name: .closeWindow, object: WindowController.urlmodal))
        guard url == "" else {
            let media = VLCMedia(url: URL(string: url)!)
            player.allowOpen = false
            player.play(media)
            Defaults[.stream1Url] = url
            Defaults[.stream1Label] = "Auto open"
            NotificationCenter.default.post(name: .updatestreams, object: nil)
            return
        }
    }
    
    func close() {
        NotificationCenter.default.post(Notification(name: .closeWindow, object: WindowController.urlmodal))
 
    }
    
    func handlePaste(provider: Any) {
        print(provider)
    }
    
    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Stream") {
                VStack(spacing: padding) {
                    TextField("URl", text: self.$url)
                    HStack {
                            Button("Open") {
                            play()
                        }
                            Button("Close") {
                            close()
                        }
                    }.buttonStyle(.automatic)
                }
            }
        }
    }
}
