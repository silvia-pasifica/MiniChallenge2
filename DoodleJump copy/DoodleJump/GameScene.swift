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
    let bg1 = SKSpriteNode(imageNamed: "bg1")
    let player = SKSpriteNode(imageNamed: "idle-front")
    let ground = SKSpriteNode(imageNamed: "platformBiasa")
    let bg2 = SKSpriteNode(imageNamed: "bg2")
    let bg3 = SKSpriteNode(imageNamed: "bg3")
    let bg4 = SKSpriteNode(imageNamed: "bg4")
    let bg5 = SKSpriteNode(imageNamed: "bg5")
    let bg6 = SKSpriteNode(imageNamed: "bg6")
    let bg7 = SKSpriteNode(imageNamed: "bg7")
    
    let lamp = SKSpriteNode(imageNamed: "lamp")
    let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let defaults = UserDefaults.standard
    var score = 0
    var bestScore = 0
    
    let cam = SKCameraNode()
    let motionActivity = Motion()
    var timer: Timer?
    var countdown: Int = -1
    var doubleJumpIsEnabled = true
    var staminaBar = StaminaBar()
    
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case lamp = 0b11
        case gameOverLine
    }
    let containerNode = SKNode()
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = .zero
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        
        bg1.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg1.setScale(0.37)
        bg1.zPosition = 1
        addChild(bg1)
        
        bg2.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg2.zPosition = 2
        bg2.setScale(0.4)
        addChild(bg2)
        
        bg3.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg3.zPosition = 3
        bg3.setScale(0.4)
        addChild(bg3)
        
        bg4.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg4.zPosition = 3
        bg4.setScale(0.4)
        addChild(bg4)
        
        bg5.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg5.zPosition = 3
        bg5.setScale(0.4)
        addChild(bg5)
        
        bg6.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg6.zPosition = 3
        bg6.setScale(0.4)
        addChild(bg6)
        
        bg7.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg7.zPosition = 3
        bg7.size = CGSize(width: size.width + 40, height: size.height)
        addChild(bg7)
        
        physicsWorld.contactDelegate = self
        
        staminaBar.getSceneFrame(sceneFrame: frame)
        staminaBar.buildStaminaBar()
        addChild(staminaBar)
        
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
        player.setScale(0.4)
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.height / 2)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.restitution = 1
        player.physicsBody?.friction = 0
        player.physicsBody?.angularDamping = 0
        
        player.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.gameOverLine.rawValue | bitmasks.lamp.rawValue
        addChild(player)
        
        gameOverLine.position = CGPoint(x: player.position.x, y: player.position.y - 200)
        gameOverLine.zPosition = -1
        gameOverLine.physicsBody = SKPhysicsBody(rectangleOf: gameOverLine.size)
        gameOverLine.physicsBody?.affectedByGravity = false
        gameOverLine.physicsBody?.allowsRotation = false
        gameOverLine.physicsBody?.categoryBitMask = bitmasks.gameOverLine.rawValue
        gameOverLine.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.player.rawValue
        addChild(gameOverLine)
        
//        scoreLabel.position.x = 50
        scoreLabel.zPosition = 2001
        scoreLabel.fontColor = .white
        scoreLabel.fontSize = 100
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
        
        cam.setScale(1.0)
        cam.position.x = player.position.x
        camera = cam
        
        let circleSize: CGFloat = 500
        
        // Membuat wadah node
        
        containerNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        containerNode.zPosition = 25
        addChild(containerNode)
        // Membuat lingkaran node
        let circleNode = SKShapeNode(circleOfRadius: circleSize)
        circleNode.fillColor = SKColor.clear
        // Menambahkan bayangan luar
        circleNode.lineWidth = 550.0
        circleNode.strokeColor = SKColor.black
        circleNode.alpha = 0.857
//        circleNode.alpha = 0.857
        circleNode.glowWidth = 150 // Mengatur lebar bayangan luar
       
        // Menambahkan lingkaran node ke dalam wadah node
