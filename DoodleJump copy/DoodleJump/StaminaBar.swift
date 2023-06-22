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
    private var maxStaminaBarWidth = CGFloat(90)
    
    private var staminaBar = SKSpriteNode()
    private var staminaBarContainer = SKSpriteNode()
    
    private let staminaTexture = SKTexture(imageNamed: "black")
    private let staminaContainerTexture = SKTexture(imageNamed: "white")
    
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
        staminaBarContainer.size.width = 100
        staminaBarContainer.size.height = 20
        staminaBarContainer.zPosition = 100
        staminaBarContainer.position.x = 80
        
        staminaBar = SKSpriteNode(texture: staminaTexture, size: staminaTexture.size())
        staminaBar.size.width = maxStaminaBarWidth
        staminaBar.size.height = 15
        staminaBar.zPosition = 101
        staminaBar.position.x = 35
        staminaBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        
        addChild(staminaBarContainer)
        addChild(staminaBar)
    }
    
    func decreaseStaminaBar() {
        staminaBar.run(SKAction.resize(toWidth: CGFloat(0), duration: 1))
    }
    
    func updatePosition(playerPos: CGFloat) {
        staminaBar.position.y = playerPos + 550
        staminaBarContainer.position.y = playerPos + 550
    }
    
    func increaseStaminaBar() {
        staminaBar.run(SKAction.resize(toWidth: maxStaminaBarWidth, duration: 8))
    }
}
