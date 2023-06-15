//
//  GameScene.swift
//  DoodleJump
//
//  Created by Maria Berliana on 13/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    let background = SKSpriteNode(imageNamed: "background")
    let player = SKSpriteNode(imageNamed: "bunny")
    let ground = SKSpriteNode(imageNamed: "ground_grass")
    let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let defaults = UserDefaults.standard
    var score = 0
    var bestScore = 0
    
    let cam = SKCameraNode()
    
    
    
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case gameOverLine
    }
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = .zero
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 1
        addChild(background)
        
        physicsWorld.contactDelegate = self
        
        ground.position = CGPoint(x: size.width / 2 , y: 0)
        ground.zPosition = 5
        ground.setScale(1.0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.affectedByGravity = false
        addChild(ground)
        
        player.position = CGPoint(x: size.width / 2, y: size.height / 6)
        player.zPosition = 10
        player.setScale(0.20)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.restitution = 1
        player.physicsBody?.friction = 0
        player.physicsBody?.angularDamping = 0
        
        player.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.gameOverLine.rawValue
        addChild(player)
        
        gameOverLine.position = CGPoint(x: player.position.x, y: player.position.y - 200)
        gameOverLine.zPosition = -1
        gameOverLine.physicsBody = SKPhysicsBody(rectangleOf: gameOverLine.size)
        gameOverLine.physicsBody?.affectedByGravity = false
        gameOverLine.physicsBody?.allowsRotation = false
        gameOverLine.physicsBody?.categoryBitMask = bitmasks.gameOverLine.rawValue
        gameOverLine.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.player.rawValue
        addChild(gameOverLine)
        
        scoreLabel.position.x = 50
        scoreLabel.zPosition = 20
        scoreLabel.fontColor = .black
        scoreLabel.fontSize = 32
        scoreLabel.text = "Score: \(score)"
        addChild(scoreLabel)
        
        
        bestScore = defaults.integer(forKey: "best")
        bestScoreLabel.position.x = 50
        bestScoreLabel.zPosition = 20
        bestScoreLabel.fontColor = .black
        bestScoreLabel.fontSize = 32
        bestScoreLabel.text = "Best Score: \(bestScore)"
        addChild(bestScoreLabel)
        
        
        makePlatform()
        makePlatform2()
        makePlatform3()
        makePlatform4()
        makePlatform5()
        makePlatform6()
        
        
        cam.setScale(1.5)
        cam.position.x = player.position.x
        camera = cam
        
    }
    override func update(_ currentTime: TimeInterval) {
//        cam.position = CGPoint(x: size.width / 2, y: player.position.y + 200)
        cam.position.y = player.position.y + 200
        background.position.y = player.position.y +  200
        background.setScale(1.5)
        
        if player.physicsBody!.velocity.dy > 0 {
            gameOverLine.position.y = player.position.y - 600 //remove the platform
        }
        scoreLabel.position.y = player.position.y + 700
        bestScoreLabel.position.y = player.position.y + 650
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody
        let contactB: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            contactA = contact.bodyA //player
            contactB = contact.bodyB //platform
            
        }else{
            contactA = contact.bodyB //player
            contactB = contact.bodyA //platform
        }
        
        if contactA.categoryBitMask == bitmasks.platform.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            contactA.node?.removeFromParent()
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue{
            if player.physicsBody!.velocity.dy < 0 {
                player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 1200)
                contactB.node?.removeFromParent()
                makePlatform5()
                makePlatform6()
                addScore()
            }
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            gameOver()
        }
            
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            
            player.position.x = location.x
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        player.physicsBody?.isDynamic = true
        if firstTouch == false{
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1100 ))
        }
        firstTouch = true
        
        
    }
    
    func makePlatform(){
        let platform = SKSpriteNode(imageNamed: "ground_grass_broken")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 140, highestValue: 300).nextInt() + Int(player.position.y) )
        //platform.position = CGPoint(x: size.width / 2, y : size.height / 2 )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.2)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    func makePlatform2(){
        let platform = SKSpriteNode(imageNamed: "ground_grass_broken")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 350, highestValue: 550).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.2)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    func makePlatform3(){
        let platform = SKSpriteNode(imageNamed: "ground_grass_broken")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 600, highestValue: 800).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.2)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    func makePlatform4(){
        let platform = SKSpriteNode(imageNamed: "ground_grass_broken")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 850, highestValue: 1050).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.2)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    func makePlatform5(){
        let platform = SKSpriteNode(imageNamed: "ground_grass_broken")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 1100, highestValue: 1300).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.2)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    func makePlatform6(){
        let platform = SKSpriteNode(imageNamed: "ground_grass_broken")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 1350, highestValue: 1550).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.2)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    
//    func makePlatform2(){
//
//        let platform2 = SKSpriteNode(imageNamed: "ground_grass_broken")
//        platform2.position = CGPoint(x: size.width / 2, y : size.height / 4 + player.position.y)
//        platform2.zPosition = 5
//        platform2.physicsBody = SKPhysicsBody(rectangleOf: platform2.size)
//        platform2.setScale(0.2)
//
//        platform2.physicsBody?.isDynamic = false
//        platform2.physicsBody?.allowsRotation = false
//        platform2.physicsBody?.affectedByGravity = false
//        platform2.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
//        platform2.physicsBody?.collisionBitMask = 0
//        platform2.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
//
//        addChild(platform2)
//    }
    
    func gameOver()
    {
        let gameOverScene = GameOverScene(size: self.size)
        let transition = SKTransition.crossFade(withDuration: 0.5)
        
        view?.presentScene(gameOverScene, transition: transition)
        
        if score > bestScore{
            bestScore = score
            defaults.set(bestScore, forKey: "best")
        }
        
    }
    
    func addScore(){
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
}
