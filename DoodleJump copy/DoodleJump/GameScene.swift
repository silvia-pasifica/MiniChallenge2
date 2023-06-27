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
    let background = SKSpriteNode(imageNamed: "bg1")
    let player = SKSpriteNode(imageNamed: "iris")
    let ground = SKSpriteNode(imageNamed: "platformBiasa")
    let tree = SKSpriteNode(imageNamed: "bg2")
    let dog = SKSpriteNode(imageNamed: "bg3")
    let bg4 = SKSpriteNode(imageNamed: "bg4")
    let bg5 = SKSpriteNode(imageNamed: "bg5")
    let bg6 = SKSpriteNode(imageNamed: "bg6")
    let bg7 = SKSpriteNode(imageNamed: "bg7")
    let bg8 = SKSpriteNode(imageNamed: "bg8")
    let bg9 = SKSpriteNode(imageNamed: "bg9")
    var lampSpawnTimer: Timer?
    let circleNode = SKShapeNode(circleOfRadius: 500)
    let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let defaults = UserDefaults.standard
    var score = 0
    var bestScore = 0
    let cam = SKCameraNode()
    let motionActivity = Motion()
    
    var playerArray = [SKTexture]()
    
    private var lamp: SKSpriteNode!
    var radialNodes: [SKSpriteNode] = []
    var currentRadialIndex = 0
    var glow = false
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case lamp = 0b100
        case gameOverLine = 0b1000
        case particlePlatform = 0b10000
    }
    let containerNode = SKNode()
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = .zero
        
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.setScale(0.37)
        background.zPosition = 1
        addChild(background)
        
        tree.position = CGPoint(x: size.width / 2, y: size.height / 2)
        tree.zPosition = 2
        tree.setScale(0.4)
        addChild(tree)
        
        dog.position = CGPoint(x: size.width / 2, y: size.height / 2)
        dog.zPosition = 3
        dog.setScale(0.4)
        addChild(dog)
        
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
        bg7.setScale(0.37)
        addChild(bg7)
        
        bg8.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg8.zPosition = 3
        bg8.setScale(0.4)
        addChild(bg8)
        
        bg9.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg9.zPosition = 3
        bg9.setScale(0.4)
        addChild(bg9)
        
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
        player.setScale(0.4)
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
        
        playerArray.append(SKTexture(imageNamed: "1"))
        playerArray.append(SKTexture(imageNamed: "2"))
        playerArray.append(SKTexture(imageNamed: "3"))
        
        
        cam.setScale(1.0)
        cam.position.x = player.position.x
        camera = cam
        
        
        containerNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        containerNode.zPosition = 25
        addChild(containerNode)
        // Membuat lingkaran node
        
        circleNode.fillColor = SKColor.clear
        // Menambahkan bayangan luar
        circleNode.lineWidth = 550.0
        circleNode.strokeColor = SKColor.black
        circleNode.alpha = 0.857
