//
//  GameScene.swift
//  DoodleJump
//
//  Created by Maria Berliana on 13/06/23.
//

import Foundation
import SpriteKit
import GameplayKit

class AsylumCafetaria: SKScene, SKPhysicsContactDelegate{
    let rotationDuration: TimeInterval = 0.5 // Duration for the rotation animation
    let rotationAngle: CGFloat = .pi * 2 // Rotation angle in radians (90 degrees)
    let launchDelay: TimeInterval = 1.0 // Delay before launching the knife
    let background = SKSpriteNode(imageNamed: "background")
    let player = SKSpriteNode(imageNamed: "bunny")
    let ground = SKSpriteNode(imageNamed: "ground_grass")
    let monster = SKSpriteNode(imageNamed: "monster")
    var knife = SKSpriteNode(imageNamed: "knife")
    let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let defaults = UserDefaults.standard
    var score = 0
    var bestScore = 0
    let cam = SKCameraNode()
    let motionActivity = Motion()
    var platformheight = CGFloat()
    var playercurrX = CGFloat()
    var randomKnife = 0
    var randomPlatform = 0
    var sticky = 0
    var ctrknife = 0
    enum bitmasks : UInt32{
        case player
        case platform
        case knife
        case gameOverLine
        case monster
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
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
        player.physicsBody?.friction = 100
        player.physicsBody?.angularDamping = 0
        
        player.physicsBody?.categoryBitMask = bitmasks.player.rawValue
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.gameOverLine.rawValue
        addChild(player)
        
        monster.position = CGPoint(x: player.position.x, y: player.position.y - 1000)
        monster.zPosition = 10
        monster.setScale(0.20)
        monster.physicsBody = SKPhysicsBody(circleOfRadius: monster.size.height / 2)
        monster.physicsBody?.isDynamic = false
        monster.physicsBody?.restitution = 0
        monster.physicsBody?.friction = 0
        monster.physicsBody?.angularDamping = 0
        monster.physicsBody?.categoryBitMask = bitmasks.monster.rawValue
        monster.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        addChild(monster)
        
        gameOverLine.position = CGPoint(x: player.position.x, y: cam.position.y - 400)
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
        makePlatform5(name: "", img: "ground_grass_broken")
        makePlatform6(name: "", img: "ground_grass_broken")
        
        
        cam.setScale(1.5)
        cam.position.x = player.position.x
        
