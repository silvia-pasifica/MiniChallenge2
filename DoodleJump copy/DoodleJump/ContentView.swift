//
//  ContentView.swift
//  DoodleJump
//
//  Created by Maria Berliana on 13/06/23.
//

import SwiftUI
import SpriteKit

class StartScene: SKScene{
    override func didMove(to view: SKView) {
        self.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scene?.scaleMode = .aspectFill
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let lokation = touch.location(in: self)
            let startNode = atPoint(lokation)
            
            if startNode.name == "startButton"
            {
                let game = GameScene(size: self.size)
//                let game = Stage_3(size: self.size)
                let transition = SKTransition.doorway(withDuration: 3)
                self.view?.presentScene(game, transition: transition)
            }
        }
    }
    
}

struct ContentView: View {
     let startScene = StartScene(fileNamed: "StartScene")!
    
    var body: some View {
        VStack {
            
            SpriteView(scene: startScene).ignoresSafeArea()
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
       
    }
}
