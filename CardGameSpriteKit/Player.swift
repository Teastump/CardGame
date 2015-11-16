//
//  Player.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/3/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit
import MultipeerConnectivity

let blankTexture = SKTexture(imageNamed: "blank_space.png");
let whiteTexture = SKTexture(imageNamed: "white_space.jpg");
let cardBackTexture = SKTexture(imageNamed: "card_back.jpeg");

let screenSize: CGSize = UIScreen.mainScreen().bounds.size;
let screenWidth = screenSize.width;
let screenHeight = screenSize.height;

let sceneWidth = CGFloat(1024);
let sceneHeight = CGFloat(768);

//1:1.775
let cardSize = CGSize(width: sceneWidth * 0.2, height: sceneHeight * 0.15);

class Player: SKSpriteNode, CardProtocol {
    static var count: Int = 0;
    var playerName: SKLabelNode!;
    var placeholderCard: SKSpriteNode;
    var tempCardCount = 0;
    let peerID: MCPeerID!;
    let playerID: Int!
    var hand: Hand!;
    var isUser: Bool = false;
    var piles: [CardPile] = [];
    
    init(peerID: MCPeerID) {
        self.peerID = peerID;
        self.playerID = Player.count;
        
        self.playerName = SKLabelNode(text: peerID.displayName);
        self.playerName.fontSize = 30;
        self.playerName.fontName = "System";
        
        self.placeholderCard = SKSpriteNode(texture: blankTexture, color: UIColor.clearColor(), size: cardSize)
        
        self.hand = Hand();
        
        super.init(texture: blankTexture, color: UIColor.clearColor(), size: cardSize);
        
        self.name = "Player";
        self.placeholderCard.name = "Placeholder";
        self.playerName.name = "PlayerLabel";
        self.playerName.userInteractionEnabled = false;

        self.playerName.zPosition = 0;
        self.placeholderCard.zPosition = 0;
        self.zPosition = 1;
        
        self.isUser = (self.peerID == (UIApplication.sharedApplication().delegate as! AppDelegate).mpcHandler.peerID)
        
        if !self.isUser {
            //self.userInteractionEnabled = true;
        }
        
        ++Player.count;
    }
    
    init(jsonPlayerData player: JSONPlayer) {
        let scanner = NSScanner(string: player.playerID);
        self.peerID = nil;
        let decoded = player.decode();
        
        var id: Int = 0;
        
        scanner.scanInteger(&id);
        
        self.playerID = id;
        
        self.playerName = SKLabelNode(text: player.name);
        self.playerName.fontSize = 20;
        
        self.placeholderCard = SKSpriteNode(texture: blankTexture, color: UIColor.clearColor(), size: cardSize);
        
        self.hand = Hand(cards: decoded.1);
        self.tempCardCount = hand.cards.count;
        
        super.init(texture: blankTexture, color: UIColor.clearColor(), size: cardSize);
        
        self.name = "Player";
        self.placeholderCard.name = "Placeholder";
        self.playerName.name = "PlayerLabel";
        self.playerName.userInteractionEnabled = false;
        
        self.playerName.zPosition = 0;
        self.placeholderCard.zPosition = 0;
        self.zPosition = 1;
        
        self.isUser = (myID == self.playerID);
        if !self.isUser {
            //self.userInteractionEnabled = true;
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCard(card: Card?) -> Card? {
        if spaceAvailable() {
            hand.addCard(card);
            updateTexture();
            if tempCardCount < hand.cards.count {
                tempCardCount = hand.cards.count;
            }
            return nil;
        }
        return card;
    }
    
    func removeCard(card: Card) -> Card? {
        if let aCard = hand.removeCard(card) {
            --tempCardCount;
            updateTexture();
            return aCard;
        }
        
        return nil;
    }
    
    func removeTopCard() -> Card? {
        if let topCard = hand.removeTopCard() {
            --tempCardCount;
            updateTexture();
            return topCard;
        }
        
        return nil;
    }
    
    func isEmpty() -> Bool {
        if hand.peekTopCard() == nil {
            return true;
        }
        else {
            return false;
        }
    }
    
    func updateTexture() {
        
        if let card = hand.peekTopCard() {
            if isUser || !Rules.gameRules.playerHandHidden {
                self.texture = CardDictionary.getTexture(card.cardValue()!);
            }
            else {
                self.texture = cardBackTexture;
            }
            if let card2 = hand.peekUnderTopCard() {
                if isUser || !Rules.gameRules.playerHandHidden {
                    self.placeholderCard.texture = CardDictionary.getTexture(card2.cardValue()!);
                }
                else {
                    self.placeholderCard.texture = cardBackTexture;
                }
            }
            else {
                self.placeholderCard.texture = blankTexture
            }
        }
        else {
            self.texture = blankTexture;
            self.placeholderCard.texture = blankTexture;
        }
        
    }
    
    func spaceAvailable() -> Bool {
        if Rules.gameRules.maxCardsPerPlayer != 0 {
            return UInt(hand.cards.count) < Rules.gameRules.maxCardsPerPlayer;
        }
        return true;
    }
    
    func pilesAvailable() -> Bool {
        if Rules.gameRules.maxPilesPerPlayer != 0 {
            return UInt(piles.count) < Rules.gameRules.maxPilesPerPlayer;
        }
        return true;
    }
    
    func getHand() -> Hand {
        return self.hand;
    }
    
}