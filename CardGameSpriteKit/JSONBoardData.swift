//
//  JSONPlayer.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/15/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class JSONRules: Serializable {
    var maxCardsPerPlayer: UInt; //default 0 = no limit
    var playerHandHidden: Bool; //default true
    var playerHandInteractable: Bool; //default false;
    var maxPilesPerPlayer: UInt; //default 0 = no limit
    
    //Pile Settings
    var maxCardsPerPile: UInt; //default 0 = no limit
    var playerPilesHidden: Bool; //default false
    var playerPilesInteractable: Bool; //default false
    
    //Board Settings
    var maxCardsOnField: UInt; //default 0 = no limit
    var maxPilesOnField: UInt; //default 0 = no limit
    var numDecksUsed: UInt; //default 1
    var deckStartsShuffled: Bool; //default true
    
    override init() {
        self.maxCardsPerPlayer = Rules.gameRules.maxCardsPerPlayer;
        self.playerHandHidden = Rules.gameRules.playerHandHidden;
        self.playerHandInteractable = Rules.gameRules.playerHandInteractable;
        self.maxPilesPerPlayer = Rules.gameRules.maxPilesPerPlayer;
        
        self.maxCardsPerPile = Rules.gameRules.maxCardsPerPile;
        self.playerPilesHidden = Rules.gameRules.playerPilesHidden;
        self.playerPilesInteractable = Rules.gameRules.playerPilesInteractable;
        
        self.maxCardsOnField = Rules.gameRules.maxCardsOnField;
        self.maxPilesOnField = Rules.gameRules.maxPilesOnField;
        self.numDecksUsed = Rules.gameRules.numDecksUsed;
        self.deckStartsShuffled = Rules.gameRules.deckStartsShuffled;
        
        super.init();
    }
    
    static func parseJSONData(jsonData data: AnyObject!) -> JSONRules? {
        let jsonRules = JSONRules();
        
        if let ruleData = data as? NSDictionary {
            jsonRules.maxCardsPerPlayer = ruleData["maxCardsPerPlayer"] as! UInt;
            jsonRules.playerHandHidden = ruleData["playerHandHidden"] as! Bool;
            jsonRules.playerHandInteractable = ruleData["playerHandInteractable"] as! Bool;
            jsonRules.maxPilesPerPlayer = ruleData["maxPilesPerPlayer"] as! UInt;
            
            jsonRules.maxCardsPerPile = ruleData["maxPilesPerPlayer"] as! UInt;
            jsonRules.playerPilesHidden = ruleData["playerPilesHidden"] as! Bool;
            jsonRules.playerPilesInteractable = ruleData["playerPilesInteractable"] as! Bool;
            
            jsonRules.maxCardsOnField = ruleData["maxCardsOnField"] as! UInt;
            jsonRules.maxPilesOnField = ruleData["maxPilesOnField"] as! UInt;
            jsonRules.numDecksUsed = ruleData["numDecksUsed"] as! UInt;
            jsonRules.deckStartsShuffled = ruleData["deckStartsShuffled"] as! Bool;
            
            return jsonRules;
        }
        
        return nil;
    }
}

class JSONDeckShuffled: Serializable {
    let type = SentDataType.DeckShuffled.rawValue;
    var deck: JSONDeck!;
    
    init(deck: Deck) {
        self.deck = JSONDeck(deck: deck);
    }
}

class JSONBoardState: Serializable {
    let type = SentDataType.BoardState.rawValue;
    let rules = JSONRules();
    let yourID = Player.count - 1;
    var maxPlayers: Int!;
    var maxPiles: Int!;
    var deck: JSONDeck!;
    var players: [JSONPlayer] = [];
    var piles: [JSONPile] = [];
    
    init(deck: Deck, players: [Player], piles: [CardPile]) {
        self.maxPlayers = Player.count;
        self.maxPiles = CardPile.count;
        
        self.deck = JSONDeck(deck: deck);
        
        for player in players {
            self.players.append(JSONPlayer(player: player));
        }
        
        for pile in piles {
            self.piles.append(JSONPile(cardPile: pile));
        }
    }
}

