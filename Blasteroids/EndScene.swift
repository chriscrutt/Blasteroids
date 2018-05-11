//
//  PauseScene.swift
//  asteroids
//
//  Created by Christopher Cruttenden on 4/23/18.
//  Copyright © 2018 Cruttenden Corporation. All rights reserved.
//

//import Foundation

import SpriteKit
import GameplayKit

// end/death/restart scene
class EndScene: SKScene {
    
    // long term storage data
    let data = UserDefaults.standard
    
    // adding nodes in EndScene.sks
    var score : SKLabelNode?
    var highScore : SKLabelNode?
    var fadeAway : SKSpriteNode?
    
    // Function to me executed when scene loads
    override func sceneDidLoad() {
        
        // Storage
        let scoree = data.string(forKey: "score")                       // sets scoree = stored score
        let highScoree = data.string(forKey: "highScore")               // sets highscoree = stored highscore
        
        // Nodes
        score = childNode(withName: "score") as? SKLabelNode
        highScore = childNode(withName: "highScore") as? SKLabelNode
        fadeAway = childNode(withName: "fadeAway") as? SKSpriteNode
        
        score?.text = scoree                                            // sets score text of this scene to scoree
        
        highScore?.text = highScoree                                    // sets highScore text of this scene to highScoree
        
        let fade = SKAction.fadeOut(withDuration: 1)                    // fades something out for 1 sec
        let wait = SKAction.wait(forDuration: 3)                        // waits for 3 secs
        let sequence = SKAction.sequence([wait, fade])                  // sequence of waiting and fading
        fadeAway?.run(sequence)                                         // runs sequence and fades blastLogo animation
    }
    
    // When a touch ends
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            let GameScene = SKScene(fileNamed: "GameScene")                 // sets GameScene = to the scene GameScene
            
            let transition = SKTransition.crossFade(withDuration: 1)        // creates a cross fade transition of 1 sec
            transition.pausesOutgoingScene = true                           // pauses fading scene
            transition.pausesIncomingScene = true                           // pauses incoming scene
            scene?.view?.presentScene(GameScene!, transition: transition)   // does transition from EndScene to GameScene with cross fade

    }

}












