//
//  GameViewController.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/3/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file as String, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, MCBrowserViewControllerDelegate {
    
    var appDelegate: AppDelegate!
    var scene: GameScene!;
    var host: Bool = true;
    var connectedStreams: [NSOutputStream] = [];
    var timerCount = 0;
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?, host: Bool) {
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        self.host = host;
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
        
        /*
        let timerGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "handleLongPress:");
        timerGestureRecognizer.minimumPressDuration = 0.01;
        timerGestureRecognizer.allowableMovement = 10;
        timerGestureRecognizer.delaysTouchesBegan = false;
        timerGestureRecognizer.cancelsTouchesInView = false;
        timerGestureRecognizer.delaysTouchesEnded = false;
        */
        
        if let spriteScene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            self.scene = spriteScene;
            // Configure the view.
            let skView = self.view as! SKView
            //skView.addGestureRecognizer(timerGestureRecognizer);
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            println("Game Scene VC Width: \(skView.bounds.size.width)");
            println("Game Scene VC Height: \(skView.bounds.size.height)");
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .Fill;
            
            self.scene.vc = self;
            self.scene.mpcHandler = appDelegate.mpcHandler;
            if host {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MPC_DidChangeStateNotification", object: nil);
                scene.addPlayer(appDelegate.mpcHandler.peerID);
                
            }
            
            skView.presentScene(self.scene)
            
            println("Game Scene Width: \(scene.size.width)");
            println("Game Scene Height: \(scene.size.height)");
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //appDelegate.mpcHandler.advertiseSelf(false);
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        super.viewWillAppear(animated);
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        super.viewWillDisappear(animated);
    }
    
    @IBAction func invitePlayer(sender: UIButton) {
        if appDelegate.mpcHandler.session != nil {
            appDelegate.mpcHandler.setupBrowser();
            appDelegate.mpcHandler.browser.delegate = self;
            
            self.presentViewController(appDelegate.mpcHandler.browser, animated: true, completion: nil);
        }
    }
    
    func goToHandScene(size: CGSize, hand: Hand, gameScene: GameScene) {
        let vc = HandViewController(size: size, hand: hand, gameScene: gameScene);
        
        navigationController?.pushViewController(vc, animated: false);
    }
    
    func goToDeckScene(size: CGSize, deck: Deck, gameScene: GameScene) {
        let vc = HandViewController(size: size, deck: deck, gameScene: gameScene);
        
        navigationController?.pushViewController(vc, animated: false);
    }
    
    func sendData(data: NSData) {
        var error: NSError?;
        
        appDelegate.mpcHandler.session.sendData(data, toPeers: appDelegate.mpcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error);
        
        if error != nil {
            println("error: \(error?.localizedDescription)");
        }
    }
    
    func sendPositionData(data: NSData) {
        var error: NSError?;
        
        for stream in connectedStreams {
            
            stream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        }
    }
    
    func peerChangedStateWithNotification(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!);
        
        let state = userInfo.objectForKey("state") as! Int;
        let peerID = userInfo.objectForKey("peerID") as! MCPeerID;
        
        println("User State Changed");
        if host {
        if state == MCSessionState.Connecting.rawValue {
            dispatch_async(dispatch_get_main_queue()) {
                self.scene.addPlayer(peerID);
                println("Player Added");
            }
        }
        else if state == MCSessionState.Connected.rawValue {
            //Do when someone connected
            
            if let data = self.scene.getBoardStateAsNSData() {
                
                var error: NSError?;
                
                var peerToSend: [AnyObject]! = [peerID];
                
                appDelegate.mpcHandler.session.sendData(data, toPeers: peerToSend, withMode: MCSessionSendDataMode.Reliable, error: &error);
                
                if error != nil {
                    println("error: \(error?.localizedDescription)");
                }
            }
        }
        else if state == MCSessionState.NotConnected.rawValue {
            scene.removePlayer(peerID);
        }
        }
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mpcHandler.browser.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        println("handleLongPress Called");
        ++timerCount;
        if timerCount % 5 == 0 {
            //scene.pauseTimer();
        }
    }
    
    /*
    func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasBytesAvailable:
            var data = NSMutableData(length: 512);
            var buf = [UInt8](count: 512, repeatedValue: 0);
            var len: Int = 0;
            len = (aStream as! NSInputStream).read(&buf, maxLength: 512);
            if len != 0 {
                data?.appendBytes(UnsafePointer<Void>(buf), length: len);
            }
            if let jsonMoveData = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
                if jsonMoveData["cardType"] as! NSString == "Deck" {
                if let moveData = JSONMove.parseJSONData(jsonMovementData: jsonMoveData["moveData"]) as? JSONDeckMove {
                    println(moveData.toJsonString());
                }
                }
            }
            break;
        default:
            break;
        }
    }
    */
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
