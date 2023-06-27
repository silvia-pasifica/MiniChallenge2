//
//  SurgeryRoom.swift
//  DoodleJump
//
//  Created by Silvia Pasica on 22/06/23.
//

import GameplayKit
import SpriteKit

class SurgeryRoom: SKScene, SKPhysicsContactDelegate{
    private var background = SKSpriteNode(imageNamed: "background")
    private var player = SKSpriteNode(imageNamed: "iris belakang")
    private var ground = SKSpriteNode(imageNamed: "ground_grass")
    private var monster: SKSpriteNode!
    private var monsterTop: SKSpriteNode!
    private var platform : SKSpriteNode!
    private var knife: SKSpriteNode!
    private let gameOverLine = SKSpriteNode(color: .red, size: CGSize(width: 1000, height: 10))
    
    var firstTouch = false
    let scoreLabel = SKLabelNode()
    let bestScoreLabel = SKLabelNode()
    let objectsContainer = SKNode()
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
        case weapon = 0b10000
        case fragilePlatform = 0b100000
        case stickyPlatform
        case monsterOnTop
    }
    
    enum PlatformDirection {
        case leftToRight
        case rightToLeft
    }
    
    var moveLeftAction: SKAction!
    var moveRightAction: SKAction!
    var moveDownAction: SKAction!
    
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
        player.physicsBody?.contactTestBitMask = bitmasks.platform.rawValue | bitmasks.gameOverLine.rawValue | bitmasks.monster.rawValue | bitmasks.weapon.rawValue
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
        
        monsterOnTop()
        
        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 120, highestValueY: 300)
        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 350, highestValueY: 500)
        dynamicPlatform(lowestValueX: 20, highestValueX: 450, lowestValueY: 550, highestValueY: 700)
        makePlatform(lowestValueX: 10, highestValueX: 350, lowestValueY: 750, highestValueY: 950)
        makePlatform(lowestValueX: 5, highestValueX: 450, lowestValueY: 990, highestValueY: 1150)
        createPlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1200, highestValueY: 1350)
        
        startMovingPlatform()
        
        cam.setScale(1.5)
        cam.position.x = player.position.x
        camera = cam
        addChild(cam)
        objectsContainer.position.x = player.position.x
        addChild(objectsContainer)

    }
    
    override func didSimulatePhysics() {
        objectsContainer.position = CGPoint(x: -cam.position.x, y: -cam.position.y)
    }
    
    override func update(_ currentTime: TimeInterval){
        cam.position.y = player.position.y + 200
        background.position.y = player.position.y +  200
        background.setScale(1.5)
        
        if player.physicsBody!.velocity.dy > 0 {
            gameOverLine.position.y = player.position.y - 600
        }
        monsterTop.position.y = player.position.y + 800
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
        
        if (contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.platform.rawValue) || (contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.stickyPlatform.rawValue)  {
            if player.physicsBody!.velocity.dy < 0 {
                if contactB.categoryBitMask == bitmasks.platform.rawValue{
                    player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 1800)
                } else {
                    player.physicsBody?.velocity = CGVector(dx: player.physicsBody!.velocity.dx, dy: 800)
                }
               
                if(platformHeight < player.position.y && score != 100){
                    platformHeight = player.position.y + 20
                    if score <= 20 {
                        createPlatforms()
                    } else if score > 20 && score <= 50 {
                        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 1120, highestValueY: 1300)
                        createPlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1350, highestValueY: 1500)
                        dynamicPlatform(lowestValueX: 5, highestValueX: 450, lowestValueY: 1550, highestValueY: 1700)
                        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1800, highestValueY: 1950)
                    }else if score > 50 && score <= 70 { //tambahin yang lengket
                        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 1120, highestValueY: 1300)
                        createPlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1350, highestValueY: 1500)
                        dynamicPlatform(lowestValueX: 5, highestValueX: 450, lowestValueY: 1550, highestValueY: 1700)
                        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1800, highestValueY: 1950)
                    }else if score > 70 && score <= 99{
                        makeStickyPlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 1120, highestValueY: 1300)
                        createPlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1350, highestValueY: 1500)
                        dynamicPlatform(lowestValueX: 5, highestValueX: 450, lowestValueY: 1550, highestValueY: 1700)
                        makeStickyPlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1800, highestValueY: 1950)
                    }
                    
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
                if score % 2 == 0 {
                    monsterOnTop()
                    
                    print("berjalan")
                    
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
        
        if contactA.categoryBitMask == bitmasks.player.rawValue && contactB.categoryBitMask == bitmasks.weapon.rawValue{
            gameOver()
        }
        
        if contactA.categoryBitMask == bitmasks.weapon.rawValue && contactB.categoryBitMask == bitmasks.fragilePlatform.rawValue{
            contactB.node?.removeFromParent()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if platform.action(forKey: "movingPlatform") == nil {
            startMovingPlatform()
        } else {
            stopMovingPlatform()
        }
    }
    
    func createPlatforms(){
        makePlatform(lowestValueX: 5, highestValueX: 350, lowestValueY: 1120, highestValueY: 1300)
        makePlatform(lowestValueX: 20, highestValueX: 350, lowestValueY: 1350, highestValueY: 1500)
        dynamicPlatform(lowestValueX: 5, highestValueX: 450, lowestValueY: 1550, highestValueY: 1700)
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
    //geraknya gak full dari kiri ke kanan atau sebaliknya
    func createPlatform(lowestValueX: Int, highestValueX: Int, lowestValueY: Int, highestValueY: Int) {
        platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: lowestValueX, highestValue: highestValueX).nextInt(), y: GKRandomDistribution( lowestValue: lowestValueY, highestValue: highestValueX).nextInt() + Int(player.position.y) )
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
        
        let moveDistance: CGFloat = 200
        let moveDuration: TimeInterval = 2.0
        
        // Move from left to right
        let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)
        // Move from right to left
        let moveLeft = SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration)
        
        moveLeftAction = SKAction.sequence([moveRight, moveLeft])
        moveRightAction = SKAction.sequence([moveLeft, moveRight])
    }
    
    func startMovingPlatform() {
        let repeatAction = SKAction.repeatForever(moveLeftAction)
        platform.run(repeatAction)
    }
    
    func stopMovingPlatform() {
        platform.removeAllActions()
    }
    
    //full
    func dynamicPlatform(lowestValueX: Int, highestValueX: Int, lowestValueY: Int, highestValueY: Int) {
       
        platform = SKSpriteNode(imageNamed: "platform")
        platform.position = CGPoint(x: Int(frame.minX), y: GKRandomDistribution( lowestValue: lowestValueY, highestValue: highestValueX).nextInt() + Int(player.position.y) )
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
        let moveDuration: TimeInterval = 2.0
        
        // Move from left to right
        let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)
        // Move from right to left
        let moveLeft = SKAction.moveBy(x: -moveDistance , y: 0, duration: moveDuration)
        
        moveLeftAction = SKAction.sequence([moveRight, moveLeft])
        moveRightAction = SKAction.sequence([moveLeft, moveRight])
        let repeatAction = SKAction.repeatForever(moveLeftAction)
        
        platform.run(repeatAction)
    }
    
    func makeStickyPlatform(lowestValueX: Int, highestValueX: Int, lowestValueY: Int, highestValueY: Int){
        platform = SKSpriteNode(imageNamed: "platform") //ganti yang sticky
        platform.position = CGPoint(x: GKRandomDistribution(lowestValue: lowestValueX, highestValue: highestValueX).nextInt(), y: GKRandomDistribution( lowestValue: lowestValueY, highestValue: highestValueX).nextInt() + Int(player.position.y) )
        platform.zPosition = 5
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
        platform.setScale(0.5)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.categoryBitMask = bitmasks.stickyPlatform.rawValue
        platform.physicsBody?.collisionBitMask = 0
        platform.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        
        addChild(platform)
    }
    
    
    
    func createWeapon(){
        knife = SKSpriteNode(imageNamed: "knife")
//
        knife.zPosition = 10
        knife.setScale(0.2)
        knife.physicsBody = SKPhysicsBody(texture: knife.texture!, size: knife.size)
        knife.physicsBody?.isDynamic = false
        knife.physicsBody?.allowsRotation = false
        knife.physicsBody?.affectedByGravity = false
        knife.physicsBody?.categoryBitMask = bitmasks.weapon.rawValue
        knife.physicsBody?.collisionBitMask = 0
        knife.physicsBody?.contactTestBitMask = bitmasks.player.rawValue | bitmasks.fragilePlatform.rawValue
        addChild(knife)
        
        let randomX = CGFloat.random(in: (knife.size.width / 2)...(frame.width - knife.size.width / 2))
        knife.position = CGPoint(x: randomX, y: frame.maxY + player.position.y + 50)
        
        // Animate the platform
        let moveAction = SKAction.move(by: CGVector(dx: 0, dy: -frame.height), duration: 5.0)
        let removeAction = SKAction.removeFromParent()
        knife.run(SKAction.sequence([moveAction, removeAction]))
        
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
        let speed: CGFloat = 450.0 // Adjust as needed
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
    
    func monsterOnTop (){
        monsterTop = SKSpriteNode(imageNamed: "Cute-Monster")
        monsterTop.zPosition = 11
        let cameraPositionInScene = self.convert(cam.position, from: self)
        monsterTop.setScale(0.5)
        monsterTop.position = CGPoint(x: frame.midX + 200, y: player.position.y + 1800)
        
        monsterTop.physicsBody = SKPhysicsBody(texture: monsterTop.texture!, size: monsterTop.size)
        monsterTop.physicsBody?.isDynamic = false
        monsterTop.physicsBody?.allowsRotation = false
        monsterTop.physicsBody?.affectedByGravity = false
        monsterTop.physicsBody?.categoryBitMask = bitmasks.monsterOnTop.rawValue
        monsterTop.physicsBody?.collisionBitMask = 0
        monsterTop.physicsBody?.contactTestBitMask = bitmasks.player.rawValue
        objectsContainer.addChild(monsterTop) 
        
        let targetY: CGFloat = player.position.y  + 1800
        let resetX: CGFloat = frame.midX + 200
        let resetY: CGFloat = player.position.y + 1800
        // Calculate duration based on distance and desired speed
        let distance = abs(targetY - 4 * monsterTop.position.y)
        let speed: CGFloat = 3500.0 // Adjust as needed
        let duration = distance / speed
       
        // Move platform
        let moveAction = SKAction.move(to: CGPoint(x: frame.midX + 200, y: targetY), duration: TimeInterval(duration))
        let resetPositionAction = SKAction.run { [weak self] in
            self?.monsterTop.position = CGPoint(x:resetX , y: resetY)
        }
        let delayAction = SKAction.wait(forDuration: 0.3)
        let sequenceAction = SKAction.sequence([moveAction, delayAction, resetPositionAction])
        let repeatAction = SKAction.repeatForever(sequenceAction)
        monsterTop.run(repeatAction)
//        run(SKAction.repeatForever(SKAction.sequence([
//                    SKAction.run(createWeapon),
//                    SKAction.wait(forDuration: 1.0)
//                ])))
       
        stopAndRemoveMonsterTop()
    }
    func stopAndRemoveMonsterTop() {
        
        let removeAction = SKAction.removeFromParent()
        let delayAction = SKAction.wait(forDuration: 3.0) // Penundaan selama 0.5 detik
        let sequenceAction = SKAction.sequence([delayAction, removeAction])
        monsterTop.run(sequenceAction) // Menjalankan aksi dengan penundaan
//        monsterTop.removeAllActions() // Menghentikan aksi berulang
        
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
