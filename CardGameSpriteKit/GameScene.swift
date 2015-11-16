//
//  GameScene.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/3/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import SpriteKit
import MultipeerConnectivity

class GameScene: SKScene {
    var vc: GameViewController!;
    var players: [Player] = [];
    var piles: [CardPile] = [];
    var deck = Deck();
    var selectedNode: SKNode? = nil;
    var origin: CGPoint? = nil;
    var mpcHandler: MPCHandler!
    private var pans: Int = 0;
    private var previousTimeInterval: NSTimeInterval?;
    private var timer: NSTimer?
    var timeInterval: NSTimeInterval = 0;
    private var lastTimeMoved: NSTimeInterval = 0;
    private var timerPaused: Bool = false;
    //var openStreams: [NSOutputStream] = [];
    
    override func didMoveToView(view: SKView) {
        
        selectedNode = nil;
        
        self.deck.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.deck.placeholderCard.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
    }
    
    func startNewGame() {
        self.deck = Deck();
        
        self.deck.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.deck.placeholderCard.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        if deck.parent == nil {
            self.addChild(deck);
            self.addChild(deck.placeholderCard);
        }
    }
    
    func spaceOnField() -> Bool {
        if Rules.gameRules.maxCardsOnField == 0 {
            return true;
        }
        
        var pileCardCount: UInt = 0;
        for pile in piles {
            pileCardCount += UInt(pile.pile.cards.count);
        }
        
        return pileCardCount < Rules.gameRules.maxCardsOnField;
    }
    
    func spaceForPilesOnField() -> Bool {
        if Rules.gameRules.maxPilesOnField == 0 {
            return true;
        }
        
        return UInt(piles.count) < Rules.gameRules.maxPilesOnField;
    }
    
    func dataWasRecieved() {
        self.userInteractionEnabled = false;
    }
    
    func dataDidFinishParsing() {
        self.userInteractionEnabled = true;
    }
    
    func updateTime() {
        if !timerPaused {
            timeInterval += 0.001;
            if timeInterval - lastTimeMoved > 0.1 {
                self.pauseTimer();
            }
        }
    }
    
