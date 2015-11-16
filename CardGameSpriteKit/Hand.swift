//
//  Hand.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/3/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation

class Hand {
    var cards: [Card]!;
    
    init() {
        self.cards = [];
    }
    
    init(cards: [Card]) {
        self.cards = cards;
    }
    
    func addCard(card: Card?) {
        if card == nil || card!.cardValue() == nil {
            return;
        }
        cards.append(card!);
    }
    
    func removeCard(card: Card) -> Card? {
        for (index, aCard) in enumerate(cards) {
            if aCard.cardValue() == card.cardValue() {
                return cards.removeAtIndex(index);
            }
        }
        
        return nil;
    }
    
    func removeTopCard() -> Card? {
        if cards.isEmpty {
            return nil;
        }
        return cards.removeLast();
    }
    
    func peekTopCard() -> Card? {
        if cards.isEmpty {
            return nil;
        }
        return cards[cards.count - 1];
    }
    
    func peekUnderTopCard() -> Card? {
        if cards.count < 2 {
            return nil;
        }
        return cards[cards.count - 2];
    }
    
    func isEmpty() -> Bool {
        return cards.isEmpty;
    }
}