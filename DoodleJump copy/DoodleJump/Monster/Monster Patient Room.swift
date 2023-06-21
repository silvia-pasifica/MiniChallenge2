//
//  Monster Patient Room.swift
//  DoodleJump
//
//  Created by Silvia Pasica on 20/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class Monster_Patient_Room: SKScene, SKPhysicsContactDelegate {
    private var monster: SKSpriteNode!
    private var platform: SKSpriteNode!
    
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case gameOverLine = 0b100
        case monster = 0b1000
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    
    
}
