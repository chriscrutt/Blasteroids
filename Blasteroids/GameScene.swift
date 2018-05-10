//
//  GameScene.swift
//  asteroids
//
//  Created by Christopher Cruttenden on 4/19/18.
//  Copyright © 2018 Cruttenden Corporation. All rights reserved.
//

import SpriteKit
import GameplayKit

// TODID: increase speed, lives, score
// TODO: explosion animation/state machines/animation, make own graphics, home/pause screen, countdown before start/resume
// OTHER?: different size asteroids, spawn 2+ asteroids at a time but slower spawn

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let data = UserDefaults.standard
    
    var blastShip : SKNode?
    var boundary : SKNode?
    var live1 : SKSpriteNode?
    var live2 : SKSpriteNode?
    var live3 : SKSpriteNode?
    var score : SKLabelNode?
    var asteroid = SKSpriteNode(imageNamed: "asteroid.png")
    var previousTimeInterval : TimeInterval = 0
    let yLimit : CGFloat = -200.0
    var waitDuration : Double = 3
    var i = 0
    var lives : Int = 3
    var scoree : Int = 0
    var sscore : Int = 0
    let EndScene = SKScene(fileNamed: "EndScene")
    
    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self
        
        live1 = childNode(withName: "live1") as? SKSpriteNode
        live2 = childNode(withName: "live2") as? SKSpriteNode
        live3 = childNode(withName: "live3") as? SKSpriteNode
        blastShip = childNode(withName: "blastShip")
        boundary = childNode(withName: "boundary")
        score = childNode(withName: "score") as? SKLabelNode
        
        spawn()
    }
    
    func spawn() {
        if waitDuration <= 0.2 {
            
            waitDuration = 0.2
            
        } else {
            
            waitDuration = 2 * pow(0.96, Double(i))
            
        }
        
        i += 1
        
        print(waitDuration)
        print(i)
        
        let wait = SKAction.wait(forDuration: waitDuration)
        let spawn = SKAction.run(spawnAsteroid)
        let rerun = SKAction.run { self.spawn() }
        let spawnSequence = SKAction.sequence([spawn, wait, rerun])
        run(spawnSequence, withKey: "actionKey")
        
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            if let blastShip = blastShip {
                
                let location = touch.location(in: self)
                
                if location.y > -200 {
                    
                    let move = SKAction.move(to: CGPoint(x: location.x, y: yLimit), duration: 0.05)
                    blastShip.run(move)
                    
                } else {
                
                    let move = SKAction.move(to: location, duration: 0.05)
                    blastShip.run(move)
                    
                }
                
            }

        }
        
    }
    
    // Touch Ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Move ship back to start location
        
        let initialPoint = CGPoint(x: 0, y: -320)
        let moveBack = SKAction.move(to: initialPoint, duration: 0.25)
        moveBack.timingMode = .linear
        blastShip?.run(moveBack)
        
    }
    
}



// Asteroids
extension GameScene {
    
    func spawnAsteroid() {
        
        //size
        var asteroidSize = CGSize(width: 50, height: 50)
        let randomSize = arc4random() % 3
        
        switch randomSize {
            
        case 1:
            asteroidSize.width *= 1.2
            asteroidSize.height *= 1.2
        case 2:
            asteroidSize.width *= 1.5
            asteroidSize.height *= 1.5
        default:
            break
            
        }
        
        //init
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: max(asteroid.size.width / 2, asteroid.size.height / 2))
        asteroid.physicsBody?.usesPreciseCollisionDetection = true
        
        var x = Int(arc4random_uniform(161))
        
        if x % 2 == 0 {
            
            x *= -1
            
        }
        
        //position
        let randoSpawn = CGPoint(x: x, y: 480)
        
        asteroid.position = randoSpawn
        asteroid.physicsBody?.contactTestBitMask = (asteroid.physicsBody?.collisionBitMask)!
        
        addChild(asteroid)
        
        //rotation
         asteroid.physicsBody?.allowsRotation = true
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

        if contact.bodyA.pinned == true {
            
            asteroid = contact.bodyB.node as! SKSpriteNode
            
            points()
        
        } else if contact.bodyB.pinned == true {
        
            asteroid = contact.bodyA.node as! SKSpriteNode
            
            points()
            
        } else if contact.bodyA.allowsRotation == true && contact.bodyB.allowsRotation == false {
            
            asteroid = contact.bodyA.node as! SKSpriteNode
            
        } else if contact.bodyB.allowsRotation == true && contact.bodyA.allowsRotation == false {
            
            asteroid = contact.bodyB.node as! SKSpriteNode
            
        }
        
        asteroid.removeFromParent() //replace with explosion later
        
        if (contact.bodyA.pinned == false && contact.bodyA.affectedByGravity == false) ||
            (contact.bodyB.pinned == false && contact.bodyB.affectedByGravity == false) {
            print(lives)
            lives -= 1
            print(lives)
            
            if lives == 2 {
                live1?.colorBlendFactor = 1
            } else if lives == 1 {
                live1?.colorBlendFactor = 1
                live2?.colorBlendFactor = 1
            } else if lives == 0 {
                live1?.colorBlendFactor = 1
                live2?.colorBlendFactor = 1
                live3?.colorBlendFactor = 1
                
                die()
                
            }
            
            
        }
    
    }
    
}

// Health and etc
extension GameScene {
    
    func die() {
        
        data.removeObject(forKey: "score")
        data.set(score?.text, forKey: "score")
        
        if data.integer(forKey: "highScore") < data.integer(forKey: "score") {
            
            data.removeObject(forKey: "highScore")
            data.set(score?.text, forKey: "highScore")
            
        }
        
        let rotate = SKAction.rotate(byAngle: CGFloat.pi*2, duration: 1)
//        let repeatt = SKAction.repeat(rotate, count: 2)
//        blastShip?.run(repeatt)
        
        let initialPoint = CGPoint(x: 0, y: -320)
        let moveBack = SKAction.move(to: initialPoint, duration: 1)
        moveBack.timingMode = .linear
        let endPoint = CGPoint(x:0, y: -100)
        let moveForward = SKAction.move(to: endPoint, duration: 2)
        let sequence = SKAction.sequence([rotate, moveBack, moveForward])
        blastShip?.run(sequence)
        
        let EndScene = SKScene(fileNamed: "EndScene")
        
        let transition = SKTransition.crossFade(withDuration: 3)
        transition.pausesOutgoingScene = false
        transition.pausesIncomingScene = false
        scene?.view?.presentScene(EndScene!, transition: transition)
        
    }
    
    
    func points() {
        
        if lives > 0 {
        
            scoree = Int((score?.text)!)!
        
            let run = SKAction.run {

                self.scoree += 1
                self.score?.text = String(self.scoree)
            
            }
        
            let wait = SKAction.wait(forDuration: 0.01)
        
            let sequence = SKAction.sequence([run, wait])
        
            let point = SKAction.repeat(sequence, count: 10)
        
            self.run(point)
          
//            let addSequence = SKAction.sequence([run, SKAction.wait(forDuration: 1)])
//            
//            let addPoint = SKAction.repeatForever(addSequence)
//            
//            self.run(addPoint)
        
        } /*else {
            
            data.removeObject(forKey: "score")
            data.set(score?.text, forKey: "score")
            
        }*/
        
    }
    
}




















