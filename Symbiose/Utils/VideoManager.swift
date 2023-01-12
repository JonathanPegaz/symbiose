//
//  VideoManager.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 29/12/2022.
//

import Foundation
import AVKit
import Combine

class VideoManager: ObservableObject {
    @Published var player = AVPlayer(url:Bundle.main.url(forResource: "video", withExtension: "mp4")!)
    @Published var step = 0
    @Published private var boundaryTimeObserver:Any?
    @Published var currentTime: Double = 0.0
    
    private var timeObservation: Any?
    
    let loopTimeTest = CMTime(seconds: 1, preferredTimescale: 60000)
    let anchorTimeTest = CMTime(seconds: 0, preferredTimescale: 60000)
    
    var loopDelay = 0.0
    var anchorDelay = 0.0
    
    init() {
      // Periodically observe the player's current time, whilst playing
        timeObservation = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: nil) { [weak self] time in
        guard let self = self else { return }
        // Publish the new player time
        self.currentTime = time.seconds
      }
        
    }
    
    func changeStep(step: Int) {
                
        if(self.boundaryTimeObserver != nil) {
            self.player.removeTimeObserver(self.boundaryTimeObserver)
        }
        
        switch step {
            
            case 1:
                print("step1")
                self.loopDelay = 4.0
                self.anchorDelay = 2.0
                self.step = 1
                self.player.play()

            case 2:
                print("step2")
                self.loopDelay = 12.0
                self.anchorDelay = 10.0
                self.step = 2
            
            case 3:
                print("step3")
                self.loopDelay = 19.0
                self.anchorDelay = 17.0
                self.step = 3
        
            case 4:
                print("step4")
                self.step = 4
                if(self.boundaryTimeObserver != nil) {
                    self.player.removeTimeObserver(self.boundaryTimeObserver)
                }

            default:
                print("Cette étape n'existe pas")
        }
        
        let loopTime = CMTime(seconds: self.loopDelay, preferredTimescale: 60000)
        let anchorTime = CMTime(seconds: self.anchorDelay, preferredTimescale: 60000)
        
        self.boundaryTimeObserver = self.player.addBoundaryTimeObserver(forTimes: [NSValue(time: loopTime)], queue: DispatchQueue.main) {
            self.player.seek(to: anchorTime)
        }
        
    }
}
