//
//  SurgeryRoom.swift
//  DoodleJump
//
//  Created by Silvia Pasica on 30/06/23.
//
import Foundation
import SpriteKit
import GameplayKit

class SurgeryRoom: SKScene, SKPhysicsContactDelegate{
    let bg1 = SKSpriteNode(imageNamed: "bg4-1")
    let player = SKSpriteNode(imageNamed: "idle-front")
    let ground = SKSpriteNode(imageNamed: "platform-4")
    let bg2 = SKSpriteNode(imageNamed: "bg4-2")
    let bg3 = SKSpriteNode(imageNamed: "bg4-3")
    let bg4 = SKSpriteNode(imageNamed: "bg4-4")
    let bg5 = SKSpriteNode(imageNamed: "bg4-5")
    let bg6 = SKSpriteNode(imageNamed: "bg4-6")
    let bg7 = SKSpriteNode(imageNamed: "bg4-7")
    let bg8 = SKSpriteNode(imageNamed: "bg4-8")
    let bg9 = SKSpriteNode(imageNamed: "bg4-9")
    let bg10 = SKSpriteNode(imageNamed: "bg4-10")
    let bg11 = SKSpriteNode(imageNamed: "bg4-11")
    let bg12 = SKSpriteNode(imageNamed: "bg4-12")
   
    let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    var firstTouch = false
    let defaults = UserDefaults.standard
    var score = 0
    var bestScore = 0
    private var platform : SKSpriteNode!
    var platformHeight = CGFloat()
    var platformheight = CGFloat()
    var randomPlatform = 0
    let cam = SKCameraNode()
    let motionActivity = Motion()
    
    let maxPlatformCount = 10
    var platformCount = 0
    var timer: Timer?
    var countdown: Int = -1
    var doubleJumpIsEnabled = true
    var staminaBar = StaminaBar()
    var facing = "front"
    let containerNode = SKNode()
    let circleNode = SKShapeNode(circleOfRadius: 500)
    var glow = false
    var radialNodes: [SKSpriteNode] = []
    var currentRadialIndex = 0
    var prevPlatformY = 0
    var finalPlatformCreated = false
    var finalPlatformPos = 0.0
    
    let textureArrayRight = [SKTexture(imageNamed: "jump-right-1"), SKTexture(imageNamed: "jump-right-2"), SKTexture(imageNamed: "jump-right-3")]
    let textureArrayFront = [SKTexture(imageNamed: "jump-front-1"), SKTexture(imageNamed: "jump-front-2"), SKTexture(imageNamed: "jump-front-3")]
    let textureArrayLeft = [SKTexture(imageNamed: "jump-left-1"), SKTexture(imageNamed: "jump-left-2"), SKTexture(imageNamed: "jump-left-3")]
    
    private var monster: SKSpriteNode!
    let random = GKRandomDistribution(lowestValue: 0, highestValue: 6)
    
    enum bitmasks : UInt32{
        case player = 0b1
        case platform = 0b10
        case gameOverLine = 0b100
        case monster = 0b1000
        case particlePlatform = 0b10000
        case casette = 0b100000
        case lamp = 0b1000000
        case monsterOnTop = 0b10000000
    }
    
    var moveLeftAction: SKAction!
    var moveRightAction: SKAction!
    
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.anchorPoint = .zero
        
        defaults.set(4, forKey: "checkpoint")
        
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
        
        bg10.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg10.zPosition = 3
        bg10.setScale(0.4)
        addChild(bg10)
        
        bg11.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg11.zPosition = 3
        bg11.setScale(0.4)
        addChild(bg11)
        
        bg12.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg12.zPosition = 3
        bg12.setScale(0.4)
        addChild(bg12)
        
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
//        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: CGSize(width: player.size.width, height: player.size.height * 2))
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
        
        createDynamicPlatform(lowestValueY: 120, highestValueY: 300)
        for _ in 0...5 {
            makePlatform(name: "", img: "platform-4")
        }
        
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
        
        playMusic(music: "stage4-backsound.mp3", loop: -1, volume: 1)
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
        bg10.position.y = player.position.y + 200
        bg11.position.y = player.position.y + 200
        bg12.position.y = player.position.y + 200
        
        staminaBar.updatePosition(playerPos: player.position.y)
        
        for (index, radialNode) in radialNodes.enumerated() {
            radialNode.position = player.position
        }
        
        //cam bergerak
        let camIncrementPerSecond: CGFloat = 0.5
        gameOverLine.position.y = cam.position.y - 700
        if(firstTouch == true){
            cam.position.y += camIncrementPerSecond
            bg1.position.y = cam.position.y
           
        }
        if cam.position.y - player.position.y < 50{
            cam.position.y = player.position.y + 50
            bg1.position.y = cam.position.y
            
        }
        
        if finalPlatformPos - player.position.y <= 50 {
            doubleJumpIsEnabled = false
        }
        
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
        
