//
//  HandViewController.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/12/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class HandViewControllerCopy: UIViewController {
    
    let size: CGSize!;
    let hand: Hand!;
    let gameScene: GameScene!;
    
    init(size: CGSize, hand: Hand, gameScene: GameScene) {
        
        self.size = size;
        self.hand = hand;
        self.gameScene = gameScene;
        
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        println("View Controller Loaded");
        
        //let scene = HandScene(size: size, viewController: self);
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        //scene.scaleMode = .AspectFill
        
        //skView.presentScene(scene)
    }
    
    func backToBoard() {
        navigationController?.popViewControllerAnimated(false);
    }
}