    func startTimer() {
        if (timer == nil) || (!timer!.valid) {
            println("Timer Started");
            timeInterval = 0;
            lastTimeMoved = 0;
            timer = NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "updateTime", userInfo: nil, repeats: true);
        }
    }
    
    func pauseTimer() {
        println("Timer Paused");
        timerPaused = true;
    }
    
    func resumeTimer() {
        println("Timer Resumed");
        lastTimeMoved = timeInterval;
        timerPaused = false;
    }
    
    func stopTimer() {
        println("Timer Ended");
        timer?.invalidate();
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        var touch = touches.first as! UITouch;
        if selectedNode != nil {
            return;
        }
        
        for node in self.nodesAtPoint(touch.locationInNode(self)) {
            if selectedNode == nil && node is CardProtocol {
                selectedNode = (node as! SKNode);
            }
            else {
                if node.zPosition > selectedNode?.zPosition && node is CardProtocol {
                    selectedNode = (node as! SKNode);
                }
            }
        }
        
        if let selected = selectedNode as? Player where !selected.isUser && Rules.gameRules.playerHandInteractable {
            selectedNode = nil;
        }
        if let selected = selectedNode as? CardPile where selected.owner != nil && !selected.owner!.isUser && Rules.gameRules.playerPilesInteractable {
            selectedNode = nil;
        }
        
        if selectedNode?.userInteractionEnabled == true {
            selectedNode = nil;
        }
        selectedNode?.zPosition = 2;
        origin = selectedNode?.position;
        
        println("Selected Node: \(selectedNode?.name)");
        
        /*
        for peer in mpcHandler.session.connectedPeers {
        let oStream = mpcHandler.session.startStreamWithName("positionData", toPeer: peer as! MCPeerID, error: nil);
        openStreams.append(oStream);
        }
        */
        if selectedNode != nil {
            startTimer();
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch = touches.first as! UITouch;
        
        self.resumeTimer();
        
        println("Current time interval: \(timeInterval)");
        
        if selectedNode != nil {
            var position = touch.locationInNode(self);
            
            if position.x > CGRectGetMaxX(self.frame) {
                position.x = CGRectGetMaxX(self.frame) - 10;
            }
            if position.x < CGRectGetMinX(self.frame) {
                position.x = CGRectGetMinX(self.frame) + 10;
            }
            if position.y > CGRectGetMaxY(self.frame) {
                position.y = CGRectGetMaxY(self.frame) - 10;
            }
            if position.y < CGRectGetMinY(self.frame) {
                position.y = CGRectGetMinY(self.frame) + 10;
            }
            
            let previousPosition = touch.previousLocationInNode(self);
            let translation = CGPoint(x: position.x - previousPosition.x, y: position.y - previousPosition.y);
            
            self.panSprite(translation);
            
            /*
            for stream in openStreams {
            stream.write(UnsafePointer<UInt8>(movementData.toJson().bytes), maxLength: movementData.toJson().length);
            }
            */
            
            if (pans % 3) == 0 {
                let dt: NSTimeInterval;
                if previousTimeInterval == nil {
                    previousTimeInterval = timeInterval;
                    dt = timeInterval;
                }
                else {
                    dt = timeInterval - previousTimeInterval!;
                }
                
                let movementData = JSONMovementData(currentPos: self.selectedNode!.position, movedType: self.selectedNode as! CardProtocol, time: dt);
                
                println(movementData.toJsonString());
                dispatch_async(networkDispatch) {
                    self.vc.sendData(movementData.toJson());
                }
            }
        }
        
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch;
        
        if selectedNode == nil {
            return;
        }
        
        
        
        /*
        for stream in openStreams {
        stream.write(UnsafePointer<UInt8>(movementData.toJson().bytes), maxLength: movementData.toJson().length);
        stream.close();
        }
        */
        
        if touch.tapCount == 2 {
            println("Double Tap!");
            
            //NEED TO LOCK OUT OTHER USERS FROM INTERACTING WITH DOUBLE TAPPED PILE WHILE USER IN IN HAND VIEW
            
            if selectedNode != nil {
                let hand: Hand;
                if selectedNode!.name == "Deck" {
                    selectedNode!.zPosition = 1;
                    vc.goToDeckScene(self.scene!.size, deck: deck, gameScene: self);
                    return;
                }
                else if selectedNode!.name == "Player" {
                    hand = (selectedNode as! Player).getHand();
                }
                else {
                    hand = (selectedNode as! CardPile).getHand();
                }
                
                selectedNode!.zPosition = 1;
                
                
                
                vc.goToHandScene(self.scene!.size, hand: hand, gameScene: self);
                
                return;
            }
        }
        
        if selectedNode != nil {
            var pileAdded: Bool = false;
            var addedPile: CardPile? = nil;
            if self.nodesAtPoint(touch.locationInNode(self)).count <= 1 {
                if spaceForPilesOnField() || (selectedNode is CardPile && (selectedNode as! CardPile).pile.cards.count <= 1) {
                    if !(selectedNode is Player) || (selectedNode as! Player).pilesAvailable()
                    {
                        addedPile = self.addPile(atPoint: touch.locationInNode(self));
                        if selectedNode is Player {
                            addedPile!.setPlayer(selectedNode as! Player);
                        }
                        pileAdded = true;
                    }
                }
            }
            for node in self.nodesAtPoint(touch.locationInNode(self)) {
                if (node as? SKNode) == nil {
                    break;
                }
                if (node as? SKNode) != selectedNode && ((node as? SKNode)?.name == "Player" || (node as? SKNode)?.name == "Pile") {
                    var sender: CardProtocol = selectedNode as! CardProtocol;
                    var reciever: CardProtocol = node as! CardProtocol;
                    
                    if !reciever.spaceAvailable() || (reciever is CardPile && !spaceOnField()) {
                        break;
                    }
                    else if let cardGiven = sender.removeTopCard() {
                        
                        reciever.addCard(cardGiven);
                        
                        let jsonCardSent = JSONCardGiven(cardGiven: cardGiven, sender: sender, reciever: reciever, pileWasAdded: addedPile, backupBoardState: JSONBoardState(deck: deck, players: players, piles: piles));
                        
                        println(jsonCardSent.toJsonString());
                        dispatch_async(networkDispatch) {
                            self.vc.sendData(jsonCardSent.toJson());
                        }
                        
                    }
                    
                    break;
                }
            }
            selectedNode!.position = origin!;
            let movementData = JSONMovementData(currentPos: origin!, movedType: selectedNode as! CardProtocol, time: 0.001);
            movementData.type = SentDataType.MovementEnded.rawValue;
            
            dispatch_async(networkDispatch) {
                self.vc.sendData(movementData.toJson());
            }
            
            if selectedNode != self {
                selectedNode!.zPosition = 1;
            }
            
            selectedNode = nil;
            
            previousTimeInterval = nil;
            stopTimer();
        }
    }
    
    func panSprite(translation: CGPoint) {
        if let position = selectedNode?.position {
            selectedNode!.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y);
            ++pans;
        }
    }
    
    func handleCardGiven(data: NSDictionary) {
        
        println("Card Given Data Recieved.");
        if let cardAdded = data["pileAdded"] as? Bool {
            
            println("Pile Added data is: \(cardAdded)");
            if cardAdded {
                handleAddPile(data["newPile"] as! NSDictionary);
            }
            
            if let senderData = JSONCardData.parseJSONData(jsonCardData: data["sender"]) {
                if let recieverData = JSONCardData.parseJSONData(jsonCardData: data["reciever"]) {
                    var sender: CardProtocol!;
                    var reciever: CardProtocol!;
                    
                    var senderFound: Bool!;
                    var count = 0;
                    do {
                        while sender == nil {
                            ++count;
                            println("Sender of Card Given is nil");
                            if count > 100 {
                                break;
                            }
                            if senderData.type == "Deck" {
                                sender = deck;
                            }
                            else if senderData.type == "Player" {
                                for player in players {
                                    if player.playerID == senderData.id {
                                        sender = player;
                                        break;
                                    }
                                }
                            }
                            else {
                                for pile in piles {
                                    if pile.pileID == senderData.id {
                                        sender = pile;
                                        break;
                                    }
                                }
                            }
                        }
                        
                        count = 0;
                        while reciever == nil {
                            ++count;
                            println("Reciever of Card Given is nil");
                            if count > 100 {
                                break;
                            }
                            if recieverData.type == "Player" {
                                for player in self.players {
                                    if player.playerID == recieverData.id {
                                        reciever = player;
                                        break;
                                    }
                                }
                            }
                            else {
                                for pile in self.piles {
                                    if pile.pileID == recieverData.id {
                                        reciever = pile;
                                        break;
                                    }
                                }
                            }
                        }
                        if sender == nil || reciever == nil {
                            self.setBoardWithBoardState(data["boardData"] as! NSDictionary)
                        }
                    } while(sender == nil || reciever == nil);
                    
                    if let cardString = data["card"] as? NSString {
                        let card = Card(jsonString: cardString as String);
                        reciever.addCard(sender.removeCard(card));
                        if reciever is CardPile {
                            (reciever as! CardPile).isBeingSent = false;
                        }
                    }
                    
                }
            }
        }
    }
    
    func handleMovmentData(data: NSDictionary) {
        
        println("MovementData Recieved");
        
        if let duration = data["timestamp"] as? Double {
            if let cardType = data["cardType"] as? NSString {
                println(cardType);
                let interpolateMove: SKAction;
                switch cardType {
                case "Deck":
                    if let jsonMoveData = JSONDeckMove.parseJSONData(jsonMovementData: data["moveData"]) as? JSONDeckMove {
                        deck.zPosition = 2;
                        deck.userInteractionEnabled = true;
                        deck.position = jsonMoveData.decode();
                        /*
                        interpolateMove = SKAction.moveTo(jsonMoveData.decode(), duration: duration);
                        dispatch_async(dispatch_movement) {
                        self.deck.runAction(interpolateMove);
                        }
                        */
                    }
                    break;
                case "Player":
                    if let jsonMoveData = JSONPlayerMove.parseJSONData(jsonMovementData: data["moveData"]) as? JSONPlayerMove {
                        println(jsonMoveData.id);
                        for player in players {
                            if player.playerID == jsonMoveData.id {
                                println("Player Should Move");
                                player.userInteractionEnabled = true;
                                player.zPosition = 2;
                                player.position = jsonMoveData.decode();
                                /*
                                interpolateMove = SKAction.moveTo(jsonMoveData.decode(), duration: duration);
                                dispatch_async(dispatch_movement) {
                                player.runAction(interpolateMove);
                                }
                                */
                                break;
                            }
                        }
                    }
                    break;
                case "Pile":
                    if let jsonMoveData = JSONPileMove.parseJSONData(jsonMovementData: data["moveData"]) as? JSONPileMove {
                        println(jsonMoveData.id);
                        for pile in piles {
                            if pile.pileID == jsonMoveData.id {
                                println("Pile Should Move");
                                pile.userInteractionEnabled = true;
                                pile.zPosition = 2;
                                pile.position = jsonMoveData.decode();
                                /*
                                interpolateMove = SKAction.moveTo(jsonMoveData.decode(), duration: duration);
                                dispatch_async(dispatch_movement) {
                                pile.runAction(interpolateMove);
                                }
                                */
                                break;
                            }
                        }
                    }
                    break;
                default:
                    break;
                }
            }
        }
    }
    
    func handleMovementEnd(data: NSDictionary) {
        
        println("MovementDataEnded Recieved");
        
        if let cardType = data["cardType"] as? NSString {
            println(cardType);
            switch cardType {
            case "Deck":
                if let jsonMoveData = JSONDeckMove.parseJSONData(jsonMovementData: data["moveData"]) as? JSONDeckMove {
                    deck.userInteractionEnabled = false;
                    deck.zPosition = 1;
                    deck.position = jsonMoveData.decode();
                }
                break;
            case "Player":
                if let jsonMoveData = JSONPlayerMove.parseJSONData(jsonMovementData: data["moveData"]) as? JSONPlayerMove {
                    for player in players {
                        if player.playerID == jsonMoveData.id {
                            if player.isUser {
                                player.userInteractionEnabled = false;
                            }
                            player.zPosition = 1;
                            player.position = jsonMoveData.decode();
                            break;
                        }
                    }
                }
                break;
            case "Pile":
                if let jsonMoveData = JSONPileMove.parseJSONData(jsonMovementData: data["moveData"]) as? JSONPileMove {
                    for pile in piles {
                        if pile.pileID == jsonMoveData.id {
                            pile.userInteractionEnabled = false;
                            pile.zPosition = 1;
                            pile.position = jsonMoveData.decode();
                            break;
                        }
                    }
                }
                break;
            default:
                break;
            }
        }
    }
    
    func addPile(atPoint point: CGPoint) -> CardPile {
        var newPile = CardPile();
        
        newPile.position = point;
        newPile.placeholderCard.position = point;
        
        /*
        dispatch_async(networkDispatch) {
        self.vc.sendData(JSONPile(cardPile: newPile).toJson());
        }
        */
        
        piles.append(newPile);
        println("CardPile added to Scene");
        self.addChild(newPile);
        self.addChild(newPile.placeholderCard);
        
        return newPile;
    }
    
    func handleAddPile (data: NSDictionary) -> CardPile? {
        
        println("Pile data recieved");
        
        if let pileData = JSONPile.parseJSONData(jsonData: data) {
            println("Pile data parsed");
            let newPile = CardPile(jsonPileData: pileData);
            newPile.isBeingSent = true;
            newPile.pile.cards.removeAll(keepCapacity: true);
            ++CardPile.count;
            
            newPile.position = pileData.decode().0;
            newPile.placeholderCard.position = pileData.decode().0;
            
            piles.append(newPile);
            println("CardPile added to Scene");
            self.addChild(newPile);
            self.addChild(newPile.placeholderCard);
            
            return newPile;
        }
        
        return nil;
    }
    
    func launchCard(card: Card, withVector vector: CGVector) -> Bool {
        if let sender = self.selectedNode as? CardProtocol {
            let newPile = CardPile();
            newPile.tempCardCount = 1;
            newPile.userInteractionEnabled = true;
            
            var endPoint = CGPoint(x: self.selectedNode!.position.x + vector.dx, y: self.selectedNode!.position.y + vector.dy);
            
            if endPoint.x > CGRectGetMaxX(self.frame) {
                endPoint.x = CGRectGetMaxX(self.frame) - 1;
            }
            if endPoint.x < CGRectGetMinX(self.frame) {
                endPoint.x = CGRectGetMinX(self.frame) + 1;
            }
            if endPoint.y > CGRectGetMaxY(self.frame) {
                endPoint.y = CGRectGetMaxY(self.frame) - 1;
            }
            if endPoint.y < CGRectGetMinY(self.frame) {
                endPoint.y = CGRectGetMinY(self.frame) + 1;
            }
            
            newPile.placeholderCard.position = endPoint;
            newPile.zPosition = 2;
            newPile.position = self.selectedNode!.position;
            
            var validLaunch: Bool = false;
            var recievingCard: CardProtocol? = nil;
            var intersectsOtherPile: Bool = false;
            
            for player in players {
                if CGRectIntersectsRect(player.placeholderCard.frame, newPile.placeholderCard.frame) {
                    newPile.isBeingRecieved = true;
                    recievingCard = player;
                    break;
                }
            }
            if recievingCard == nil {
                for pile in piles {
                    if pile != newPile && !pile.isBeingRecieved && CGRectIntersectsRect(pile.placeholderCard.frame, newPile.placeholderCard.frame) {
                        newPile.isBeingRecieved = true;
                        recievingCard = pile;
                        break;
                    }
                }
            }
            
            println("Launch Reciever is: \(recievingCard?.placeholderCard)");
            
            /*REDESIGN ALL THIS VALIDITY CHECKING PLEASE*/
            
            
            if !(selectedNode is CardPile) {
                if !spaceOnField() {
                    if let reciever = recievingCard where reciever is Player && UInt(reciever.tempCardCount) < Rules.gameRules.maxCardsPerPlayer && reciever.spaceAvailable()  {
                        
                        ++(reciever as! Player).tempCardCount;
                        validLaunch = true;
                    }
                    
                    if !validLaunch {
                        return false;
                    }
                }
            }
            
            
            if !spaceForPilesOnField() && !validLaunch {
                
                if let reciever = recievingCard where (reciever is CardPile && UInt(reciever.tempCardCount) < Rules.gameRules.maxCardsPerPile && reciever.spaceAvailable()) {
                    
                    ++(reciever as! CardPile).tempCardCount;
                    validLaunch = true;
                }
                else if let reciever = recievingCard where (reciever is Player && UInt(reciever.tempCardCount) < Rules.gameRules.maxCardsPerPlayer && reciever.spaceAvailable()) {
                    ++(reciever as! Player).tempCardCount;
                    validLaunch = true;
                }
                
                if sender is CardPile && (sender as! CardPile).pile.cards.count <= 1 {
                    validLaunch = true;
                }
                
                if !validLaunch {
                    return false;
                }
            }
            
            if !validLaunch {
                if recievingCard == nil {
                    validLaunch = true;
                }
                else if let reciever = recievingCard where (reciever is CardPile && UInt(reciever.tempCardCount) < Rules.gameRules.maxCardsPerPile && reciever.spaceAvailable()) {
                    
                    ++(reciever as! CardPile).tempCardCount;
                    validLaunch = true;
                }
                else if let reciever = recievingCard where (reciever is Player && UInt(reciever.tempCardCount) < Rules.gameRules.maxCardsPerPlayer && reciever.spaceAvailable()) {
                    ++(reciever as! Player).tempCardCount;
                    validLaunch = true;
                }
                
                if !validLaunch {
                    return false;
                }
            }
            
            if selectedNode is Player && !(selectedNode as! Player).pilesAvailable() && recievingCard == nil {
                return false;
            }
            
            //GO INTO HAND SCENE TO CHANGE LAUNCH CARD, DON'T REMOVE CARD UNTIL LAUNCH VALIDATED **DONE**
            newPile.addCard(sender.removeCard(card));
            
            validLaunch = true;
            
            //println(JSONLaunchData(launchingPile: self.selectedNode as! CardProtocol, card: card, endPoint: newPile.placeholderCard.position).toJsonString());
            
            let launchAction = SKAction.moveTo(endPoint, duration: 1);
            
            self.piles.append(newPile);
            self.addChild(newPile);
            self.addChild(newPile.placeholderCard);
            
            var cardGiven: CardProtocol? = nil;
            
            newPile.isAnimating = true;
            dispatch_async(networkDispatch) {
                self.vc.sendData(JSONLaunchData(launchingPile: self.selectedNode as! CardProtocol, card: card, newPile: newPile, endPoint: newPile.placeholderCard.position).toJson());
            }
            newPile.runAction(launchAction, completion: { () -> Void in
                for player in self.players {
                    if CGRectIntersectsRect(player.placeholderCard.frame, newPile.frame) && player.spaceAvailable() {
                        let addCardAction = SKAction.moveTo(player.position, duration: 0.5);
                        
                        newPile.runAction(addCardAction, completion: { () -> Void in
                            
                            player.addCard(newPile.removeCard(card));
                            
                        })
                        return;
                    }
                }
                for pile in self.piles {
                    if CGRectIntersectsRect(pile.placeholderCard.frame, newPile.frame) && newPile != pile && !pile.isAnimating {
                        let addCardAction = SKAction.moveTo(pile.position, duration: 0.5);
                        newPile.runAction(addCardAction, completion: { () -> Void in
                            
                            pile.addCard(newPile.removeCard(card));
                        })
                        return;
                    }
                }
                newPile.isAnimating = false;
                newPile.zPosition = 1;
                newPile.userInteractionEnabled = false;
                
                if self.selectedNode is Player {
                    newPile.setPlayer(self.selectedNode as! Player);
                }
            })
            
            if !newPile.isEmpty() {
                var cards = self.selectedNode as! CardProtocol;
                cards.updateTexture();
            }
            
            return true;
        }
        
        return false;
    }
    
    func handleLaunchCard(data: NSDictionary) {
        
        println("LaunchCard Signal Recieved");
        if let launchData = JSONLaunchData.parseJSONData(data) {
            println("Data Parsed Successfully");
            println(launchData.cardData.type)
            var launchedCard: SKSpriteNode!;
            if launchData.cardData.type == "Deck" {
                launchedCard = self.deck;
            }
            else if launchData.cardData.type == "Player" {
                for player in self.players {
                    if launchData.cardData.id == player.playerID {
                        launchedCard = player;
                        break;
                    }
                }
            }
            else {
                for pile in self.piles {
                    if launchData.cardData.id == pile.pileID {
                        launchedCard = pile;
                        break;
                    }
                }
            }
            
            let decoded = launchData.decode();
            
            let newPile = CardPile(jsonPileData: launchData.newPile);
            newPile.pile.cards.removeAll(keepCapacity: true);
            newPile.userInteractionEnabled = true;
            (launchedCard as! CardProtocol).removeCard(decoded.0);
            newPile.addCard(decoded.0);
            
            newPile.placeholderCard.position = decoded.1;
            newPile.zPosition = 2;
            newPile.position = launchedCard.position;
            
            let launchAction = SKAction.moveTo(newPile.placeholderCard.position, duration: 1);
            
            self.piles.append(newPile);
            self.addChild(newPile);
            self.addChild(newPile.placeholderCard);
            
            
            newPile.isAnimating = true;
            newPile.runAction(launchAction, completion: { () -> Void in
                /*
                println("Launch Data Reciever: \(launchData.reciever?.toJsonString())");
                if launchData.reciever != nil {
                println("Launch Data reciever was not nil");
                var recievedPile: CardProtocol?;
                if launchData.reciever!.type == "Player" {
                for player in self.players {
                if launchData.reciever!.id == player.playerID {
                recievedPile = player;
                break;
                }
                }
                }
                else {
                for pile in self.piles {
                if launchData.reciever!.id == pile.pileID {
                recievedPile = pile;
                break;
                }
                }
                }
                if recievedPile != nil {
                let addCardAction = SKAction.moveTo(recievedPile!.placeholderCard.position, duration: 0.5);
                
                newPile.runAction(addCardAction, completion: { () -> Void in
                recievedPile!.addCard(newPile.removeCard(decoded.0));
                newPile.removeFromParent();
                newPile.placeholderCard.removeFromParent();
                for i in 0..<self.piles.count {
                if self.piles[i] == newPile {
                self.piles.removeAtIndex(i);
                break;
                }
                }
                })
                }
                }
                */
                
                for player in self.players {
                    if CGRectIntersectsRect(player.frame, newPile.frame) {
                        let addCardAction = SKAction.moveTo(player.position, duration: 0.5);
                        
                        newPile.runAction(addCardAction, completion: { () -> Void in
                            player.addCard(newPile.removeCard(decoded.0));
                            newPile.removeFromParent();
                            newPile.placeholderCard.removeFromParent();
                            for i in 0..<self.piles.count {
                                if self.piles[i] == newPile {
                                    self.piles.removeAtIndex(i);
                                    break;
                                }
                            }
                        })
                        return;
                    }
                }
                for pile in self.piles {
                    if CGRectIntersectsRect(pile.frame, newPile.frame) && newPile != pile && !pile.isAnimating {
                        let addCardAction = SKAction.moveTo(pile.position, duration: 0.5);
                        newPile.runAction(addCardAction, completion: { () -> Void in
                            pile.addCard(newPile.removeCard(decoded.0));
                            newPile.removeFromParent();
                            newPile.placeholderCard.removeFromParent();
                            for i in 0..<self.piles.count {
                                if self.piles[i] == newPile {
                                    self.piles.removeAtIndex(i);
                                    break;
                                }
                            }
                        })
                        return;
                    }
                }
                newPile.isAnimating = false;
                newPile.zPosition = 1;
                newPile.userInteractionEnabled = false;
                
                if launchedCard is Player {
                    newPile.setPlayer(launchedCard as! Player);
                }
                
            })
            
            (launchedCard as! CardProtocol).updateTexture();
        }
    }
    
    func updateCards() {
        for child in self.children {
            if child is CardProtocol {
                (child as! CardProtocol).updateTexture();
            }
        }
    }
    
    func addPlayer(peerID: MCPeerID) {
        let newPlayer = Player(peerID: peerID);
        
        let midX: CGFloat = CGRectGetMidX(self.frame);
        let leftX: CGFloat = midX - 150;
        let rightX: CGFloat = midX + 150;
        let midY: CGFloat = CGRectGetMidY(self.frame)
        let topY: CGFloat = midY + 250;
        let botY: CGFloat = midY - 250;
        
        switch players.count {
        case 0:
            newPlayer.position = CGPoint(x: midX, y: topY);
            break;
        case 1:
            newPlayer.position = CGPoint(x: midX, y: botY);
            break;
        case 2:
            newPlayer.position = CGPoint(x: rightX, y: midY);
            break;
        case 3:
            newPlayer.position = CGPoint(x: leftX, y: midY);
            break;
        case 4:
            newPlayer.position = CGPoint(x: rightX, y: topY);
            break;
        case 5:
            newPlayer.position = CGPoint(x: leftX, y: botY);
            break;
        case 6:
            newPlayer.position = CGPoint(x: leftX, y: topY);
            break;
        case 7:
            newPlayer.position = CGPoint(x: rightX, y: botY);
        default:
            println("Too many Players, can't add more");
            break;
        }
        
        newPlayer.placeholderCard.position = newPlayer.position;
        newPlayer.playerName.position = CGPoint(x: newPlayer.placeholderCard.position.x, y: newPlayer.placeholderCard.position.y + newPlayer.placeholderCard.size.height / 2);
        
        println("Player zRotation: \(newPlayer.zRotation)");
        
        players.append(newPlayer);
        
        self.addChild(newPlayer);
        self.addChild(newPlayer.placeholderCard);
        self.addChild(newPlayer.playerName);
    }
    
    func removePlayer(peerID: MCPeerID) {
        
        for (index, player) in enumerate(players) {
            if player.peerID == peerID {
                player.removeFromParent();
                player.placeholderCard.removeFromParent();
                player.playerName.removeFromParent();
                players.removeAtIndex(index);
            }
        }
    }
    
    func getBoardStateAsNSData() -> NSData? {
        
        
        let boardData = JSONBoardState(deck: deck, players: players, piles: piles);
        println(boardData.toJsonString());
        let data = boardData.toJson();
        
        return data;
    }
    
    func setBoardWithBoardState(boardState: NSDictionary) -> Bool {
        clearBoard();
        
        if let rules = JSONRules.parseJSONData(jsonData: boardState.objectForKey("rules")) {
            Rules.gameRules.setRulesFromJSON(rules);
        }
        if let maxPlayers = boardState.objectForKey("maxPlayers") as? Int {
            Player.count = maxPlayers;
        }
        if let maxPiles = boardState.objectForKey("maxPiles") as? Int {
            CardPile.count = maxPiles;
        }
        
        //Set deck cards
        if let jsonDeck = JSONDeck.parseJSONData(jsonData: boardState.objectForKey("deck")) {
            
            deck.cards = jsonDeck.decode();
            
            self.addChild(deck);
            self.addChild(deck.placeholderCard);
        }
        
        //Add players
        if let jsonPlayersArray = boardState.objectForKey("players") as? NSArray {
            for player in jsonPlayersArray {
                if let jsonPlayer = JSONPlayer.parseJSONData(jsonData: player) {
                    let aPlayer = Player(jsonPlayerData: jsonPlayer)
                    
                    let position = jsonPlayer.decode().0;
                    aPlayer.position = position;
                    aPlayer.placeholderCard.position = position;
                    aPlayer.playerName.position = CGPoint(x: aPlayer.placeholderCard.position.x, y: aPlayer.placeholderCard.position.y + aPlayer.placeholderCard.size.height / 2);
                    
                    
                    players.append(aPlayer);
                    self.addChild(aPlayer);
                    self.addChild(aPlayer.placeholderCard);
                    self.addChild(aPlayer.playerName);
                }
            }
        }
        
        //Add piles
        if let jsonPilesArray = boardState.objectForKey("piles") as? NSArray {
            for pile in jsonPilesArray {
                if let jsonPile = JSONPile.parseJSONData(jsonData: pile) {
                    let aPile = CardPile(jsonPileData: jsonPile);
                    
                    let decoded = jsonPile.decode();
                    
                    aPile.position = decoded.0;
                    aPile.placeholderCard.position = decoded.0;
                    
                    piles.append(aPile);
                    self.addChild(aPile);
                    self.addChild(aPile.placeholderCard);
                }
            }
        }
        
        updateCards();
        
        return true;
    }
    
    func clearBoard() {
        for child in self.children {
            child.removeFromParent();
        }
        
        players.removeAll(keepCapacity: true);
        piles.removeAll(keepCapacity: true);
    }
    
    func shuffleDeck() {
        self.deck.shuffleDeck();
        
        dispatch_async(networkDispatch) {
            self.vc.sendData(JSONDeckShuffled(deck: self.deck).toJson())
        }
    }
    
    func handleShuffleDeck(data: NSDictionary) {
        if let deckData = JSONDeck.parseJSONData(jsonData: data["deck"]) {
            self.deck.cards = deckData.decode();
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        for (index, pile) in enumerate(piles) {
            if pile.isEmpty() && !pile.isBeingSent {
                if index < piles.count {
                    pile.removeFromParent();
                    pile.placeholderCard.removeFromParent();
                    piles.removeAtIndex(index);
                }
            }
        }
    }
}
