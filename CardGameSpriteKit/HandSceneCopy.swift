//
//  HandSceneCopy.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/12/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation

//
//  HandScene.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/6/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit

class HandSceneCopy: SKSpriteNode {
    private var hand: Hand;
    private let gameScene: GameScene
    private var selectedNode: SKNode?
    private var start: CGPoint!;
    private var startTime: NSTimeInterval!;
    private var center: CGPoint!;
    
    init(size: CGSize, hand: Hand, gameScene: GameScene) {
        self.hand = hand;
        self.gameScene = gameScene;
        
        super.init(texture: whiteTexture, color: UIColor.clearColor(), size: gameScene.size);
        
        self.zPosition = 3;
        self.userInteractionEnabled = true;
        
        self.center = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        
        for (index, card) in enumerate(hand.cards) {
            let aCard = CardSprite(card: card);
            aCard.position = center;
            aCard.zPosition = CGFloat(index) + self.zPosition;
            self.addChild(aCard);
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch;
        
        for node in self.nodesAtPoint(touch.locationInNode(self)) {
            if selectedNode == nil {
                selectedNode = (node as! SKNode);
            }
            else if node.zPosition > selectedNode!.zPosition {
                selectedNode = (node as! SKNode);
            }
        }
        
        start = touch.locationInNode(self);
        startTime = touch.timestamp;
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch;
        
        if selectedNode != nil {
            var position = touch.locationInNode(self);
            var previousPosition = touch.previousLocationInNode(self);
            var translation = CGPoint(x: position.x - previousPosition.x, y: position.y - previousPosition.y);
            
            self.panSprite(translation);
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch;
        let location = touch.locationInNode(self);
        let time = touch.timestamp;
        
        if touch.tapCount == 2 {
            for child in self.children {
                (child as! SKNode).removeFromParent();
            }
            self.parent!.userInteractionEnabled = true;
            self.removeFromParent();
            
            selectedNode = nil;
            
            return;
        }
        
        let dx = location.x - start.x;
        let dy = location.y - start.y;
        let magnitude = sqrt((dx*dx) + (dy*dy));
        
        if magnitude >= 25 {
            let dt: CGFloat = CGFloat(time - startTime);
            if dt < 0.25 {
                let speed = magnitude / dt;
                let vector = CGVector(dx: dx, dy: dy);
                let swipeAwayCard = SKAction.moveBy(CGVector(dx: dx * 10, dy: dy * 10), duration: 1)
                
                if selectedNode != nil {
                    selectedNode!.runAction(SKAction.sequence([swipeAwayCard, SKAction.removeFromParent()]));
                    if let removedCard = hand.removeCard((selectedNode as! CardSprite).card) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.gameScene.launchCard(removedCard, withVector: vector);
                        }
                    }
                    selectedNode = nil;
                }
            }
        }
        
        let moveBackToCenter = SKAction.moveTo(center, duration: 0.5);
        moveBackToCenter.timingMode = .EaseOut;
        
        if selectedNode != nil {
            hand.cards.insert(hand.cards.removeLast(), atIndex: 0)
            selectedNode!.runAction(moveBackToCenter);
            selectedNode!.zPosition = 3;
            for card in self.children {
                ++(card as! CardSprite).zPosition;
            }
            selectedNode = nil;
        }
    }
    
    func panSprite(translation: CGPoint) {
        if let position = selectedNode?.position {
            selectedNode!.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y);
        }
    }
}
