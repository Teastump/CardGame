//
//  HandScene.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/6/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import SpriteKit
import Darwin

func degToRad(degrees: CGFloat) -> CGFloat {
    return degrees * CGFloat(M_PI) / 180;
}

func getPosition(magnitude: CGFloat, angleInRads angle: CGFloat) -> CGVector {
    let dx = sin(angle) * magnitude;
    let dy = cos(angle) * magnitude;
    
    return CGVector(dx: dx, dy: dy);
}

class HandScene: SKScene {
    var vc: HandViewController!
    var selectedNode: CardSprite?
    var start: CGPoint!;
    var startTime: NSTimeInterval!;
    var center: CGPoint!;
    var device = UIDevice.currentDevice();
    var landscape: Bool = false;
    var landscapePositions: [CGPoint] = [];
    
    init(size: CGSize, viewController: HandViewController) {
        
        self.vc = viewController;
        self.landscape = false;
        
        super.init(size: size);
        
        self.userInteractionEnabled = true;

        setupPortrait();
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch;
        
        for node in self.nodesAtPoint(touch.locationInNode(self)) {
            if selectedNode == nil {
                selectedNode = (node as! CardSprite);
            }
            else if node.zPosition > selectedNode!.zPosition {
                selectedNode = (node as! CardSprite);
            }
        }
        
        if landscape {
            getLandscapePositions();
        }
        
        start = touch.locationInNode(self);
        startTime = touch.timestamp;
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch = touches.first as! UITouch;
        
        if landscape {
            touchesMovedLandscape(touch);
        }
        else {
            touchesMovedPortrait(touch);
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
                        selectedNode!.runAction(SKAction.sequence([swipeAwayCard, SKAction.removeFromParent()]), completion: { () -> Void in
                            if self.landscape {
                                self.setupLandscape();
                            }
                        })
                        selectedNode = nil;
                    }
                }
            }
        }
        
        if landscape {
            touchesEndedLandscape(touch);
        }
        else {
            touchesEndedPortrait(touch);
        }
        
    }
    
    func panSprite(translation: CGPoint) {
        if let position = selectedNode?.position {
            selectedNode!.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y);
        }
    }
    
    func orientationChanged(note: NSNotification) {
        let device = note.object as! UIDevice;
        println("Device Orientation Changed!");
        
        if device.orientation == .LandscapeLeft || device.orientation == .LandscapeRight {
            println("Landscape!");
            landscape = true;
            setupLandscape();
        }
        else if device.orientation == .Portrait {
            println("Portrait!");
            landscape = false;
            setupPortrait();
        }
    }
    
    func setupPortrait() {
        
        for child in self.children {
            (child as! SKNode).removeFromParent();
        }
        
        center = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame));
        for (index, card) in enumerate(vc.hand.cards) {
            let aCard = CardSprite(card: card);
            aCard.position = center;
            aCard.zPosition = CGFloat(index);
            aCard.name = "Card\(index)";
            self.addChild(aCard);
        }
    }
    
    func setupLandscape() {
        
        if selectedNode == nil {
            for child in self.children {
                (child as! SKNode).removeFromParent();
            }
            
            center = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMinY(self.frame));
            let angleConstraint = SKConstraint.orientToPoint(center, offset: SKRange(constantValue: degToRad(90)));
            let constraint = NSArray(object: angleConstraint);
            
            let positions: [CGPoint] = getLandscapePositions()!;
            
            for (index, card) in enumerate(vc.hand.cards) {
                let aCard = CardSprite(card: card);
                aCard.constraints = constraint as [AnyObject];
                aCard.position = positions[index];
                aCard.zPosition = CGFloat(index);
                aCard.name = "Card\(index)";
                self.addChild(aCard);
            }
        }
    }
    
    func getLandscapePositions() -> [CGPoint]? {
        if landscape {
            landscapePositions.removeAll(keepCapacity: true);
            
            let radianOffset = degToRad(5);
            let vectorMagnitude: CGFloat = CGRectGetMidY(self.frame) - CGRectGetMinY(self.frame);
            let half: CGFloat = floor(CGFloat(vc.hand.cards.count) / 2);
            let startAngle: CGFloat;
            
            if !vc.hand.cards.isEmpty {
                if vc.hand.cards.count % 2 == 0 {
                    startAngle = degToRad(-((5 * (half - 1)) + 2.5));
                    
                    for num in 0...(vc.hand.cards.count - 1) {
                        let rotation = startAngle + (radianOffset * CGFloat(num));
                        let positionVector = getPosition(vectorMagnitude, angleInRads: rotation);
                        landscapePositions.append(CGPoint(x: center.x + positionVector.dx, y: center.y + positionVector.dy));
                    }
                }
                else {
                    startAngle = degToRad(-(5 * half));
                    
                    for num in 0...(vc.hand.cards.count - 1) {
                        let rotation = startAngle + (radianOffset * CGFloat(num));
                        let positionVector = getPosition(vectorMagnitude, angleInRads: rotation);
                        landscapePositions.append(CGPoint(x: center.x + positionVector.dx, y: center.y + positionVector.dy));
                    }
                }
            }
            
            return landscapePositions;
        }
        else {
            return nil;
        }
    }
    
    private func touchesMovedPortrait(touch: UITouch) {
        if selectedNode != nil {
            var position = touch.locationInNode(self);
            var previousPosition = touch.previousLocationInNode(self);
            var translation = CGPoint(x: position.x - previousPosition.x, y: position.y - previousPosition.y);
            
            self.panSprite(translation);
        }
    }
    
    private func touchesEndedPortrait(touch: UITouch) {
        
        let moveBackToCenter = SKAction.moveTo(center, duration: 0.5);
        moveBackToCenter.timingMode = .EaseOut;
        
        if selectedNode != nil {
            vc.hand.cards.insert(vc.hand.cards.removeLast(), atIndex: 0)
            selectedNode!.runAction(moveBackToCenter);
            selectedNode!.zPosition = 0;
            for card in self.children {
                ++(card as! CardSprite).zPosition;
            }
            selectedNode = nil;
        }
    }
    
    private func touchesMovedLandscape(touch: UITouch) {
        if selectedNode != nil {
            let position = touch.locationInNode(self);
            let previousPosition = touch.previousLocationInNode(self);
            let translation = CGPoint(x: position.x - previousPosition.x, y: position.y - previousPosition.y);
            
            self.panSprite(translation);
            
            var left: CardSprite?
            var right: CardSprite?
            var selectedIndex: Int!;
            
            for (index, card) in enumerate(vc.hand.cards) {
                if selectedNode!.card == card{
                    left = (self.childNodeWithName("Card\(index - 1)") as? CardSprite);
                    right = (self.childNodeWithName("Card\(index + 1)") as? CardSprite);
                    
                    selectedIndex = index;
                    break;
                }
            }
            
            if selectedIndex < landscapePositions.count {
                let moveAction = SKAction.moveTo(landscapePositions[selectedIndex], duration: 0.5);
            
            
            if left != nil && selectedNode!.position.x < left?.position.x {
                vc.hand.cards.insert(vc.hand.cards.removeAtIndex(selectedIndex), atIndex: selectedIndex - 1);
                
                selectedNode!.name = "Card\(selectedIndex - 1)";
                --selectedNode!.zPosition;
                left!.name = "Card\(selectedIndex)";
                ++left!.zPosition;
                
                left!.runAction(moveAction);
            }
            if right != nil && selectedNode!.position.x > right?.position.x {
                
                vc.hand.cards.insert(vc.hand.cards.removeAtIndex(selectedIndex), atIndex: selectedIndex + 1);
                
                selectedNode!.name = "Card\(selectedIndex + 1)";
                ++selectedNode!.zPosition;
                right!.name = "Card\(selectedIndex)";
                --right!.zPosition;
                
                right!.runAction(moveAction);
            }
            }
        }
        
    }
    
    private func touchesEndedLandscape(touch: UITouch) {
        
        if selectedNode != nil {
            var selectedIndex: Int!
            for (index, card) in enumerate(vc.hand.cards) {
                if selectedNode!.card == card {
                    selectedIndex = index;
                    break;
                }
            }
            
            let moveBackToPosition = SKAction.moveTo(landscapePositions[selectedIndex], duration: 0.5);
            moveBackToPosition.timingMode = .EaseOut;
            
            selectedNode!.runAction(moveBackToPosition);
            selectedNode = nil;
        }
    }
}