//        circleNode.alpha = 0.857
        circleNode.glowWidth = 150 // Mengatur lebar bayangan luar
       
        // Menambahkan lingkaran node ke dalam wadah node
        containerNode.addChild(circleNode)
        
        for i in 1...9 {
            let radialTexture = SKTexture(imageNamed: "Radial\(i)")
            let radialNode = SKSpriteNode(texture: radialTexture)
            radialNode.position = CGPoint(x: player.position.x, y: player.position.y)
            radialNode.alpha = 0
            radialNode.zPosition = 9
            addChild(radialNode)
            radialNodes.append(radialNode)
        }
        
        if glow {
            showNextRadial()
        }
        
        
    }
    func showNextRadial() {
        let fadeInDuration: TimeInterval = 0.2
        let fadeOutDuration: TimeInterval = 0.1
        
        let radialNode = radialNodes[currentRadialIndex]
        currentRadialIndex = (currentRadialIndex + 1) % radialNodes.count
        
        let fadeInAction = SKAction.fadeIn(withDuration: fadeInDuration)
        let fadeOutAction = SKAction.fadeOut(withDuration: fadeOutDuration)
        let waitAction = SKAction.wait(forDuration: fadeOutDuration)
        
        let sequenceAction = SKAction.sequence([fadeInAction, waitAction, fadeOutAction])
        
        radialNode.run(sequenceAction) { [self] in
            if self.currentRadialIndex != 0 {
                self.showNextRadial()
            }
            else{
                glow = false
            }
        }
        
    }
   
    override func update(_ currentTime: TimeInterval) {
//        cam.position = CGPoint(x: size.width / 2, y: player.position.y + 200)
        cam.position.y = player.position.y + 200
        background.position.y = player.position.y +  200
        
        tree.position.y = player.position.y + 200
        dog.position.y = player.position.y + 200
        bg4.position.y = player.position.y + 200
        bg5.position.y = player.position.y + 200
        bg6.position.y = player.position.y + 200
        bg7.position.y = player.position.y + 200
        bg8.position.y = player.position.y + 200
        bg9.position.y = player.position.y + 200
        
        for (index, radialNode) in radialNodes.enumerated() {
                radialNode.position = player.position
            }
        
        if player.physicsBody!.velocity.dy == 1200 {
            player.texture = SKTexture(imageNamed: "1")
        }
        
        if player.physicsBody!.velocity.dy > 0 {
            gameOverLine.position.y = player.position.y - 600 //remove the platform
        }
        scoreLabel.position.y = player.position.y + 700
        bestScoreLabel.position.y = player.position.y + 650
        
        let newPosition = player.position.x + motionActivity.getAccelerometerDataX()
        
        if newPosition >= -40 && newPosition <= 430 {
            let difference = player.position.x - newPosition
            
            player.position.x = newPosition
            tree.position.x = size.width / 2 - newPosition / 13
            bg4.position.x = size.width / 2 - newPosition / 14
            bg7.position.x = size.width / 2 - newPosition / 24
            
            if player.position.x >= 150 && player.position.x <= 240 {
                player.texture = SKTexture(imageNamed: "iris")
            } else if player.position.x < 150 {
                player.texture = SKTexture(imageNamed: "2")
            } else {
                player.texture = SKTexture(imageNamed: "3")
            }
        }
        containerNode.position = player.position
    }
    
    @objc func doubleTapped() {
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1100 ))
        makePlatform5()
        makePlatform6()
        makePlatform7()
        makePlatform8()
        makePlatform9()
        makePlatform10()
        makePlatform11()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        let particlePlatform = SKEmitterNode(fileNamed: "smoke")
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
                
                makePlatform5()
                makePlatform6()
                addScore()
                
                particlePlatform!.zPosition = 6
                particlePlatform!.position = CGPoint(x: player.position.x, y: player.position.y)
                particlePlatform!.setScale(0.8)
                particlePlatform!.physicsBody?.isDynamic = false
                particlePlatform!.physicsBody?.allowsRotation = false
                particlePlatform!.physicsBody?.affectedByGravity = false
                particlePlatform!.physicsBody?.categoryBitMask = bitmasks.particlePlatform.rawValue
                particlePlatform!.physicsBody?.collisionBitMask = 0
                particlePlatform!.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
                let smokeFade = SKAction.fadeOut(withDuration: 1.0)
                particlePlatform!.alpha = 0.2
                
                addChild(particlePlatform!)
                particlePlatform!.run(SKAction.sequence([smokeFade, .removeFromParent()]))
                
            }
            
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            gameOver()
        }
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.lamp.rawValue{
            glowArea()
            contactB.node?.removeFromParent()
        }
    }
    
    func glowArea(){
        let fadeOutAction = SKAction.fadeAlpha(to: 0.3, duration: 5.0)
        let fadeInAction = SKAction.fadeAlpha(to: 0.857, duration: 10.00)
        let sequenceAction = SKAction.sequence([fadeOutAction, fadeInAction])
        
        circleNode.run(sequenceAction)
        glow = true
        showNextRadial()
            
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        player.physicsBody?.isDynamic = true
        if firstTouch == false{
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1000 ))

//            player.run(SKAction.animate(with: playerArray, timePerFrame: 0.5))
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
        
        let randomChance = Int(arc4random_uniform(7))
        if randomChance == 5{
            let lamp = SKSpriteNode(imageNamed: "lamp")
            lamp.position = CGPoint(x: CGFloat(GKRandomDistribution(lowestValue: Int(platform.position.x - 50), highestValue: Int(platform.position.x + 50)).nextInt()), y: platform.position.y + platform.size.height - 10)
            lamp.zPosition = platform.zPosition + 1
            lamp.physicsBody = SKPhysicsBody(rectangleOf: lamp.size)
            lamp.setScale(0.1)
            lamp.physicsBody?.isDynamic = false
            lamp.physicsBody?.allowsRotation = false
            lamp.physicsBody?.affectedByGravity = false
            lamp.physicsBody?.categoryBitMask = bitmasks.lamp.rawValue
            lamp.physicsBody?.collisionBitMask = 0
            lamp.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
            
            addChild(lamp)
            
        }
        
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
    
    func makePlatform11(){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: 2600, highestValue: 2800).nextInt() + Int(player.position.y) )
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
