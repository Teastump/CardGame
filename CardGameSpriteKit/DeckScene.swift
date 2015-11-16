//
//  DeckScene.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/18/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit

class DeckScene: HandScene {
    
    override init(size: CGSize, viewController: HandViewController) {
        super.init(size: size, viewController: viewController);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupPortrait() {
        
        for child in self.children {
            (child as! SKNode).removeFromParent();
        }
        
        center = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        for (index, card) in enumerate(vc.deck!.cards) {
            let aCard = CardSprite(card: card, displayValue: false);
            aCard.position = center;
            aCard.zPosition = CGFloat(index);
            aCard.name = "Card\(index)";
            self.addChild(aCard);
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
            
            selectedNode = nil;
            
            vc.gameScene.updateCards();
            
            vc.backToBoard();
            
            vc = nil;
            
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
                let swipeAwayCard = SKAction.moveBy(CGVector(dx: dx * 10, dy: dy * 10), duration: 1);
                
                
                if selectedNode != nil {
                    if self.vc.gameScene.launchCard(selectedNode!.card, withVector: vector) {
                        selectedNode!.runAction(SKAction.sequence([swipeAwayCard, SKAction.removeFromParent()]))
                        selectedNode = nil;
                    }
                }
            }
        }
        
        let moveBackToCenter = SKAction.moveTo(center, duration: 0.5);
        moveBackToCenter.timingMode = .EaseOut;
        
        if selectedNode != nil {
            selectedNode!.runAction(moveBackToCenter);
        }
        
    }
    
    func shuffleDeck() {
        setupPortrait();
    }
}