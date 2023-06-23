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
    guard let audioData = NSDataAsset(name: music)?.data else {
        fatalError("Unable to find asset \(music)")
    }
    
    do {
        audioPlayer = try AVAudioPlayer(data: audioData)
        audioPlayer.numberOfLoops = loop
        audioPlayer.volume = 0
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
