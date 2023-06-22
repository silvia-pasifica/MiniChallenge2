//
//  Stage 3.swift
//  DoodleJump
//
//  Created by Silvia Pasica on 16/06/23.
//100 platform

import Foundation
import SpriteKit
import GameplayKit


class Stage_3: SKScene, SKPhysicsContactDelegate{
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
    private var platform : SKSpriteNode!
    var platformHeight = CGFloat()
    
    let cam = SKCameraNode()
    let motionActivity = Motion()
    
    private var monster: SKSpriteNode!
    let random = GKRandomDistribution(lowestValue: 0, highestValue: 6)
    
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case gameOverLine = 0b100
        case monster = 0b1000
    }
    
    override func didMove(to view: SKView) {
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
        player.setScale(0.2)
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
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 970, highestValueY: 1150)
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1200, highestValueY: 1350)
        
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
                
                if score % 3 == 0{
                    let randMonster = random.nextInt()
                    if randMonster == 0 {
                        dynamicMonster(imageMonsterName: "tanganKiri1", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 1, scale: 0.4)
                        dynamicMonster(imageMonsterName: "tanganKanan1", platformLowestXPosition: 0, platformXHighestPosition: 405, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 2, scale: 0.4)
                        
                    }else if randMonster == 1 {
                        dynamicMonster(imageMonsterName: "tanganKanan1", platformLowestXPosition: 0, platformXHighestPosition: 405, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 2, scale: 0.4)
                    }else if randMonster == 2 {
                        dynamicMonster(imageMonsterName: "tanganKanan2", platformLowestXPosition: 0, platformXHighestPosition: 405, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 2, scale: 0.4)
                    }else if randMonster == 3 {
                        dynamicMonster(imageMonsterName: "tanganKiri1", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 1, scale: 0.4)
                    }else if randMonster == 4 {
                        dynamicMonster(imageMonsterName: "tanganKiri2", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 1, scale: 0.4)
                    }else if randMonster == 5 {
                        dynamicMonster(imageMonsterName: "kepalaPasien2", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 850, platformYHighestPosition: 1000, leftOrRight: 1, scale: 0.6)
                    }else if randMonster == 6 {
                        dynamicMonster(imageMonsterName: "kepalaPasien1", platformLowestXPosition: 350, platformXHighestPosition: 350, platformLowestYPosition: 850, platformYHighestPosition: 1000, leftOrRight: 2, scale: 0.6)
                    }
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
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        player.physicsBody?.isDynamic = true
        if firstTouch == false{
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1200 ))
        }
        firstTouch = true
        motionActivity.startAccelorometerUpdate()
        
    }
    //
    func createPlatform(){
        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 1120, highestValueY: 1300)
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1350, highestValueY: 1500)
        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 1550, highestValueY: 1700)
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1750, highestValueY: 1800)
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
        //        latestPlatformPoints = platform.position
        
        addChild(platform)
    }
    
   
    func dynamicMonster(imageMonsterName : String, platformLowestXPosition: Int, platformXHighestPosition: Int, platformLowestYPosition: Int, platformYHighestPosition: Int, leftOrRight: Int, scale: Double){
        monster = SKSpriteNode(imageNamed: imageMonsterName)
        monster.zPosition = 10
        monster.setScale(scale)
        
        let initialX = leftOrRight == 1 ? platformLowestXPosition : platformXHighestPosition
        let initialY = GKRandomDistribution(lowestValue: platformLowestYPosition, highestValue: platformYHighestPosition).nextInt() + Int(player.position.y)
        monster.position = CGPoint(x: initialX, y: initialY)
        
        monster.physicsBody = SKPhysicsBody(texture: monster.texture!, size: monster.size)
        monster.physicsBody?.isDynamic = false
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = bitmasks.monster.rawValue
        monster.physicsBody?.collisionBitMask = 0
        monster.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(monster)
        
        //1 = left; 2 = right
        if leftOrRight == 1 {
            monster.position.x = frame.minX - monster.size.width / 2
        } else {
            monster.position.x = frame.maxX + monster.size.width / 2
        }
        
        let targetX: CGFloat = leftOrRight == 1 ? frame.midX - monster.size.width  : frame.midX + monster.size.width
        
        // Calculate duration based on distance and desired speed
        let distance = abs(targetX - monster.position.x)
        let speed: CGFloat = 150.0 // Adjust as needed
        let duration = distance / speed
        var resetPositionX: Int
        if leftOrRight == 1 {
            resetPositionX = -80
        }else {
            resetPositionX = 500
        }
        // Move platform
        let moveAction = SKAction.move(to: CGPoint(x: targetX, y: monster.position.y), duration: TimeInterval(duration))
        let resetPositionAction = SKAction.run { [weak self] in
            self?.monster.position = CGPoint(x: resetPositionX, y: initialY)
        }
        let delayAction = SKAction.wait(forDuration: 1.0)
        let sequenceAction = SKAction.sequence([moveAction, delayAction, resetPositionAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
            
        monster.run(repeatAction)
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
