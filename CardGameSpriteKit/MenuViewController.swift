//
//  MenuViewController.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/13/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import UIKit
import MultipeerConnectivity

var myID: Int = 0;

class MenuViewController: UIViewController, MCNearbyServiceAdvertiserDelegate {
    
    var appDelegate: AppDelegate!;
    var game: GameViewController!;
    var goToBoardButton: UIButton!;
    var disconnectButton: UIButton!;
    var connected = false;
    
    @IBOutlet weak var toBoardButton: UIButton!
    @IBOutlet weak var dcButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        println("Width: \(self.view.bounds.size.width)");
        println("Height: \(self.view.bounds.size.height)");
        
        println("Device Width: \(screenWidth)");
        println("Device Height: \(screenHeight)");
        
        goToBoardButton = toBoardButton;
        disconnectButton = dcButton;

        // Do any additional setup after loading the view.
        
        (navigationController as! RotationController).supportedOrientations = Int(UIInterfaceOrientationMask.Portrait.rawValue);
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        appDelegate.mpcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name);
        appDelegate.mpcHandler.setupSession();
        appDelegate.mpcHandler.advertiseSelf(true);
        appDelegate.mpcHandler.nearbyAdvertiser!.delegate = self;
        
        game = GameViewController(nibName: "GameViewController", bundle: nil, host: true);
        
        appDelegate.mpcHandler.game = game;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleRecievedDataWithNotification:", name: "MPC_DidRecieveDataNotification", object: nil);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startGame(object: AnyObject) {
        
        if !connected {
            game.scene.startNewGame();
        }
        navigationController?.pushViewController(game, animated: true);
    }
    
    @IBAction func toSettings(sender: AnyObject) {
        
        //let vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil);
        //navigationController?.pushViewController(vc, animated: true)
    }
    
    func handleRecievedDataWithNotification(notification: NSNotification) {
        let userInfo = NSDictionary(dictionary: notification.userInfo!);
        let recievedData = userInfo.objectForKey("data") as! NSData;
        
        var error: NSError?
        
        let data = NSJSONSerialization.JSONObjectWithData(recievedData, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary;
        
        if error != nil {
            println("error: \(error?.localizedDescription)");
        }
        
        let type = data.objectForKey("type") as! Int;
        
        dispatch_async(recievedNetworkDispatch) {
            self.game.scene.dataWasRecieved();
            switch type {
            case SentDataType.BoardState.rawValue:
                myID = data.objectForKey("yourID") as! Int;
                if self.game.scene.setBoardWithBoardState(data) {
                }
                self.goToBoardButton.setTitle("Go To Board", forState: .Normal);
                self.connected = true;
                self.goToBoardButton.userInteractionEnabled = true;
                self.disconnectButton.hidden = false;
                self.game.scene.dataDidFinishParsing();
                break;
            case SentDataType.Movement.rawValue:
                self.game.scene.handleMovmentData(data);
                break;
            case SentDataType.MovementEnded.rawValue:
                self.game.scene.handleMovementEnd(data);
                self.game.scene.dataDidFinishParsing();
                break;
            case SentDataType.AddPile.rawValue:
                self.game.scene.handleAddPile(data);
                self.game.scene.dataDidFinishParsing();
                break;
            case SentDataType.CardGiven.rawValue:
                self.game.scene.handleCardGiven(data);
                self.game.scene.dataDidFinishParsing();
                break;
            case SentDataType.CardLaunched.rawValue:
                self.game.scene.handleLaunchCard(data);
                self.game.scene.dataDidFinishParsing();
                break;
            case SentDataType.DeckShuffled.rawValue:
                self.game.scene.handleShuffleDeck(data);
                self.game.scene.dataDidFinishParsing();
            default:
                self.game.scene.dataDidFinishParsing();
                break;
            }
        }
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession!) -> Void)!) {
        let alertController = UIAlertController(title: "Invitation from \(peerID.displayName)", message: nil, preferredStyle: .Alert);
        let decline = UIAlertAction(title: "Decline", style: .Default) { (action) -> Void in
            invitationHandler(false, self.appDelegate.mpcHandler.session);
        }
        alertController.addAction(decline);
        
        let accept = UIAlertAction(title: "Accept", style: .Default) { (action) -> Void in
            invitationHandler(true, self.appDelegate.mpcHandler.session);
            self.goToBoardButton.setTitle("Connecting...", forState: .Normal);
            self.goToBoardButton.userInteractionEnabled = false;
            self.game.host = false;
        }
        alertController.addAction(accept);
        
        self.presentViewController(alertController, animated: true, completion: nil);
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
