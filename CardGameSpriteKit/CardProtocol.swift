//
//  CardProtocol.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/9/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit

protocol CardProtocol {
    var placeholderCard: SKSpriteNode { get };
    var tempCardCount: Int { get set };
    
    mutating func addCard(Card?) -> Card?; //Returns nil if card successfully added, or the card if there was not enough space to add it
    func removeCard(Card) -> Card?;
    mutating func removeTopCard() -> Card?;
    func isEmpty() -> Bool;
    func spaceAvailable() -> Bool;
    func updateTexture();
    
    
}