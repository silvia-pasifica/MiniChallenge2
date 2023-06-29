//
//  AudioPlayer.swift
//  DoodleJump
//
//  Created by Sheren Emanuela on 23/06/23.
//

import Foundation
import AVFoundation
import UIKit

var audioPlayer: AVAudioPlayer!
var audioPlayers = [AVAudioPlayer]()
func playMusic(music: String, loop: Int, volume: Float) {
    
    let path = Bundle.main.path(forResource: music, ofType: nil)!
    let url = URL(fileURLWithPath: path)
    
    do {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer.numberOfLoops = loop
        audioPlayer.volume = volume
        audioPlayer.play()
        audioPlayers.append(audioPlayer)
    } catch {
        fatalError(error.localizedDescription)
    }
}

func stopMusic() {
    for audioPlayer in audioPlayers {
        audioPlayer.stop()
    }
    audioPlayers.removeAll()
}

func pauseMusic() {
    audioPlayer.pause()
}

func playMusic() {
    audioPlayer.play()
}
func resumeMusic() {
    for audioPlayer in audioPlayers {
        audioPlayer.play()
    }
}
