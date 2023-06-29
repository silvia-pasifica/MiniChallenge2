//
//  GameScene.swift
//  DoodleJump
//
//  Created by Maria Berliana on 13/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class PipingSector: SKScene, SKPhysicsContactDelegate{
    let bg1 = SKSpriteNode(imageNamed: "bg1-1")
    let player = SKSpriteNode(imageNamed: "idle-front")
    let ground = SKSpriteNode(imageNamed: "platform")
    let bg2 = SKSpriteNode(imageNamed: "bg1-2")
    let bg3 = SKSpriteNode(imageNamed: "bg1-3")
    let bg4 = SKSpriteNode(imageNamed: "bg1-4")
    let bg5 = SKSpriteNode(imageNamed: "bg1-5")
    let bg6 = SKSpriteNode(imageNamed: "bg1-6")
    let bg7 = SKSpriteNode(imageNamed: "bg1-7")
    let bg8 = SKSpriteNode(imageNamed: "bg1-8")
    let bg9 = SKSpriteNode(imageNamed: "bg1-9")
    
    let maxPlatformCount = 10
    var lampSpawnTimer: Timer?
    let circleNode = SKShapeNode(circleOfRadius: 500)
    let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let defaults = UserDefaults.standard
    var score = 0
    var bestScore = 0
    var particlePlatform : SKEmitterNode = SKEmitterNode(fileNamed: "smoke")!
    let howToPlayLabel = SKLabelNode()
    let handTapLabel = SKSpriteNode(imageNamed: "hand-tap")
    var tutorials = ["Tilt to Move", "Grab The Lamps", "Double Tap to Jump Higher"]
    var platformCount = 0
    var firstDoubleTap = false
    
    var glow = false
    var radialNodes: [SKSpriteNode] = []
    var currentRadialIndex = 0
    
    let cam = SKCameraNode()
    let motionActivity = Motion()
    var timer: Timer?
    var countdown: Int = -1
    var doubleJumpIsEnabled = false
    var staminaBar = StaminaBar()
    var facing = "front"
    var lampPosition = 0.0
    
    let textureArrayRight = [SKTexture(imageNamed: "jump-right-1"), SKTexture(imageNamed: "jump-right-2"), SKTexture(imageNamed: "jump-right-3")]
    let textureArrayFront = [SKTexture(imageNamed: "jump-front-1"), SKTexture(imageNamed: "jump-front-2"), SKTexture(imageNamed: "jump-front-3")]
    let textureArrayLeft = [SKTexture(imageNamed: "jump-left-1"), SKTexture(imageNamed: "jump-left-2"), SKTexture(imageNamed: "jump-left-3")]
    
    private var lamp: SKSpriteNode!
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case lamp = 0b100
        case gameOverLine = 0b1000
        case particlePlatform = 0b10000
        case casette = 0b100000
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
        
        bg8.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg8.zPosition = 3
        bg8.setScale(0.4)
        addChild(bg8)
        
        bg9.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg9.zPosition = 3
        bg9.setScale(0.4)
        addChild(bg9)
        
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
        
        makePlatform(lowestValueY: 120, highestValueY: 300)
        makePlatform(lowestValueY: 350, highestValueY: 500)
        makePlatform(lowestValueY: 550, highestValueY: 700)
        makePlatform(lowestValueY: 750, highestValueY: 950)
        makePlatform(lowestValueY: 970, highestValueY: 1150)
        makePlatform(lowestValueY: 1200, highestValueY: 1350)
        
        cam.setScale(1.0)
        cam.position.x = player.position.x
        camera = cam
        
        containerNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        containerNode.zPosition = 25
        addChild(containerNode)
        
        circleNode.fillColor = SKColor.clear
        circleNode.lineWidth = 550.0
        circleNode.strokeColor = SKColor.black
        circleNode.alpha = 0.857
        circleNode.glowWidth = 150
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
        
        showTutorial()
        howToPlayLabel.text = "Touch to Start"
        howToPlayLabel.color = .white
        howToPlayLabel.fontSize = 30
        howToPlayLabel.zPosition = 2000
        howToPlayLabel.position = CGPoint(x: size.width / 2, y: 50)
        addChild(howToPlayLabel)
        
        handTapLabel.zPosition = 3000
        handTapLabel.position = CGPoint(x: size.width / 2, y: 10)
        handTapLabel.run(SKAction.repeatForever(SKAction.sequence([SKAction.scale(to: 1.2, duration: 1), SKAction.scale(to: 1, duration: 1)])))
        addChild(handTapLabel)
        
        playMusic(music: "stage1-backsound.mp3", loop: -1, volume: 1)
    }
    
    func showTutorial() {
        howToPlayLabel.text = tutorials[platformCount / 4]
        howToPlayLabel.isHidden = false
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
        
        radialNode.run(sequenceAction) {[self] in
            if self.currentRadialIndex != 0 {
                self.showNextRadial()
            } else {
                glow = false
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        cam.position.y = player.position.y + 200
        bg1.position.y = player.position.y + 200
        bg2.position.y = player.position.y + 200
        bg3.position.y = player.position.y + 200
        bg4.position.y = player.position.y + 200
        bg5.position.y = player.position.y + 200
        bg6.position.y = player.position.y + 200
        bg7.position.y = player.position.y + 200
        bg8.position.y = player.position.y + 200
        bg9.position.y = player.position.y + 200
        howToPlayLabel.position.y = player.position.y - 100
        handTapLabel.position.y = player.position.y - 150
        
        staminaBar.updatePosition(playerPos: player.position.y)
        
        for (index, radialNode) in radialNodes.enumerated() {
            radialNode.position = player.position
        }
        
        if player.physicsBody!.velocity.dy > 0 {
            gameOverLine.position.y = player.position.y - 600 //remove the platform
        }
        scoreLabel.position.y = player.position.y + 700
        bestScoreLabel.position.y = player.position.y + 650
        
        let newPosition = player.position.x + motionActivity.getAccelerometerDataX()
                
        if platformCount == 1 {
            showTutorial()
        }
        
        if platformCount % 4 == 0 && platformCount / 4 < tutorials.count && platformCount > 0 {
            showTutorial()
        }
        
        if newPosition >= 10 && newPosition <= 380 {
            let difference = player.position.x - newPosition
            
            player.position.x = newPosition
            bg2.position.x += difference / 11
            bg3.position.x += difference / 4
            bg4.position.x += difference / 8
            bg5.position.x -= difference / 10
            bg7.position.x += difference / 10
            
            if player.position.x >= 150 && player.position.x <= 240 {
                if facing != "front" {
                    facing = "front"
                    player.run(SKAction.setTexture(textureArrayFront[0], resize: true))
                    player.run(SKAction.repeatForever(SKAction.animate(with: textureArrayFront, timePerFrame: 0.1)))
                }
            } else if player.position.x < 150 {
                if facing != "left" {
                    facing = "left"
                    player.run(SKAction.setTexture(textureArrayLeft[0], resize: true))
                    player.run(SKAction.repeatForever(SKAction.animate(with: textureArrayLeft, timePerFrame: 0.1)))
                }
            } else {
                if facing != "right" {
                    facing = "right"
                    player.texture = textureArrayRight[0]
                    player.run(SKAction.setTexture(textureArrayRight[0], resize: true))
                    player.run(SKAction.repeatForever(SKAction.animate(with: textureArrayRight, timePerFrame: 0.1)))
                }
            }
        }
        containerNode.position = player.position
    }
    
    @objc func doubleTapped() {
        
        if platformCount > 8 && !firstDoubleTap {
            doubleJumpIsEnabled = true
            howToPlayLabel.isHidden = true
            firstDoubleTap = true
        }
        
        if doubleJumpIsEnabled {
            doubleJumpIsEnabled = false
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1000 ))
            playMusic(music: "double-jump.mp3", loop: 0, volume: 1)
            if platformCount < maxPlatformCount - 1 {
                makePlatform(lowestValueY: 1100, highestValueY: 1300)
            }
            if platformCount < maxPlatformCount - 1 {
                makePlatform(lowestValueY: 1350, highestValueY: 1550)
            }
            if platformCount < maxPlatformCount - 1 {
                makePlatform(lowestValueY: 1600, highestValueY: 1800)
            }
            if platformCount < maxPlatformCount - 1 {
                makePlatform(lowestValueY: 1850, highestValueY: 2050)
            }
            if platformCount < maxPlatformCount - 1 {
                makePlatform(lowestValueY: 2100, highestValueY: 2300)
            }
            if platformCount < maxPlatformCount - 1 {
                makePlatform(lowestValueY: 2350, highestValueY: 2550)
            }
            countdown = 8
            staminaBar.decreaseStaminaBar()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.staminaBar.increaseStaminaBar()
            }
        }
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
            
                if player.position.x >= 150 && player.position.x <= 240 {
                    player.texture = SKTexture(imageNamed: "idle-front")
                } else if player.position.x < 150 {
                    player.texture = SKTexture(imageNamed: "idle-left")
                } else {
                    player.texture = SKTexture(imageNamed: "idle-right")
                }
                
                
                if platformCount == maxPlatformCount {
                    makePlatform(lowestValueY: 1200, highestValueY: 1350)
                } else if platformCount < maxPlatformCount {
                    makePlatform(lowestValueY: 970, highestValueY: 1150)
                    makePlatform(lowestValueY: 1200, highestValueY: 1350)
                    addScore()
                }
                
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
                particlePlatform!.alpha = 0.8
                addChild(particlePlatform!)
                particlePlatform!.run(SKAction.sequence([smokeFade, .removeFromParent()]))
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.impactOccurred()
                
                playMusic(music: "jump.mp3", loop: 0, volume: 1)
                
                platformCount += 1
                
                contactB.node?.removeFromParent()
            }
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            gameOver()
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.lamp.rawValue{
            playMusic(music: "pickup-item-2.mp3", loop: 0, volume: 1)
            glowArea()
            contactB.node?.removeFromParent()
        }
        
        if (player.physicsBody?.velocity.dy)! < 0 {
            if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.casette.rawValue{
                playMusic(music: "pickup-item-2.mp3", loop: 0, volume: 1)
                contactB.node?.removeFromParent()
                
                self.view?.presentScene(AsylumCafetaria(size: self.size), transition: SKTransition.fade(withDuration: 3))
            }
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
            firstTouch = true
            player.run(SKAction.setTexture(textureArrayFront[0], resize: true))
            player.run(SKAction.repeatForever(SKAction.animate(with: textureArrayFront, timePerFrame: 0.1)))
            motionActivity.startAccelorometerUpdate()
            handTapLabel.isHidden = true
            howToPlayLabel.isHidden = true
        }
    }
    
    func makePlatform(lowestValueY: Int, highestValueY: Int){
        let platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: GKRandomDistribution( lowestValue: lowestValueY, highestValue: highestValueY).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(platformCount == maxPlatformCount ? 1.0 : 0.5)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        if platformCount == maxPlatformCount {
            platform.position.x = size.width / 2
            let casette = SKSpriteNode(imageNamed: "casette")
            casette.position = CGPoint(x: size.width / 2, y: platform.position.y + 100
            )
            casette.zPosition = platform.zPosition + 1
            casette.physicsBody = SKPhysicsBody(rectangleOf: casette.size)
            casette.setScale(0.3)
            casette.physicsBody?.isDynamic = false
            casette.physicsBody?.allowsRotation = false
            casette.physicsBody?.affectedByGravity = false
            casette.physicsBody?.categoryBitMask = bitmasks.casette.rawValue
            casette.physicsBody?.collisionBitMask = 0
            casette.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
            addChild(casette)
        } else {
            
            var randomChance = 0
            
            if platformCount > 10 {
                randomChance = Int(arc4random_uniform(20))
            } else if platformCount == 3 {
                randomChance = 5
            }
            
            if randomChance == 5 {
                let radio = SKSpriteNode(imageNamed: "radio")
                radio.position = CGPoint(x: CGFloat(GKRandomDistribution(lowestValue: Int(platform.position.x - 50), highestValue: Int(platform.position.x + 50)).nextInt()), y: platform.position.y + platform.size.height - 10)
                radio.zPosition = platform.zPosition + 1
                radio.physicsBody = SKPhysicsBody(rectangleOf: radio.size)
                radio.setScale(0.3)
                radio.physicsBody?.isDynamic = false
                radio.physicsBody?.allowsRotation = false
                radio.physicsBody?.affectedByGravity = false
                radio.physicsBody?.categoryBitMask = bitmasks.lamp.rawValue
                radio.physicsBody?.collisionBitMask = 0
                radio.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
                addChild(radio)
                
                lampPosition = radio.position.y
            }
        }
        
        addChild(platform)
    }
    
    @objc func fireTimer() {
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
