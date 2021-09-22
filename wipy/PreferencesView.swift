//
//  Preferences.swift
//  Preferences
//
//  Created by Alex on 21/09/2021.
//

import Preferences
import SwiftUI
import Defaults


extension Defaults.Keys {
    static let stream1Url = Key<String>("stream1url", default: "")
    static let stream2Url = Key<String>("stream2url", default: "")
    static let stream3Url = Key<String>("stream3url", default: "")
    static let stream1Label = Key<String>("stream1label", default: "")
    static let stream2Label = Key<String>("stream2label", default: "")
    static let stream3Label = Key<String>("stream3label", default: "")
}


struct PreferencesView: View {

    @Default(.stream1Label) var label1
    @Default(.stream2Label) var label2
    @Default(.stream3Label) var label3
    @Default(.stream1Url) var url1
    @Default(.stream2Url) var url2
    @Default(.stream3Url) var url3


    private let contentWidth: Double = 450.0
    
    var body: some View {
        Preferences.Container(contentWidth: contentWidth) {
            Preferences.Section(title: "Stream 1") {
                VStack(spacing: 15) {
                    TextField("Title", text: $label1)
                    TextField("URL", text: $url1)
                }
            }
            Preferences.Section(title: "Stream 2") {
                VStack(spacing: 15) {
                    TextField("Title", text: $label2)
                    TextField("URL", text: $url2)
                }
            }
            Preferences.Section(title: "Stream 3") {
                VStack(spacing: 15) {
                    TextField("Title", text: $label3)
                    TextField("URL", text: $url3)
                }
            }
        }
    }
}
