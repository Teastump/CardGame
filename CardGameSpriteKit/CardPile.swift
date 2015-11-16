//
//  CardPile.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/5/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit

class CardPile: SKSpriteNode, CardProtocol {
    static var count: Int = 0;
    var owner: Player? = nil;
    var isAnimating: Bool = false;
    var isBeingSent: Bool = false;
    var isBeingRecieved: Bool = false;
    var pile: Hand!;
    var placeholderCard: SKSpriteNode;
    var tempCardCount: Int = 0;
    let pileID: Int!;
    
    init() {
        self.pileID = CardPile.count;
        
        self.pile = Hand();
        
        self.placeholderCard = SKSpriteNode(texture: blankTexture, color: UIColor.clearColor(), size: cardSize);
        
        super.init(texture: blankTexture, color: UIColor.clearColor(), size: cardSize);
        
        self.name = "Pile";
        self.zPosition = 1;
        self.placeholderCard.name = "Placeholder";
        self.placeholderCard.zPosition = 0;
        
        ++CardPile.count;
    }
    
    init(jsonPileData data: JSONPile) {
        let scanner = NSScanner(string: data.pileID);
        let decoded = data.decode();
        
        var id: Int = 0;
        scanner.scanInteger(&id);
        
        self.pileID = id;
        
        self.pile = Hand(cards: decoded.1);
        self.tempCardCount = pile.cards.count;
        
        self.placeholderCard = SKSpriteNode(texture: blankTexture, color: UIColor.clearColor(), size: cardSize);
        
        super.init(texture: blankTexture, color: UIColor.clearColor(), size: cardSize);
        
        self.name = "Pile";
        self.zPosition = 1;
        self.placeholderCard.name = "Placeholder";
        self.placeholderCard.zPosition = 0;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPlayer(player: Player) {
        self.owner = player;
        player.piles.append(self);
    }
    
    func addCard(card: Card?) -> Card? {
        if spaceAvailable() {
            pile.addCard(card);
            updateTexture();
            if tempCardCount < pile.cards.count {
                tempCardCount = pile.cards.count;
            }
            return nil;
        }
        return card;
    }
    
    func removeCard(card: Card) -> Card? {
        if let aCard = pile.removeCard(card) {
            --tempCardCount;
            updateTexture();
            return aCard;
        }
        
        return nil;
    }
    
    func removeTopCard() -> Card? {
        
        if let topCard = pile.removeTopCard() {
            --tempCardCount;
            updateTexture();
            return topCard;
        }
        
        return nil;
    }
    
    internal func updateTexture() {
        
        if let card = pile.peekTopCard() {
            if owner != nil && !owner!.isUser && Rules.gameRules.playerPilesHidden {
                self.texture = cardBackTexture;
            }
            else {
                self.texture = CardDictionary.getTexture(card.cardValue()!);
            }
            if let card2 = pile.peekUnderTopCard() {
                if owner != nil && !owner!.isUser && Rules.gameRules.playerPilesHidden {
                    self.placeholderCard.texture = cardBackTexture;
                }
                else {
                    self.placeholderCard.texture = CardDictionary.getTexture(card2.cardValue()!);
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
    
    func isEmpty() -> Bool {
        return pile.isEmpty();
    }
    
    func spaceAvailable() -> Bool {
        if Rules.gameRules.maxCardsPerPile != 0 {
            return UInt(pile.cards.count) < Rules.gameRules.maxCardsPerPile;
        }
        return true;
    }
    
    func getHand() -> Hand {
        return self.pile;
    }
}