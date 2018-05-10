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

class EndScene: SKScene {
    
    let data = UserDefaults.standard
    
    var score : SKLabelNode?
    
    var highScore : SKLabelNode?
    
    var fadeAway : SKSpriteNode?
    
    override func sceneDidLoad() {
        
        let sscore = data.string(forKey: "score")
        
        let hhighScore = data.string(forKey: "highScore")
        
        score = childNode(withName: "score") as? SKLabelNode
        
        highScore = childNode(withName: "highScore") as? SKLabelNode
        
        score?.text = sscore
        
        highScore?.text = hhighScore
        
        fadeAway = childNode(withName: "fadeAway") as? SKSpriteNode
        
        let fade = SKAction.fadeOut(withDuration: 1)
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([wait, fade])
        fadeAway?.run(sequence)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            
            let GameScene = SKScene(fileNamed: "GameScene")
            
            let transition = SKTransition.crossFade(withDuration: 1)
            transition.pausesOutgoingScene = false
            transition.pausesIncomingScene = false
            scene?.view?.presentScene(GameScene!, transition: transition)

    }

}












