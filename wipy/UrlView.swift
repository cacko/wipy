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
    
    func play() {
        let mediaUrl =  URL(string: self.url)
        let media = VLCMedia(url: mediaUrl!)
        Player.instance.play(media)
        NotificationCenter.default.post(Notification(name: .closeWindow, object: WindowController.urlmodal))
    }
    
    func close() {
        NotificationCenter.default.post(Notification(name: .closeWindow, object: WindowController.urlmodal))
    }
    
    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Stream") {
                VStack(spacing: 15) {
                    TextField("URL", text: $url)
                        .textFieldStyle(.roundedBorder)
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
