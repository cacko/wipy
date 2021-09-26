//
//  Stream.swift
//  Stream
//
//  Created by Alex on 26/09/2021.
//

import Defaults

class Stream {
    
    var title: String
    
    var url: URL
    
    var kL: Defaults.AnyKey
    
    var kU: Defaults.AnyKey
    
    var isValid: Bool {
        get {
            self.title.count > 0 && self.url.absoluteString.count > 0
        }
    }
    
    init(keyLabel: Defaults.AnyKey, keyUrl: Defaults.AnyKey) {
        self.kL = keyLabel
        self.kU = keyUrl
        self.title = UserDefaults.standard.string(forKey: keyLabel.name) ?? keyLabel.name
        self.url = URL(string: UserDefaults.standard.string(forKey: keyUrl.name) ?? "") ?? URL(fileURLWithPath: "")
    }
    
}



class Streams {
    
    static let instance: Streams = { Streams() }()

    
    static let keys: [Defaults.AnyKey] =
    [
        .stream1Url,
        .stream2Url,
        .stream3Url,
    ]
    
    
    static let labels: [Defaults.AnyKey] =
    [
        .stream1Label,
        .stream2Label,
        .stream3Label,
    ]
    
    
    var streams: [Stream] {
        get {
            var res: [Stream] = []
            for key in [
                [Defaults.Keys.stream1Label, Defaults.Keys.stream1Url],
                [Defaults.Keys.stream2Label, Defaults.Keys.stream2Url],
                [Defaults.Keys.stream3Label, Defaults.Keys.stream3Url]
            ] {
                let stream = Stream(keyLabel: key[0], keyUrl: key[1])
                res.append(stream)
            }
            return res
        }
    }
    
    var autoPlay: Stream? {
        streams.filter{ $0.isValid }.first
    }
}
