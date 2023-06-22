//
//  SurgeryRoom.swift
//  DoodleJump
//
//  Created by Silvia Pasica on 22/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class SurgeryRoom: SKScene, SKPhysicsContactDelegate{
    private var background = SKSpriteNode(imageNamed: "background")
    private var player = SKSpriteNode(imageNamed: "iris belakang")
    private var ground = SKSpriteNode(imageNamed: "ground_grass")
    private var monster: SKSpriteNode!
    private var platform : SKSpriteNode!
    private var knife: SKSpriteNode!
    private let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let defaults = UserDefaults.standard
    var score = 0
    var bestScore = 0
    
    var platformHeight = CGFloat()
    let cam = SKCameraNode()
    let motionActivity = Motion()
    let random = GKRandomDistribution(lowestValue: 0, highestValue: 4)
    
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case gameOverLine = 0b100
        case monster = 0b1000
    }
    
    enum PlatformDirection {
        case leftToRight
        case rightToLeft
    }
    
    override func didMove(to view: SKView){
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = .zero
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = 1
        addChild(background)
        
        physicsWorld.contactDelegate = self
        
        ground.position = CGPoint(x: frame.midX , y: -300)
        ground.zPosition = 5
        ground.setScale(1.0)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.affectedByGravity = false
        addChild(ground)
        
        player.position = CGPoint(x: size.width / 2, y: -180)
        player.zPosition = 10
        player.setScale(0.5)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.restitution = 0
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
        
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 120, highestValueY: 300)
        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 350, highestValueY: 500)
        makePlatform(lowestValueX: 20, highestValueX: 450, lowestValueY: 550, highestValueY: 700)
        makePlatform(lowestValueX: 10, highestValueX: 350, lowestValueY: 750, highestValueY: 950)
        makePlatform(lowestValueX: 5, highestValueX: 450, lowestValueY: 990, highestValueY: 1150)
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1200, highestValueY: 1350)
        
        cam.setScale(1.5)
        cam.position.x = player.position.x
        camera = cam
    }
    
    override func update(_ currentTime: TimeInterval){
        cam.position.y = player.position.y + 200
        background.position.y = player.position.y +  200
        background.setScale(1.5)
        
        if player.physicsBody!.velocity.dy > 0 {
            gameOverLine.position.y = player.position.y - 600
        }
        scoreLabel.position.y = player.position.y + 700
        bestScoreLabel.position.y = player.position.y + 650
        
        var newPosition = player.position.x + motionActivity.getAccelerometerDataX()
        
        if newPosition >= -40 && newPosition <= 430 {
            player.position.x = newPosition
        }
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
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue{
            if player.physicsBody!.velocity.dy < 0 {
                player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 1500)
                if(platformHeight < player.position.y && score != 100){
                    platformHeight = player.position.y + 20
                    createPlatform()
                    addScore()
                }
            }
        }
        
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            gameOver()
        }
        
        //logic monster
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.monster.rawValue{
            gameOver()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        player.physicsBody?.isDynamic = true
        if firstTouch == false{
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1200 ))
        }
        firstTouch = true
        motionActivity.startAccelorometerUpdate()
    }
    
    func createPlatform(){
        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 1120, highestValueY: 1300)
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1350, highestValueY: 1500)
        makePlatform(lowestValueX: 5, highestValueX: 450, lowestValueY: 1550, highestValueY: 1700)
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1800, highestValueY: 1950)
    }
    
    func makePlatform(lowestValueX: Int, highestValueX: Int, lowestValueY: Int, highestValueY: Int){
        platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: lowestValueX, highestValue: highestValueX).nextInt(), y: GKRandomDistribution( lowestValue: lowestValueY, highestValue: highestValueX).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.5)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    
    func createKnife(){
        knife = SKSpriteNode(imageNamed: "knife")
//        knife.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: frame.maxY)
        knife.zPosition = 6
    }
    
    
    func gameOver(){
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
