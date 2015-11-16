//
//  JSONMovementData.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/17/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import UIKit

class JSONLaunchData: Serializable {
    var type = SentDataType.CardLaunched.rawValue;
    var cardData: JSONCardData!;
    var card: String!;
    var newPile: JSONPile!;
    var endPoint: String!;
    //var cardWasGiven: Bool!;
    //var reciever: JSONCardData!;
    
    private override init() {
        super.init();
    }
    
    init(launchingPile cardData: CardProtocol, card: Card, newPile: CardPile, endPoint: CGPoint) {
        self.cardData = JSONCardData(card: cardData);
        self.card = card.toJSON();
        self.newPile = JSONPile(cardPile: newPile);
        self.endPoint = "\(endPoint.x),\(endPoint.y)";
        /*
        self.cardWasGiven = cardWasGiven;
        if cardWasGiven {
            self.reciever = JSONCardData(card: reciever);
        }
        else {
            self.reciever = JSONCardData(card: nil);
        }
        */
    }
    
    func decode() -> (Card, CGPoint) {
        let decodedCard = Card(jsonString: card);
        
        let scanner = NSScanner(string: endPoint);
        var x: Float = 0;
        var y: Float = 0;
        
        scanner.scanFloat(&x);
        scanner.scanString(",", intoString: nil);
        scanner.scanFloat(&y);
        
        return (decodedCard, CGPoint(x: CGFloat(x), y: CGFloat(y)));
    }
    
    static func parseJSONData(data: AnyObject!) -> JSONLaunchData? {
        let jsonLaunchData = JSONLaunchData();
        
        if let launchData = data as? NSDictionary {
            if let card = launchData["card"] as? NSString {
                println("card parsed");
                jsonLaunchData.card = card as String;
            }
            if let newPile = JSONPile.parseJSONData(jsonData: launchData["newPile"]) {
                println("newPile parsed");
                jsonLaunchData.newPile = newPile;
            }
            if let endPoint = launchData["endPoint"] as? NSString {
                println("endPoint parsed");
                jsonLaunchData.endPoint = endPoint as String;
            }
            if let cardData = JSONCardData.parseJSONData(jsonCardData: launchData["cardData"]) {
                println("cardData parsed");
                jsonLaunchData.cardData = cardData;
                //jsonLaunchData.reciever = JSONCardData.parseJSONData(jsonCardData: launchData["reciever"]);
                return jsonLaunchData;
            }
        }
        
        return nil;
    }
}

class JSONMovementData: Serializable {
    var type = SentDataType.Movement.rawValue;
    let cardType: String!;
    let moveData: JSONMove!;
    let timestamp: Double!;
    
    init(currentPos curr: CGPoint, movedType: CardProtocol, time timestamp: Double) {
        if movedType is Deck {
            self.moveData = JSONDeckMove(current: curr);
            self.cardType = "Deck";
        }
        else if movedType is Player {
            self.moveData = JSONPlayerMove(current: curr, playerID: (movedType as! Player).playerID);
            self.cardType = "Player";
        }
        else {
            self.moveData = JSONPileMove(current: curr, pileID: (movedType as! CardPile).pileID);
            self.cardType = "Pile";
        }
        
        self.timestamp = timestamp;
    }
}

protocol JSONMove {
    var currentPos: String! { get };
    var id: Int! { get };
    
    func decode() -> CGPoint;
    static func parseJSONData(jsonMovementData data: AnyObject!) -> JSONMove?;
}

class JSONPlayerMove: Serializable, JSONMove {
    var currentPos: String!;
    var id: Int!;
    
    private override init() {
        super.init();
    }
    
    init(current currentPos: CGPoint!, playerID id: Int) {
        self.currentPos = "\(currentPos.x),\(currentPos.y)";
        self.id = id;
    }
    
    func decode() -> CGPoint {
        let scanner = NSScanner(string: currentPos);
        
        var x: Float = 0;
        var y: Float = 0;
        
        scanner.scanFloat(&x);
        scanner.scanString(",", intoString: nil);
        scanner.scanFloat(&y);
        
        let curr = CGPoint(x: CGFloat(x), y: CGFloat(y));
        
        return curr;
    }
    
    static func parseJSONData(jsonMovementData data: AnyObject!) -> JSONMove? {
        let playerMove = JSONPlayerMove();
        
        if let moveData = data as? NSDictionary {
            if let curr = moveData["currentPos"] as? NSString {
                playerMove.currentPos = curr as String;
            }
            if let id = moveData["id"] as? Int {
                playerMove.id = id;
                return playerMove;
            }
        }
        
        return nil;
    }
}

class JSONPileMove: Serializable, JSONMove {
    var currentPos: String!;
    var id: Int!;
    
    private override init() {
        super.init();
    }
    
    init(current currentPos: CGPoint!, pileID id: Int) {
        self.currentPos = "\(currentPos.x),\(currentPos.y)";
        self.id = id;
    }
    
    func decode() -> CGPoint {
        var scanner = NSScanner(string: currentPos);
        var x: Float = 0;
        var y: Float = 0;
        
        scanner.scanFloat(&x);
        scanner.scanString(",", intoString: nil);
        scanner.scanFloat(&y);
        
        let curr = CGPoint(x: CGFloat(x), y: CGFloat(y));
        
        return curr;
    }
    
    static func parseJSONData(jsonMovementData data: AnyObject!) -> JSONMove? {
        let pileMove = JSONPileMove();
        
        if let moveData = data as? NSDictionary {
            if let curr = moveData["currentPos"] as? NSString {
                pileMove.currentPos = curr as String;
            }
            if let id = moveData["id"] as? Int {
                pileMove.id = id;
                return pileMove;
            }
        }
        
        return nil;
    }
}

class JSONDeckMove: Serializable, JSONMove {
    var currentPos: String!;
    var id: Int!;
    
    private override init() {
        super.init();
        
        self.id = -1;
    }
    
    init(current currentPos: CGPoint!) {
        self.currentPos = "\(currentPos.x),\(currentPos.y)";
        self.id = -1;
    }
    
    func decode() -> CGPoint {
        var scanner = NSScanner(string: currentPos);
        var x: Float = 0;
        var y: Float = 0;
        
        scanner.scanFloat(&x);
        scanner.scanString(",", intoString: nil);
        scanner.scanFloat(&y);
        
        let curr = CGPoint(x: CGFloat(x), y: CGFloat(y));
        
        return curr;
    }
    
    static func parseJSONData(jsonMovementData data: AnyObject!) -> JSONMove? {
        let deckMove = JSONDeckMove();
        
        if let moveData = data as? NSDictionary {
            if let curr = moveData["currentPos"] as? NSString {
                deckMove.currentPos = curr as String;
                return deckMove
            }
        }
        
        return nil;
    }
}