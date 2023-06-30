//
//  ContentView.swift
//  DoodleJump
//
//  Created by Maria Berliana on 13/06/23.
//

import SwiftUI
import SpriteKit
import AVFoundation

class StartScene: SKScene{
    private var videoNode: SKVideoNode?
    let videoURL = Bundle.main.url(forResource: "game_menu", withExtension: "mov")!
    
    var videoLooper: AVPlayerLooper?
    
    override func didMove(to view: SKView) {
        let playerItem = AVPlayerItem(url: videoURL)
        let player = AVQueuePlayer()
        videoLooper = AVPlayerLooper(player: player, templateItem: playerItem)
        
        videoNode = SKVideoNode(avPlayer: player)
        videoNode?.position = CGPoint(x: frame.midX, y: frame.midY)
        videoNode?.size = CGSize(width: size.width, height: size.height)
        addChild(videoNode!)

        videoNode?.play()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let lokation = touch.location(in: self)
            let startNode = atPoint(lokation)
            
            if startNode.name == "startButton" {
                videoLooper?.disableLooping()
                videoNode?.pause()
                self.videoLooper = nil
                self.view?.presentScene(PipingSector(size: self.size), transition: SKTransition.fade(withDuration: 3))
            }
        }
    }
    
}

struct ContentView: View {
    var body: some View {
        VStack {
            SpriteView(scene: StartScene(fileNamed: "StartScene")!)
                .ignoresSafeArea()
        }
        
    }
}
