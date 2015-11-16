//
//  Rules.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/20/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import UIKit

enum GameRules {
    case FreePlay, Custom
}

class Rules {
    static let gameRules = Rules();
    
    @IBOutlet weak var someStepper: UIStepper!;
    
    var gameType: GameRules = .FreePlay; //default FreePlay, no limitations, 1 deck
    //Player Settings
    var maxCardsPerPlayer: UInt = 0; //default 0 = no limit
    var playerHandHidden: Bool = true; //default true
    var playerHandInteractable: Bool = false; //default false;
    var maxPilesPerPlayer: UInt = 0; //default 0 = no limit
    
    //Pile Settings
    var maxCardsPerPile: UInt = 0; //default 0 = no limit
    var playerPilesHidden: Bool = false; //default false
    var playerPilesInteractable: Bool = false; //default false
    
    //Board Settings
    var maxCardsOnField: UInt = 0; //default 0 = no limit
    var maxPilesOnField: UInt = 0; //default 0 = no limit
    var numDecksUsed: UInt = 1; //default 1
    var deckStartsShuffled: Bool = true; //default true
    
    func setRulesFromJSON(jsonRules: JSONRules) {
        self.maxCardsPerPlayer = jsonRules.maxCardsPerPlayer;
        self.playerHandHidden = jsonRules.playerHandHidden;
        self.playerHandInteractable = jsonRules.playerHandInteractable;
        self.maxPilesPerPlayer = jsonRules.maxPilesPerPlayer;
        
        self.maxCardsPerPile = jsonRules.maxCardsPerPile;
        self.playerPilesHidden = jsonRules.playerPilesHidden;
        self.playerPilesInteractable = jsonRules.playerPilesInteractable;
        
        self.maxCardsOnField = jsonRules.maxCardsOnField;
        self.maxPilesOnField = jsonRules.maxPilesOnField;
        self.numDecksUsed = jsonRules.numDecksUsed;
        self.deckStartsShuffled = jsonRules.deckStartsShuffled;
    }
    
    func loadGameTypeNamed(name: String) {
        //Load settings here
    }
    
    func saveGameTypeAs(name: String) {
        //Save settings
    }
    
    func setMaxCardsPerPlayer(num: UInt) {
        maxCardsPerPlayer = num;
    }
    
    func setMaxCardsPerPile(num: UInt) {
        maxCardsPerPile = num;
    }
    
    func setMaxCardsOnField(num: UInt) {
        maxCardsOnField = num;
    }
    
    func setMaxPilesOnField(num: UInt) {
        maxPilesOnField = num;
    }
    
    func setMaxPilesPerPlayer(num: UInt) {
        maxPilesPerPlayer = num;
    }
    
    func setPlayerHandHidden(hidden: Bool) {
        playerHandHidden = hidden;
    }
    
    func setPlayerHandInteractable(interactable: Bool) {
        playerHandInteractable = interactable;
    }
    
    func setPlayerPilesHidden(hidden: Bool) {
        playerPilesHidden = hidden;
    }
    
    func setPlayerPilesInteractable(interactable: Bool) {
        playerPilesInteractable = interactable;
    }
    
    func setNumDecksUsed(num: UInt) {
        numDecksUsed = num;
    }
}