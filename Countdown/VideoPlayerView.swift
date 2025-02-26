//
//  VideoPlayerView.swift
//  VideoPlayerView
//
//  Created by neo on 12/25/24.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoName: String
    
    var body: some View {
        if let path = Bundle.main.path(forResource: "CountdownLoad", ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            VideoPlayer(player: AVPlayer(url: url).apply { player in
                player.play()
            })
                overlay(
                    Color.clear
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                )
        } else {
            Text("Video not found")
        }
    }
}

extension AVPlayer {
    func apply(_ closure: (AVPlayer) -> Void) -> AVPlayer {
        closure(self)
        return self
    }
} 
