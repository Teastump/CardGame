//
//  CardSprite.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/6/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit

class CardSprite: SKSpriteNode {
    let card: Card;
    
    init(card: Card, displayValue: Bool = true) {
        self.card = card;
        
        let texture = CardDictionary.getTexture(card.cardValue()!);
        
        if displayValue {
            super.init(texture: texture, color: UIColor.clearColor(), size: CGSize(width: cardSize.width * 3, height: cardSize.height * 3))
        }
        else {
            super.init(texture: cardBackTexture, color: UIColor.clearColor(), size: CGSize(width: cardSize.width * 3, height: cardSize.height * 3))
        }
        
        self.name = "Card";
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}