        camera = cam
        
    }
    override func update(_ currentTime: TimeInterval) {
        //        cam.position = CGPoint(x: size.width / 2, y: player.position.y + 200)
        gameOverLine.position.y = cam.position.y - 700
        let camIncrementPerSecond: CGFloat = 0.5
        let knifeIncrementPerSecond: CGFloat = 20
        if(firstTouch == true){
            cam.position.y += camIncrementPerSecond
            background.position.y = cam.position.y
            scoreLabel.position.y = cam.position.y + 600
            bestScoreLabel.position.y = cam.position.y + 550
        }
        if(randomKnife != 2 && randomKnife != -1){
            knife.position.y += knifeIncrementPerSecond
        }else if(randomKnife == -1){
            knife.position.y = cam.position.y - 400
        }
        background.setScale(1.5)
        if cam.position.y - player.position.y < 50{
            cam.position.y = player.position.y + 50
            background.position.y = cam.position.y
            scoreLabel.position.y = cam.position.y + 600
            bestScoreLabel.position.y = cam.position.y + 550
        }
        if player.position.y - monster.position.y < 1000 {
            
        }else{
            monster.position.y = player.position.y - 1000
        }
        //        if player.physicsBody!.velocity.dy < 0{
        //
        //        }else{
        //            monster.position.y = player.position.y - 400
        //        }
        monster.position.x = player.position.x
        
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
        
        if contactA.categoryBitMask == bitmasks.platform.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            contactA.node?.removeFromParent()
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue{
            if let sticky = contactB.node?.userData?["sticky"] as? Bool {
                if player.physicsBody!.velocity.dy < 0 {
                    if(ctrknife != 3){
                        ctrknife += 1
                    }else if(ctrknife == -1){
                        
                    }else{
                        randomKnife = Int.random(in: 1...2)
                    }
                    monster.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 400)
                    if let platform = contactB.node as? SKSpriteNode, platform.name == "sticky" {
                        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 600)
                    }else{
                        player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 1200)
                        if let platform = contactB.node as? SKSpriteNode, platform.name == "crack"{
                            let changeImageAction = SKAction.setTexture(SKTexture(imageNamed: "ground_grass_broken"))
                            let dropAction = SKAction.moveBy(x: 0, y: -50, duration: 0.1)
                           
                            let sequenceAction = SKAction.sequence([changeImageAction, dropAction])
                            platform.run(sequenceAction){
                                contactB.node?.removeFromParent()
                            }
                        }
                    }
                    if(platformheight < player.position.y){
                        platformheight = player.position.y + 20
                        randomPlatform = Int.random(in: 1...11)
                        if(randomPlatform < 4){
                            makePlatform5(name: "crack", img: "ground_grass")
                            makePlatform6(name: "", img: "ground_grass_broken")
                        }else if(randomPlatform == 4){
                            makePlatform5(name: "crack", img: "ground_grass")
                            makePlatform6(name: "", img: "ground_grass_broken")
//                            makePlatform5(name: "sticky", img: "ground_grass")
//                            makePlatform6(name: "", img: "ground_grass_broken")
                        }else if(randomPlatform == 5){
                            makePlatform5(name: "crack", img: "ground_grass")
                            makePlatform6(name: "", img: "ground_grass_broken")
//                            makePlatform5(name: "", img: "ground_grass_broken")
//                            makePlatform6(name: "sticky", img: "ground_grass")
                        }
                        else{
                            makePlatform5(name: "", img: "ground_grass_broken")
                            makePlatform6(name: "", img: "ground_grass_broken")
                        }
                        addScore()
                    }
                }
            }
        }
        if(randomKnife == 2){
            playercurrX = player.position.x
            knife.removeFromParent()
            makeKnife()
            randomKnife = -1
            ctrknife = -1
        }
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.gameOverLine.rawValue{
            gameOver()
        }
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.monster.rawValue{
            gameOver()
        }
//        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.knife.rawValue{
//            gameOver()
//        }
    }
    
    //    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //        for touch in touches{
    //            let location = touch.location(in: self)
    //
    //            player.position.x = location.x
    //
    //        }
    //    }
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        player.physicsBody?.isDynamic = true
        if firstTouch == false{
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 1100 ))
        }
        firstTouch = true
        motionActivity.startAccelorometerUpdate()
        
    }
    func makeKnife(){
        knife = SKSpriteNode(imageNamed: "knife")
        knife.position = CGPoint(x: playercurrX, y: cam.position.y - 500)
        knife.zPosition = 10
        knife.setScale(0.20)
        knife.physicsBody = SKPhysicsBody(circleOfRadius: knife.size.height / 2)
        knife.physicsBody?.isDynamic = false
        knife.physicsBody?.restitution = 0
        knife.physicsBody?.friction = 0
        knife.physicsBody?.angularDamping = 0
        
        knife.physicsBody?.categoryBitMask = bitmasks.knife.rawValue
        knife.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(knife)
        // Apply rotation animation
            let rotateAction = SKAction.rotate(byAngle: rotationAngle, duration: rotationDuration)
            // Apply delay before launching the knife
            let delayAction = SKAction.wait(forDuration: launchDelay)
            // Combine rotation and delay actions
            let sequenceAction = SKAction.sequence([rotateAction, delayAction])
            // Run the sequence of actions on the knife node
            knife.run(sequenceAction) {
                self.randomKnife = 0
                self.ctrknife = 0
                // This closure is called after the rotation and delay actions have completed
                // Add code here to launch the knife or perform any other desired actions
            }
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
        platform.userData = ["sticky": sticky]
        
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
        platform.userData = ["sticky": sticky]
        
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
        platform.userData = ["sticky": sticky]
        
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
        platform.userData = ["sticky": sticky]
        
        addChild(platform)
    }
    func makePlatform5(name: String, img: String){
        let platform = SKSpriteNode(imageNamed: img)
        platform.name = name
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
        platform.userData = ["sticky": sticky]
        
        addChild(platform)
    }
    func makePlatform6(name: String, img: String){
        let platform = SKSpriteNode(imageNamed: img)
        platform.name = name
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
        platform.userData = ["sticky": sticky]
        
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
