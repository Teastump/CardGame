//
//  CardDictionary.swift
//  CardTest
//
//  Created by Daniel Seitz on 12/12/14.
//  Copyright (c) 2014 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit

/*
Class that contains a dictionary relating the string returned by calling cardValue on a Card struct to a certain image
*/
struct CardDictionary
{
    static let cardNames: [String: String] = [
        //**********Hearts**********\\
        "Ace of Hearts": "heart_ace.png",
        "Two of Hearts": "heart_two.png",
        "Three of Hearts": "heart_three.png",
        "Four of Hearts": "heart_four.png",
        "Five of Hearts": "heart_five.png",
        "Six of Hearts": "heart_six.png",
        "Seven of Hearts": "heart_seven.png",
        "Eight of Hearts": "heart_eight.png",
        "Nine of Hearts": "heart_nine.png",
        "Ten of Hearts": "heart_ten.png",
        "Jack of Hearts": "heart_jack.png",
        "Queen of Hearts": "heart_queen.png",
        "King of Hearts": "heart_king.png",
        //*********Diamonds*********\\
        "Ace of Diamonds": "diamond_ace.png",
        "Two of Diamonds": "diamond_two.png",
        "Three of Diamonds": "diamond_three.png",
        "Four of Diamonds": "diamond_four.png",
        "Five of Diamonds": "diamond_five.png",
        "Six of Diamonds": "diamond_six.png",
        "Seven of Diamonds": "diamond_seven.png",
        "Eight of Diamonds": "diamond_eight.png",
        "Nine of Diamonds": "diamond_nine.png",
        "Ten of Diamonds": "diamond_ten.png",
        "Jack of Diamonds": "diamond_jack.png",
        "Queen of Diamonds": "diamond_queen.png",
        "King of Diamonds": "diamond_king.png",
        //**********Spades**********\\
        "Ace of Spades": "spade_ace.png",
        "Two of Spades": "spade_two.png",
        "Three of Spades": "spade_three.png",
        "Four of Spades": "spade_four.png",
        "Five of Spades": "spade_five.png",
        "Six of Spades": "spade_six.png",
        "Seven of Spades": "spade_seven.png",
        "Eight of Spades": "spade_eight.png",
        "Nine of Spades": "spade_nine.png",
        "Ten of Spades": "spade_ten.png",
        "Jack of Spades": "spade_jack.png",
        "Queen of Spades": "spade_queen.png",
        "King of Spades": "spade_king.png",
        //***********Clubs**********\\
        "Ace of Clubs": "club_ace.png",
        "Two of Clubs": "club_two.png",
        "Three of Clubs": "club_three.png",
        "Four of Clubs": "club_four.png",
        "Five of Clubs": "club_five.png",
        "Six of Clubs": "club_six.png",
        "Seven of Clubs": "club_seven.png",
        "Eight of Clubs": "club_eight.png",
        "Nine of Clubs": "club_nine.png",
        "Ten of Clubs": "club_ten.png",
        "Jack of Clubs": "club_jack.png",
        "Queen of Clubs": "club_queen.png",
        "King of Clubs": "club_king.png"
    ]
    
    static func getTexture(cardName: String) -> SKTexture {
        if let filename = cardNames[cardName] {
            return SKTexture(imageNamed: filename);
        }
        else {
            return SKTexture(imageNamed: "blank_space.png");
        }
    }
}