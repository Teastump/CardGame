//
//  RotationController.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/12/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import Foundation
import UIKit

class RotationController: UINavigationController {
    var autorotate: Bool = true;
    var supportedOrientations: Int = Int(UIInterfaceOrientationMask.Portrait.rawValue);
    override func shouldAutorotate() -> Bool {
        return autorotate;
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return supportedOrientations;
    }
}