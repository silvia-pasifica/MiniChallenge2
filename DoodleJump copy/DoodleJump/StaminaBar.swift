//
//  StaminaBar.swift
//  DoodleJump
//
//  Created by Sheren Emanuela on 22/06/23.
//

import Foundation
import SpriteKit

class StaminaBar: SKNode {
    
    private var stamina = CGFloat(0)
    private var maxStamina = CGFloat(8)
    private var maxStaminaBarWidth = CGFloat(160)
    
    private var staminaBar = SKSpriteNode()
    private var staminaBarContainer = SKSpriteNode()
    
    private let staminaTexture = SKTexture(imageNamed: "bar-fill")
    private let staminaContainerTexture = SKTexture(imageNamed: "bar-frame")
    
    private var sceneFrame = CGRect()
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSceneFrame(sceneFrame: CGRect) {
        self.sceneFrame = sceneFrame
    }
    
    func buildStaminaBar() {
        staminaBarContainer = SKSpriteNode(texture: staminaContainerTexture, size: staminaContainerTexture.size())
        staminaBarContainer.size.width = 180
        staminaBarContainer.size.height = 60
        staminaBarContainer.zPosition = 101
        staminaBarContainer.position.x = 100
        
        staminaBar = SKSpriteNode(texture: staminaTexture, size: staminaTexture.size())
        staminaBar.size.width = maxStaminaBarWidth
        staminaBar.size.height = 18
        staminaBar.zPosition = 100
        staminaBar.position.x = 30
        staminaBar.anchorPoint = CGPoint(x: 0, y: 0.25)
        staminaBar.alpha = 0.5
        
        addChild(staminaBar)
        addChild(staminaBarContainer)
    }
    
    func decreaseStaminaBar() {
        staminaBar.run(SKAction.resize(toWidth: CGFloat(0), duration: 0.5))
    }
    
    func updatePosition(playerPos: CGFloat) {
        staminaBar.position.y = playerPos + 550
        staminaBarContainer.position.y = playerPos + 550
    }
    
    func increaseStaminaBar() {
        staminaBar.run(SKAction.resize(toWidth: maxStaminaBarWidth, duration: 8))
    }
}