class JSONPlayer: Serializable {
    var name: String!;
    var position: String!;
    var playerID: String!;
    var cards: [String] = [];
    
    private override init() {
        super.init();
    }
    
    init (player: Player) {
        self.name = player.playerName.text;
        self.position = "\(player.placeholderCard.position.x),\(player.placeholderCard.position.y)";
        self.playerID = "\(player.playerID)";
        for card in player.hand.cards {
            cards.append(card.toJSON());
        }
    }
    
    func decode() -> (CGPoint, [Card]) {
        let scanner = NSScanner(string: position);
        var x: Float = 0;
        var y: Float = 0;
        var decodedCards: [Card] = [];
        
        scanner.scanFloat(&x);
        scanner.scanString(",", intoString: nil);
        scanner.scanFloat(&y);
        
        for card in cards {
            decodedCards.append(Card(jsonString: card));
        }
        
        return (CGPoint(x: CGFloat(x), y: CGFloat(y)), decodedCards);
    }
    
    static func parseJSONData(jsonData data: AnyObject!) -> JSONPlayer? {
        let jsonPlayer = JSONPlayer();
        
        if let playerData = data as? NSDictionary {
            if let name = playerData["name"] as? NSString {
                jsonPlayer.name = name as String;
                if let position = playerData["position"] as? NSString {
                    jsonPlayer.position = position as String;
                    if let playerID = playerData["playerID"] as? NSString {
                        jsonPlayer.playerID = playerID as String;
                        if let cards = playerData["cards"] as? NSArray {
                            for card in cards {
                                jsonPlayer.cards.append(card as! String);
                            }
                            return jsonPlayer;
                        }
                    }
                }
            }
        }
        
        return nil;
    }
}

class JSONPile: Serializable {
    var type = SentDataType.AddPile.rawValue;
    var position: String!;
    var pileID: String!;
    var cards: [String] = [];
    
    private override init() {
        super.init();
    }
    
    init (cardPile: CardPile) {
        self.position = "\(Float(cardPile.placeholderCard.position.x)),\(Float(cardPile.placeholderCard.position.y))";
        self.pileID = "\(cardPile.pileID)";
        for card in cardPile.pile.cards {
            cards.append(card.toJSON());
        }
    }
    
    func decode() -> (CGPoint, [Card]) {
        let scanner = NSScanner(string: position);
        var x: Float = 0;
        var y: Float = 0;
        var decodedCards: [Card] = [];
        
        scanner.scanFloat(&x);
        scanner.scanString(",", intoString: nil);
        scanner.scanFloat(&y);
        
        for card in cards {
            decodedCards.append(Card(jsonString: card));
        }
        
        return (CGPoint(x: CGFloat(x), y: CGFloat(y)), decodedCards);
    }
    
    static func parseJSONData(jsonData data: AnyObject!) -> JSONPile? {
        let jsonPile = JSONPile()
        
        
                    if let pileData = data as? NSDictionary {
                        if let cards = pileData["cards"] as? NSArray {
                            for card in cards {
                                jsonPile.cards.append(card as! String);
                            }
                        }
                        if let pileID = pileData["pileID"] as? NSString {
                            jsonPile.pileID = pileID as String;
                        }
                        if let position = pileData["position"] as? NSString {
                            jsonPile.position = position as String;
                            return jsonPile;
                        }
                    }
        
        
        return nil;
    }
}

class JSONDeck: Serializable {
    var cards: [String] = [];
    
    private override init() {
        super.init();
    }
    
    init (deck: Deck) {
        for card in deck.cards {
            cards.append(card.toJSON());
        }
    }
    
    func decode() -> [Card] {
        var decodedCards: [Card] = [];
        for card in cards {
            decodedCards.append(Card(jsonString: card))
        }
        
        return decodedCards;
    }
    
    static func parseJSONData(jsonData data: AnyObject!) -> JSONDeck? {
        
        let jsonDeck = JSONDeck();
        
        if let deck = data as? NSDictionary {
            if let cards = deck["cards"] as? NSArray {
                for card in cards {
                    jsonDeck.cards.append(card as! String);
                }
                return jsonDeck;
            }
        }
        
        return nil;
    }
}