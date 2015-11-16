//
//  Deck.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/3/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit

class Deck: SKSpriteNode, CardProtocol {
    var cards: [Card] = [];
    var tempCardCount: Int = 0;
    var placeholderCard: SKSpriteNode;
    
    init() {
        
        for deck in 0..<Rules.gameRules.numDecksUsed {
        for suit in Suit.allValues {
            for rank in Rank.allValues {
                self.cards.append(Card(suit: suit, rank: rank));
            }
        }
        }
        
        self.placeholderCard = SKSpriteNode(texture: cardBackTexture, color: UIColor.clearColor(), size: cardSize);
        
        super.init(texture: cardBackTexture, color: UIColor.clearColor(), size: cardSize);
        
        self.name = "Deck";
        
        self.zPosition = 1;
        self.placeholderCard.zPosition = 0;
        
        if Rules.gameRules.deckStartsShuffled {
            shuffleDeck();
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCard(card: Card?) -> Card? {
        if card == nil || card!.cardValue() == nil || !spaceAvailable() {
            return nil;
        }
        cards.append(card!);
        return nil;
    }
    
    func removeCard(card: Card) -> Card? {
        for (index, aCard) in enumerate(cards) {
            if aCard.cardValue() == card.cardValue() {
                updateTexture();
                return cards.removeAtIndex(index);
            }
        }
        
        return nil;
    }
    
    func removeTopCard() -> Card? {
        if cards.isEmpty {
            return nil;
        }
        else {
            var top = cards.removeLast();
            updateTexture();
            return top;
        }
    }
    
    func updateTexture() {
        if cards.isEmpty {
            self.texture = blankTexture;
            self.placeholderCard.texture = whiteTexture;
        }
        else if cards.count == 1 {
            self.texture = cardBackTexture;
            self.placeholderCard.texture = whiteTexture;
        }
        else {
            self.texture = cardBackTexture;
            self.placeholderCard.texture = cardBackTexture;
        }
    }
    
    func isEmpty() -> Bool {
        return cards.isEmpty;
    }
    
    func spaceAvailable() -> Bool {
        return true;
    }
    
    /*
    Function that shuffles the cards in the deck
    */
    func shuffleDeck()
    {
        for var i = 0; i < cards.count; ++i //Iterates over each card in the deck
        {
            var r = Int(arc4random_uniform(UInt32(cards.count))) //Gets a random number from 0 - (cards.count - 1)
            var tempCard = cards[r] //Stores the randomly chosen card in a temporary
            cards[r] = cards[i] //Replaces randomly chosen card with current card
            cards[i] = tempCard //Switches current card back with the randomly chosen card
        }
    }
}