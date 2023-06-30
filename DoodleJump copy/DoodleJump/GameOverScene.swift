//
//  GameOverScene.swift
//  DoodleJump
//
//  Created by Maria Berliana on 14/06/23.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene
{
    let gameOver = SKSpriteNode(imageNamed: "gameOver")
    let background = SKSpriteNode(imageNamed: "background")
    
    override func didMove(to view: SKView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // play lagu
            
            let gameScene = AsylumCafetaria(size: self.size)
            let transition = SKTransition.fade(withDuration: 1)
            view.presentScene(gameScene,transition: transition)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
}
