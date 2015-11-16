//
//  JSONCardData.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/17/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation

class JSONCardGiven: Serializable {
    var type = SentDataType.CardGiven.rawValue;
    let card: String!;
    let boardData: JSONBoardState!;
    let sender: JSONCardData!;
    let reciever: JSONCardData!;
    let newPile: JSONPile?;
    let pileAdded: Bool!;
    
    init(cardGiven card: Card, sender: CardProtocol, reciever: CardProtocol, pileWasAdded pileAdded: CardPile?, backupBoardState boardData: JSONBoardState) {
        self.card = card.toJSON();
        self.boardData = boardData;
        self.sender = JSONCardData(card: sender);
        self.reciever = JSONCardData(card: reciever);
        if pileAdded != nil {
            self.pileAdded = true;
            self.newPile = JSONPile(cardPile: pileAdded!);
        }
        else {
            self.pileAdded = false;
            self.newPile = nil;
        }
    }
}

class JSONCardData: Serializable {
    var type: String!;
    var id: Int!;
    
    private override init() {
        super.init();
    }
    
    init(card: CardProtocol?) {
        if card != nil {
        if card is Deck {
            self.type = "Deck";
            self.id = -1;
        }
        else if card is Player {
            self.type = "Player";
            self.id = (card as! Player).playerID;
        }
        else {
            self.type = "Pile";
            self.id = (card as! CardPile).pileID;
        }
        }
        else {
            self.type = "None";
            self.id = -1;
        }
        
    }
    
    static func parseJSONData(jsonCardData data: AnyObject!) -> JSONCardData? {
        let jsonCardData = JSONCardData();
        
        if let cardData = data as? NSDictionary {
            if let type = cardData["type"] as? NSString {
                jsonCardData.type = type as String;
            }
            if let id = cardData["id"] as? Int {
                jsonCardData.id = id;
                return jsonCardData;
            }
        }
        
        return nil;
    }
}