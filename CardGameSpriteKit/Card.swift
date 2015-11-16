//
//  Card.swift
//  CardTest
//
//  Created by Daniel Seitz on 12/12/14.
//  Copyright (c) 2014 Daniel Seitz. All rights reserved.
//

import Foundation

/*
Enum for the suit of a card, contains function for returning a string based on the value of the enum
*/
enum Suit: Int
{
    case Heart, Diamond, Spade, Club, NoSuit
    
    static let allValues = [Heart, Diamond, Spade, Club] //Array of all values used to iterate through each value
    
    init()
    {
        self = NoSuit
    }
    
    init(suit: Suit)
    {
        self = suit
    }
    
    /*
    Function that returns a string based on the value of the enum
    */
    func suit() -> String?
    {
        switch self
        {
        case Heart:
            return "Hearts"
        case Diamond:
            return "Diamonds"
        case Spade:
            return "Spades"
        case Club:
            return "Clubs"
        default:
            return nil
        }
    }
}

/*
Enum for the rank of a card, contains function for returning a string based on the value of the enum
*/
enum Rank: Int
{
    case Ace = 1, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King, NoRank
    
    static let allValues = [Ace, Two, Three, Four, Five, Six, Seven, Eight, Nine, Ten, Jack, Queen, King] //Array used to iterate through all values of the enum
    
    init()
    {
        self = NoRank
    }
    
    init(rank: Rank)
    {
       self = rank
    }
    
    /*
    Function that returns a string based on the value of the enum
    */
    func rank() -> String?
    {
        switch self
        {
        case Ace:
            return "Ace of "
        case Two:
            return "Two of "
        case Three:
            return "Three of "
        case Four:
            return "Four of "
        case Five:
            return "Five of "
        case Six:
            return "Six of "
        case Seven:
            return "Seven of "
        case Eight:
            return "Eight of "
        case Nine:
            return "Nine of "
        case Ten:
            return "Ten of "
        case Jack:
            return "Jack of "
        case Queen:
            return "Queen of "
        case King:
            return "King of "
        default:
            return nil
        }
    }
}

/*
Struct containg a suit and a rank value
*/
class Card: NSObject, NSCoding
{
    var suit: Suit
    var rank: Rank
    
    override init()
    {
        self.suit = Suit()
        self.rank = Rank()
    }
    
    init(jsonString: String) {
        var suit: Int = 0;
        var rank: Int = 0;
        let scanner = NSScanner(string: jsonString);
        scanner.scanInteger(&suit);
        scanner.scanString(",", intoString: nil);
        scanner.scanInteger(&rank);
        
        self.suit = Suit(rawValue: suit)!;
        self.rank = Rank(rawValue: rank)!;
    }
    
    init(suit: Suit, rank: Rank)
    {
        self.suit = Suit(suit: suit)
        self.rank = Rank(rank: rank)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        self.suit = Suit(rawValue: Int(aDecoder.decodeInt32ForKey("Suit")))!
        self.rank = Rank(rawValue: Int(aDecoder.decodeInt32ForKey("Rank")))!
    }
    
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeInt(Int32(self.suit.rawValue), forKey: "Suit")
        aCoder.encodeInt(Int32(self.rank.rawValue), forKey: "Rank")
    }
    /*
    Function that returns a string based on the rank and suit of a card
    */
    func cardValue() -> String?
    {
        let suitValue = suit.suit()
        let rankValue = rank.rank()
        
        if suitValue != nil && rankValue != nil
        {
            return rankValue! + suitValue!
        }
        else
        {
            return nil
        }
    }
    
    func toJSON() -> String {
        return "\(suit.rawValue),\(rank.rawValue)";
    }
}