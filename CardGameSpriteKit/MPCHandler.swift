//
//  MPCHandler.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/10/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum SentDataType: Int {
    case BoardState, Movement, MovementEnded, AddPile, CardGiven, CardLaunched, DeckShuffled
}

class MPCHandler: NSObject, MCSessionDelegate {
    
    var peerID: MCPeerID!;
    var session: MCSession!;
    var browser: MCBrowserViewController!;
    var nearbyAdvertiser: MCNearbyServiceAdvertiser? = nil;
    var advertiser: MCAdvertiserAssistant? = nil;
    var state: MCSessionState = .NotConnected;
    var game: GameViewController!;
    
    func setupPeerWithDisplayName(displayName: String) {
        peerID = MCPeerID(displayName: displayName);
    }
    
    func setupSession() {
        session = MCSession(peer: peerID);
        session.delegate = self;
    }
    
    func setupBrowser() {
        browser = MCBrowserViewController(serviceType: "dseitz-cardgame", session: session);
    }
    
    func advertiseSelf(advertise: Bool) {
        /*
        if advertise {
            advertiser = MCAdvertiserAssistant(serviceType: "dseitz-cardgame", discoveryInfo: nil, session: session);
            advertiser!.start();
        }
        else {
            advertiser!.stop();
            advertiser = nil;
        }
        */
        
        if advertise {
            nearbyAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "dseitz-cardgame");
            nearbyAdvertiser!.startAdvertisingPeer();
        }
        else {
            nearbyAdvertiser?.stopAdvertisingPeer();
            nearbyAdvertiser = nil;
        }
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        let userInfo = ["peerID":peerID, "state":state.rawValue];
        
        println("State Changed in MPCHandler.");
        
        dispatch_async(dispatch_get_main_queue()) {
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidChangeStateNotification", object: nil, userInfo: userInfo);
        }
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
        let userInfo = ["data":data, "peerID":peerID];
        
        dispatch_async(recievedNetworkDispatch) {
            NSNotificationCenter.defaultCenter().postNotificationName("MPC_DidRecieveDataNotification", object: nil, userInfo: userInfo);
        }
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
        
    }
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
        /*
        stream.delegate = game;
        
        stream.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode);
        stream.open();
        */
    }
}