//        containerNode.addChild(circleNode)
    }
    override func update(_ currentTime: TimeInterval) {
//        cam.position = CGPoint(x: size.width / 2, y: player.position.y + 200)
        
        cam.position.y = player.position.y + 200
        bg1.position.y = player.position.y + 200
        bg2.position.y = player.position.y + 200
        bg3.position.y = player.position.y + 200
        bg4.position.y = player.position.y + 200
        bg5.position.y = player.position.y + 200
        bg6.position.y = player.position.y + 200
        bg7.position.y = player.position.y + 200
        staminaBar.updatePosition(playerPos: player.position.y)
        
        if player.physicsBody!.velocity.dy == 1200 {
            player.texture = SKTexture(imageNamed: "idle-front")
        }
        
        if player.physicsBody!.velocity.dy > 0 {
            gameOverLine.position.y = player.position.y - 600 //remove the platform
        }
        scoreLabel.position.y = player.position.y + 700
        bestScoreLabel.position.y = player.position.y + 650
        
        let newPosition = player.position.x + motionActivity.getAccelerometerDataX()
        
        if newPosition >= 10 && newPosition <= 380 {
            let difference = player.position.x - newPosition
            
            player.position.x = newPosition
            bg2.position.x += difference / 11
            bg3.position.x += difference / 4
            bg4.position.x += difference / 8
            bg5.position.x -= difference / 10
            bg7.position.x += difference / 10
            
            if player.position.x >= 150 && player.position.x <= 240 {
                player.texture = SKTexture(imageNamed: "jump-front")
            } else if player.position.x < 150 {
                player.texture = SKTexture(imageNamed: "jump-left")
            } else {
                player.texture = SKTexture(imageNamed: "jump-right")
            }
        }
        containerNode.position = player.position
    }
    
    @objc func doubleTapped() {
        if doubleJumpIsEnabled {
            doubleJumpIsEnabled = false
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1100 ))
            makePlatform5()
            makePlatform6()
            makePlatform7()
            makePlatform8()
            makePlatform9()
            makePlatform10()
            countdown = 8
            staminaBar.decreaseStaminaBar()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.staminaBar.increaseStaminaBar()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view!.addGestureRecognizer(tap)
        
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
                if player.position.x >= 150 && player.position.x <= 240 {
                    player.texture = SKTexture(imageNamed: "idle-front")
                } else if player.position.x < 150 {
                    player.texture = SKTexture(imageNamed: "idle-left")
                } else {
                    player.texture = SKTexture(imageNamed: "idle-right")
                }
                makePlatform5()
                makePlatform6()
                addScore()
            }
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            gameOver()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        player.physicsBody?.isDynamic = true
        if firstTouch == false{ 
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1000 ))
        }
        firstTouch = true
        motionActivity.startAccelorometerUpdate()
        
    }
    
    func makePlatform(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 140, highestValue: 300).nextInt() + Int(player.position.y) )
        //platform.position = CGPoint(x: size.width / 2, y : size.height / 2 )
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
    func makePlatform2(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 350, highestValue: 550).nextInt() + Int(player.position.y) )
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
    func makePlatform3(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 600, highestValue: 800).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.4)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    func makePlatform4(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 850, highestValue: 1050).nextInt() + Int(player.position.y) )
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
    func makePlatform5(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 1100, highestValue: 1300).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.4)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
        
//        
//        lamp.position = CGPoint(x: lamp.position.x, y: lamp.position.y + 5)
//        lamp.zPosition = 5
//        lamp.setScale(0.1)
//        addChild(lamp)
        
    }
    func makePlatform6(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 1350, highestValue: 1550).nextInt() + Int(player.position.y) )
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
    
    func makePlatform7(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 1600, highestValue: 1800).nextInt() + Int(player.position.y) )
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
    
    func makePlatform8(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 1850, highestValue: 2050).nextInt() + Int(player.position.y) )
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
    
    func makePlatform9(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 2100, highestValue: 2300).nextInt() + Int(player.position.y) )
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
    
    func makePlatform10(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 2350, highestValue: 2550).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.4)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    
    @objc func fireTimer() {
        print(countdown)
        if countdown == 0 {
            doubleJumpIsEnabled = true
        } else if countdown > 0 {
            countdown -= 1
        }
    }
    
    func gameOver()
    {
        let gameOverScene = GameOverScene(size: self.size)
        let transition = SKTransition.crossFade(withDuration: 0.5)
        timer!.invalidate()
        
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
