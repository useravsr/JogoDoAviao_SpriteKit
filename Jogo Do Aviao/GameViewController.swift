//
//  GameViewController.swift
//  Jogo Do Aviao
//
//  Created by Arthur Dos Reis on 02/07/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let minhaView:SKView = SKView (frame: self.view.frame)
        self.view = minhaView
        
        let minhaCena:GameScene = GameScene(size: minhaView.frame.size)
        
        minhaView.contentMode = .scaleToFill
        minhaView.presentScene(minhaCena)
        minhaView.ignoresSiblingOrder = false
        minhaView.showsFPS = false
        minhaView.showsNodeCount = false
        minhaView.showsPhysics = false
        
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//                
//                // Present the scene
//                view.presentScene(scene)
//            }
//
//            view.ignoresSiblingOrder = false
//            view.showsFPS = true
//            view.showsNodeCount = true
//            view.showsPhysics = true
//        }
    }

}
