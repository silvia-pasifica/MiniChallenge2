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
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
        gameOver.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gameOver.setScale(1.6)
        gameOver.zPosition = 5
        addChild(gameOver)
        
        let tapLabel = SKLabelNode()
        tapLabel.position = CGPoint(x: size.width / 2, y: size.height / 4)
        tapLabel.text = "Tap to restart"
        tapLabel.fontSize = 46
        tapLabel.fontColor = .black
        addChild(tapLabel)
        
        let outAction = SKAction.fadeOut(withDuration: 0.5)
        let inAction = SKAction.fadeIn(withDuration: 0.5)
        let sequence = SKAction.sequence([outAction, inAction])
        
        tapLabel.run(SKAction.repeatForever(sequence))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = PipingSector(size: self.size)
        let transition = SKTransition.flipVertical(withDuration: 1)
        
        view?.presentScene(gameScene,transition: transition)
    }
    
    
}
