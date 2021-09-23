//
//  UrlView.swift
//  UrlView
//
//  Created by Alex on 23/09/2021.
//

import Preferences
import SwiftUI



struct UrlModal: View {
    
    @State var url: String = ""
    
    private let contentWidth: Double = 450.0
    private let padding: Double = 15.0
    
    func play() {
        let mediaUrl =  URL(string: self.url)
        let media = VLCMedia(url: mediaUrl!)
        Player.instance.play(media)
        NotificationCenter.default.post(Notification(name: .closeWindow, object: WindowController.urlmodal))
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
                    }.buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
