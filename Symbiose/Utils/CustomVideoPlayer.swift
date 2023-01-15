//
//  CustomVideoPLayer.swift
//  videomapping
//
//  Created by digital on 27/12/2022.
//

import Foundation
import AVKit
import SwiftUI

struct CustomVideoPlayer: UIViewControllerRepresentable {
    
    let controller = AVPlayerViewController()
    let player:AVPlayer
    
    init(player: AVPlayer) {
        self.player = player
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        controller.player = player
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
  
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    
    }
}
