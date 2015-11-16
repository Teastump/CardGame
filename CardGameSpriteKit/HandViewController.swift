//
//  HandViewController.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/12/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveHandFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! HandScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class HandViewController: UIViewController {

    var size: CGSize!;
    var hand: Hand!;
    var deck: Deck?;
    var gameScene: GameScene!;
    private var scene: HandScene!;
    
    init(size: CGSize, hand: Hand, gameScene: GameScene) {
        
        self.size = size;
        self.hand = hand;
        self.deck = nil;
        self.gameScene = gameScene;
        
        super.init(nibName: "HandViewController", bundle: nil);
        
        self.scene = HandScene(size: self.size, viewController: self);
    }
    
    init(size: CGSize, deck: Deck, gameScene: GameScene) {
        self.size = size;
        self.hand = Hand(cards: deck.cards);
        self.deck = deck;
        self.gameScene = gameScene;
        
        super.init(nibName: "HandViewController", bundle: nil);
        
        self.scene = DeckScene(size: self.size, viewController: self);
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        if deck == nil {
            (navigationController as! RotationController).autorotate = true;
            (navigationController as! RotationController).supportedOrientations = Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue);
            UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications();
            NSNotificationCenter.defaultCenter().addObserver(scene, selector: Selector("orientationChanged:"), name: UIDeviceOrientationDidChangeNotification, object: UIDevice.currentDevice());
        }
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .Fill
        
        skView.presentScene(scene)
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if motion == .MotionShake {
            println("Device Shaken");
            if deck != nil {
                gameScene.shuffleDeck();
                (scene as! DeckScene).shuffleDeck();
            }
            
        }
    }
    
    func backToBoard() {
        gameScene.selectedNode = nil;
        hand = nil;
        gameScene = nil;
        (navigationController as! RotationController).autorotate = true;
        (navigationController as! RotationController).supportedOrientations = Int(UIInterfaceOrientationMask.Portrait.rawValue);
        NSNotificationCenter.defaultCenter().removeObserver(scene, name: UIDeviceOrientationDidChangeNotification, object: nil);
        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation");
        
        navigationController?.popViewControllerAnimated(false);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
