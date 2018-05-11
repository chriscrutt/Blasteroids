//
//  GameScene.swift
//  asteroids
//
//  Created by Christopher Cruttenden on 4/19/18.
//  Copyright © 2018 Cruttenden Corporation. All rights reserved.
//

import SpriteKit
import GameplayKit

// TODID : increase speed, lives, score
// TODO  : explosion animation/state machines/animation, make own graphics, home/pause screen, countdown before start/resume
// TODO  : Add menu for choosing between bigger ship, putting ship in front of finger, or a scroller for ship. different scenes for each?
// OTHER?: different size asteroids, spawn 2+ asteroids at a time but slower spawn

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // long term storage data
    let data = UserDefaults.standard
    
    // Adding Nodes in GameScene.sks
    var blastShip : SKNode?
    var boundary : SKNode?
    var live1 : SKSpriteNode?
    var live2 : SKSpriteNode?
    var live3 : SKSpriteNode?
    var score : SKLabelNode?
    var asteroid = SKSpriteNode(imageNamed: "asteroid.png")
    let EndScene = SKScene(fileNamed: "EndScene")
    
    let yLimit : CGFloat = -200.0   // Limits how far spaceship will go
    var waitDuration : Double = 2   // waitDuration declaration for spawning asteroids
    var i = 0                       // counting how many asteroids have spawned, speeding up spawn rate
    var lives : Int = 3             // Amount of Player lives
    var scoree : Int = 0            // score value (two "e"s because "score" is already node)
    
    // Function to me executed when scene loads
    override func sceneDidLoad() {
        // Allows physics to work...
        physicsWorld.contactDelegate = self
        
        // pairs initiated nodes above with the node in the scene.sks
        // Lives
        live1 = childNode(withName: "live1") as? SKSpriteNode
        live2 = childNode(withName: "live2") as? SKSpriteNode
        live3 = childNode(withName: "live3") as? SKSpriteNode
        
        // Ship
        blastShip = childNode(withName: "blastShip")
        
        // Boundary under screen view that destroys asteroids when hit
        boundary = childNode(withName: "boundary")
        
        // Shows score
        score = childNode(withName: "score") as? SKLabelNode
        
        // Starts the spawn function
        spawn()
    }
    
    // Spawns in asteroids
    func spawn() {
        if waitDuration <= 0.2 { // Cap spawn rate at 0.2 seconds
            
            waitDuration = 0.2
            
        } else {
            
            waitDuration = 2 * pow(0.96, Double(i))
            
        }
        // since asteroid is about to spawn, add 1 to current asteroid count
        i += 1
        
        // print the current wait durration and asteroid count
        print(waitDuration)
        print(i)
        
        // SKActions
        let wait = SKAction.wait(forDuration: waitDuration)             // waits for whatever duration
        let spawn = SKAction.run(spawnAsteroid)                         // runs spawnAsteroid() and spawns asteroid
        let rerun = SKAction.run { self.spawn() }                       // runs this function in an infinite loop
        let spawnSequence = SKAction.sequence([spawn, wait, rerun])     // creates sequence of spawning, waiting, and reruning the func
        run(spawnSequence, withKey: "actionKey")                        // idk but makes it work
        
    }

    // when phone sees someone moved their finger
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // creates var touch that = current properties of finger touching screen at that moment
        for touch in touches {
            
            // creates constant equal to blastShip?
            if let blastShip = blastShip {
                
                // creates location equal to touch location
                let location = touch.location(in: self)
                
                // doesn't allow ship to pass 200px mark
                if location.y > -200 {
                    
                    let move = SKAction.move(to: CGPoint(x: location.x, y: yLimit), duration: 0.05) // slight delay looks good
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



extension GameScene {
    
    // asteroid spawning and details
    func spawnAsteroid() {
        
//        //size
//        var asteroidSize = CGSize(width: 50, height: 50)
//        let randomSize = arc4random() % 3
//
//        switch randomSize {
//
//        case 1:
//            asteroidSize.width *= 1.2
//            asteroidSize.height *= 1.2
//        case 2:
//            asteroidSize.width *= 1.5
//            asteroidSize.height *= 1.5
//        default:
//            break
//
//        }
        
        //init
        let asteroid = SKSpriteNode(imageNamed: "asteroid")             // lets asteroid node be equal to the sprite
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius:
            max(asteroid.size.width / 2, asteroid.size.height / 2))     // creates circular physical colliding body
        asteroid.physicsBody?.usesPreciseCollisionDetection = true      // use Precise Collision Detection
        
        var x = Int(arc4random_uniform(161))                            // creates random var from 0 to 160
        
        if x % 2 == 0 {                                                 // if it is odd make it negative
            
            x *= -1
            
        }
        
        //position
        let randoSpawn = CGPoint(x: x, y: 480)                          // let x position be equal to random var above
        
        asteroid.position = randoSpawn                                  // let asteroid spawn = the CGPoint above
        asteroid.physicsBody?.contactTestBitMask =
            (asteroid.physicsBody?.collisionBitMask)!                   // allows us to be notified of all collisions with asteroid
        
        addChild(asteroid)                                              // spawns the asteroid FINALLY
        
        //rotation
         asteroid.physicsBody?.allowsRotation = true                    // allows rotation (not needed) to help determine later
        
    }
    
    // when a collision begins
    func didBegin(_ contact: SKPhysicsContact) {

        if contact.bodyA.pinned == true {                   // if a bodyA was the boundary (pinned)
            
            asteroid = contact.bodyB.node as! SKSpriteNode  // make asteroid bodyB
            
            points()                                        // Add points
        
            
        } else if contact.bodyB.pinned == true {            // if a bodyA was the boundary (pinned)
        
            asteroid = contact.bodyA.node as! SKSpriteNode  // make asteroid bodyA
            
            points()                                        // add points
            
        } else if contact.bodyA.allowsRotation == true
            && contact.bodyB.allowsRotation == false {      // if asteroid and ship collide (rotation and no rotation)
            
            asteroid = contact.bodyA.node as! SKSpriteNode  // make asteroid bodyA (first body)
            
        } else if contact.bodyB.allowsRotation == true
            && contact.bodyA.allowsRotation == false {      // if ship and asteroid collide (no rotation and rotation)
            
            asteroid = contact.bodyB.node as! SKSpriteNode  // make asteroid bodyB (second body)
            
        }
        
        asteroid.removeFromParent() //replace with explosion later... removes asteroid
        
        // The following could be simplified with a function or etc, and incorperating into above, or visa versa
        
        if (contact.bodyA.pinned == false                       // if asteroid (not pinned and is affected by gravity)
            && contact.bodyA.affectedByGravity == false)        // and if ship (not pinned and not affected by gravity) collided
            || (contact.bodyB.pinned == false
                && contact.bodyB.affectedByGravity == false) {  // or visa versa
            print(lives)                                        // print how many lives
            lives -= 1                                          // take away 1 life
            print(lives)                                        // print lives again
            
            if lives == 2 {                                     // if lives = 2
                
                live1?.colorBlendFactor = 1                     // fade life 1
                
            } else if lives == 1 {                              // if lives = 1
                
                live1?.colorBlendFactor = 1                     // fade life 1
                live2?.colorBlendFactor = 1                     // fade life 2
                
            } else if lives == 0 {                              // if lives = 0
                
                live1?.colorBlendFactor = 1                     // fade life 1
                live2?.colorBlendFactor = 1                     // fade life 2
                live3?.colorBlendFactor = 1                     // fade life 3
                
                die()                                           // die function
                
            }
            
            
        }
    
    }
    
}

// Health and etc
extension GameScene {
    
    // kills player ending game
    func die() {
        
        data.removeObject(forKey: "score")              // removes stored value "score"
        data.set(score?.text, forKey: "score")          // replaces it with new score
        
        if data.integer(forKey: "highScore")            // if that highscore
            < data.integer(forKey: "score") {           // is less than current score
            
            data.removeObject(forKey: "highScore")      // remove stored highscore
            data.set(score?.text, forKey: "highScore")  // replace it with current score
            
        }
        
        let rotate = SKAction.rotate(byAngle: CGFloat.pi*2, duration: 1)    // rotate the ship
//        let repeatt = SKAction.repeat(rotate, count: 2)
//        blastShip?.run(repeatt)
        
        let initialPoint = CGPoint(x: 0, y: -320)                           // sets initial point
        let moveBack = SKAction.move(to: initialPoint, duration: 1)         // moves ship back to init point
        moveBack.timingMode = .linear                                       // makes sure it all good
        let endPoint = CGPoint(x:0, y: -100)                                // new end point
        let moveForward = SKAction.move(to: endPoint, duration: 2)          // moves the ship forward (cant see it really cause scene fade)
        let sequence = SKAction.sequence([rotate, moveBack, moveForward])   // creates sequence of rotating, moving back, and forward
        blastShip?.run(sequence)                                            // runs this sequence
        
        let EndScene = SKScene(fileNamed: "EndScene")                       // creates SKScene var from EndScene to transition
        
        let transition = SKTransition.crossFade(withDuration: 3)            // scene transition is cross fade with duration of 3 secs
        transition.pausesOutgoingScene = false                              // Gamescene doesn't pause until gone
        transition.pausesIncomingScene = false                              // EndScene scene isn't paused when fades in
        scene?.view?.presentScene(EndScene!, transition: transition)        // transitions from GameScene to EndScene with above specifications
        
    }
    
    // Adding points and score keeper
    func points() {
        
        if lives > 0 {                                              // if alive
        
            scoree = Int((score?.text)!)!                           // scoree (represents score as var) = current showing score
        
            let run = SKAction.run {                                // creates constant run which...

                self.scoree += 1                                    // adds 1 to current scoree
                self.score?.text = String(self.scoree)              // sets score labelNode = scoree
            
            }
        
            let wait = SKAction.wait(forDuration: 0.01)             // waits 0.01 seconds
        
            let sequence = SKAction.sequence([run, wait])           // sequence of running above and waiting 0.01 secs
        
            let point = SKAction.repeat(sequence, count: 10)        // repeats sequence 10 times (to add score of 10)
        
            self.run(point)                                         // runs the point repeating sequence
          
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




















