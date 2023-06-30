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
            
            
            let checkpoint = UserDefaults().integer(forKey: "checkpoint")
            let transition = SKTransition.fade(withDuration: 1)
            
            switch checkpoint {
            case 1:
                view.presentScene(PipingSector(size: self.size), transition: transition)
            case 2:
                view.presentScene(AsylumCafetaria(size: self.size), transition: transition)
            default:
                view.presentScene(PatientRoom(size: self.size), transition: transition)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
}