        if doubleJumpIsEnabled {
            doubleJumpIsEnabled = false
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1000 ))
            playMusic(music: "double-jump.mp3", loop: 0, volume: 1)
            
            if !finalPlatformCreated {
                for _ in 0...6 {
                    if platformCount < maxPlatformCount - 1 {
                        makePlatform(name:"", img: "platform-4")
                    }
                }
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
                    makePlatform(name: "", img: "platform-2")
                } else if platformCount < maxPlatformCount {
                    if(platformheight < player.position.y){
                        platformheight = player.position.y + 20
//                        randomPlatform = Int.random(in: 1...11)
                        randomPlatform = 5
                        if(randomPlatform < 4){
                            makePlatform(name: "crack", img: "broken-platform-4")
                            makePlatform(name: "", img: "platform-4")
                            makePlatform(name: "crack", img: "broken-platform-4")
                            makePlatform(name: "", img: "platform-4")
                            makePlatform(name: "", img: "platform-4")
                        }else if(randomPlatform == 4){
                            dynamicPlatform(lowestValueY: 1200, highestValueY: 1350)
                            makePlatform(name: "", img: "platform-4")
                            dynamicPlatform(lowestValueY: 1200, highestValueY: 1350)
                            makePlatform(name: "", img: "platform-4")
                            makePlatform(name: "", img: "platform-4")
                        }else if(randomPlatform == 5){
                            createDynamicPlatform(lowestValueY: 970, highestValueY: 1150)
                            makePlatform(name: "", img: "platform-4")
                            createDynamicPlatform(lowestValueY: 970, highestValueY: 1150)
                            makePlatform(name: "", img: "platform-4")
                            makePlatform(name: "", img: "platform-4")
                        }
                        else{
                            for _ in 0...5 {
                                makePlatform(name: "", img: "platform-4")
                            }
                        }
                        addScore()
                    }
                }
                if let platform = contactB.node as? SKSpriteNode, platform.name == "sticky" {
                    player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 600)
                }else{
                    player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 1200)
                    if let platform = contactB.node as? SKSpriteNode, platform.name == "crack"{
                        let changeImageAction = SKAction.setTexture(SKTexture(imageNamed: "broken-platform-4"))
                        let dropAction = SKAction.moveBy(x: 0, y: -50, duration: 0.1)
                       
                        let sequenceAction = SKAction.sequence([changeImageAction, dropAction])
                        platform.run(sequenceAction){
                            contactB.node?.removeFromParent()
                        }
                    }
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
                
                if score % 3 == 0{
                    let randMonster = random.nextInt()
                    playMusic(music: "hands-wall.mp3", loop: 0, volume: 1)
                    if randMonster == 0 {
                        dynamicMonster(imageMonsterName: "tanganKiri1", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 1, scale: 0.4, name: "tangan")
                        dynamicMonster(imageMonsterName: "tanganKanan1", platformLowestXPosition: 0, platformXHighestPosition: 405, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 2, scale: 0.4, name: "tangan")
                        
                    }else if randMonster == 1 {
                        dynamicMonster(imageMonsterName: "tanganKanan1", platformLowestXPosition: 0, platformXHighestPosition: 405, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 2, scale: 0.4, name: "tangan")
                    }else if randMonster == 2 {
                        dynamicMonster(imageMonsterName: "tanganKanan2", platformLowestXPosition: 0, platformXHighestPosition: 405, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 2, scale: 0.4, name: "tangan")
                    }else if randMonster == 3 {
                        dynamicMonster(imageMonsterName: "tanganKiri1", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 1, scale: 0.4, name: "tangan")
                    }else if randMonster == 4 {
                        dynamicMonster(imageMonsterName: "tanganKiri2", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 1000, platformYHighestPosition: 1200, leftOrRight: 1, scale: 0.4, name: "tangan")
                    }else if randMonster == 5 {
                        dynamicMonster(imageMonsterName: "kepalaPasien2", platformLowestXPosition: 0, platformXHighestPosition: 0, platformLowestYPosition: 850, platformYHighestPosition: 1000, leftOrRight: 1, scale: 0.6, name: "kepala")
                    }else if randMonster == 6 {
                        dynamicMonster(imageMonsterName: "kepalaPasien1", platformLowestXPosition: 350, platformXHighestPosition: 350, platformLowestYPosition: 850, platformYHighestPosition: 1000, leftOrRight: 2, scale: 0.6, name: "kepala")
                    }
                }
                if score % 5 == 0 {
                    
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
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.lamp.rawValue{
            playMusic(music: "pickup-item-2.mp3", loop: 0, volume: 1)
            glowArea()
            contactB.node?.removeFromParent()
        }
        
        if (player.physicsBody?.velocity.dy)! < 0 {
            if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.casette.rawValue{
                playMusic(music: "pickup-item-2.mp3", loop: 0, volume: 1)
                contactB.node?.removeFromParent()
                
//                self.view?.presentScene(SurgeryRoom(size: self.size), transition: SKTransition.fade(withDuration: 3))
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
        }
        
    }
    
    
    func makePlatform(name: String, img: String){
        let platform = SKSpriteNode(imageNamed: img)
        platform.name = name
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: prevPlatformY + 150)
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(platformCount == maxPlatformCount ? 1.0 : 0.35)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        prevPlatformY = Int(platform.position.y)
        
        if platformCount == maxPlatformCount {
            finalPlatformCreated = true
            finalPlatformPos = platform.position.y
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
            
            var randomChance = Int(arc4random_uniform(20))
            
            if randomChance == 5 {
                let radio = SKSpriteNode(imageNamed: "radio")
                radio.position = CGPoint(x: CGFloat(GKRandomDistribution(lowestValue: Int(platform.position.x - 50), highestValue: Int(platform.position.x + 50)).nextInt()), y: platform.position.y + platform.size.height - 10)
                radio.zPosition = platform.zPosition + 1
                radio.physicsBody = SKPhysicsBody(rectangleOf: radio.size)
                radio.setScale(0.2)
                radio.physicsBody?.isDynamic = false
                radio.physicsBody?.allowsRotation = false
                radio.physicsBody?.affectedByGravity = false
                radio.physicsBody?.categoryBitMask = bitmasks.lamp.rawValue
                radio.physicsBody?.collisionBitMask = 0
                radio.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
                addChild(radio)
            }
        }
        addChild(platform)
    }
    
    func createDynamicPlatform(lowestValueY: Int, highestValueY: Int) {
        platform = SKSpriteNode(imageNamed: "platform-4")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: 20, highestValue: 350).nextInt(), y: prevPlatformY + 150)
        platform.zPosition = 5
        platform.setScale(0.35)
        platform.physicsBody = SKPhysicsBody(texture: platform.texture!, size: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(platform)

        prevPlatformY = Int(platform.position.y)
        
        let moveDistance: CGFloat = 200
        let moveDuration: TimeInterval = 1.5

        // Move from left to right
        let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)
        // Move from right to left
        let moveLeft = SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration)

        moveLeftAction = SKAction.sequence([moveRight, moveLeft])
        moveRightAction = SKAction.sequence([moveLeft, moveRight])
        let repeatAction = SKAction.repeatForever(moveLeftAction)

        platform.run(repeatAction)
    }
    
    func dynamicPlatform(lowestValueY: Int, highestValueY: Int) {

        platform = SKSpriteNode(imageNamed: "platform-4")
        platform.position = CGPoint(x: Int(frame.minX), y: GKRandomDistribution( lowestValue: lowestValueY, highestValue: highestValueY).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.setScale(0.5)
        platform.physicsBody = SKPhysicsBody(texture: platform.texture!, size: platform.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.platform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(platform)

        var moveDistance: CGFloat = frame.width
        let moveDuration: TimeInterval = 1.5

        // Move from left to right
        let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)
        // Move from right to left
        let moveLeft = SKAction.moveBy(x: -moveDistance , y: 0, duration: moveDuration)

        moveLeftAction = SKAction.sequence([moveRight, moveLeft])
        moveRightAction = SKAction.sequence([moveLeft, moveRight])
        let repeatAction = SKAction.repeatForever(moveLeftAction)

        platform.run(repeatAction)
    }

    
    @objc func fireTimer() {
        if countdown == 0 {
            doubleJumpIsEnabled = true
        } else if countdown > 0 {
            countdown -= 1
        }
    }
   
    func dynamicMonster(imageMonsterName : String, platformLowestXPosition: Int, platformXHighestPosition: Int, platformLowestYPosition: Int, platformYHighestPosition: Int, leftOrRight: Int, scale: Double, name: String){
        monster = SKSpriteNode(imageNamed: imageMonsterName)
        monster.zPosition = 10
        monster.setScale(scale)

        let initialX = leftOrRight == 1 ? platformLowestXPosition : platformXHighestPosition
        let initialY = GKRandomDistribution(lowestValue: platformLowestYPosition, highestValue: platformYHighestPosition).nextInt() + Int(player.position.y)
        monster.position = CGPoint(x: initialX, y: initialY)
        
        monster.physicsBody = SKPhysicsBody(texture: monster.texture!, size: name == "tangan" ? CGSize(width: (monster.size.width/1.5), height: (monster.size.height/1.5)) : CGSize(width: monster.size.width - 50, height: monster.size.height))
        monster.physicsBody?.isDynamic = false
        monster.physicsBody?.allowsRotation = false
        monster.physicsBody?.affectedByGravity = false
        monster.physicsBody?.categoryBitMask = bitmasks.monster.rawValue
        monster.physicsBody?.collisionBitMask = 0
        monster.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(monster)
        
        //1 = left; 2 = right
        if leftOrRight == 1 {
            if name == "tangan"{
                monster.position.x = frame.minX  + 300
            }else if name == "kepala"{
                monster.position.x = frame.minX - monster.size.width / 2 + 100
            }
        } else {
            if name == "tangan"{
                monster.position.x = frame.maxX  - 300
            }else if name == "kepala"{
                monster.position.x = frame.maxX + monster.size.width / 2 - 100
            }
        }
        
        let targetX: CGFloat = leftOrRight == 1 ? frame.midX - monster.size.width  : frame.midX + monster.size.width
        
        // Calculate duration based on distance and desired speed
        let distance = abs(targetX - monster.position.x)
        let speed: CGFloat = 50.0 // Adjust as needed
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
        let delayAction = SKAction.wait(forDuration: 2.0)
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
    }
    
}
