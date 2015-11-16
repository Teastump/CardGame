//
//  PlayerSettingsViewController.swift
//  CardGameSpriteKit
//
//  Created by Daniel Seitz on 6/23/15.
//  Copyright (c) 2015 Daniel Seitz. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    /* Player Settings Outlets */
    @IBOutlet weak var playerMaxCardsStepper: UIStepper!
    @IBOutlet weak var playerMaxCardsLabel: UILabel!

    @IBOutlet weak var maxPlayerPilesStepper: UIStepper!
    @IBOutlet weak var playerMaxPilesLabel: UILabel!
    
    @IBOutlet weak var playerHandHiddenLabel: UILabel!
    @IBOutlet weak var playerHandInteractLabel: UILabel!
    /* Player Settings Outlets */
    
    /* Pile Settings Outlets */
    @IBOutlet weak var pileMaxCardsStepper: UIStepper!
    @IBOutlet weak var pileMaxCardsLabel: UILabel!
    
    @IBOutlet weak var pileHiddenLabel: UILabel!
    @IBOutlet weak var pileInteractLabel: UILabel!
    /* Pile Settings Outlets */
    
    /* Board Settings Outlets */
    @IBOutlet weak var boardMaxCardsStepper: UIStepper!
    @IBOutlet weak var boardMaxCardsLabel: UILabel!
    
    @IBOutlet weak var boardMaxPilesStepper: UIStepper!
    @IBOutlet weak var boardMaxPilesLabel: UILabel!
    
    @IBOutlet weak var boardDecksUsedStepper: UIStepper!
    @IBOutlet weak var boardDecksUsedLabel: UILabel!
    
    @IBOutlet weak var boardDeckShuffledLabel: UILabel!
    /* Board Settings Outlets */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTable();

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func setupTable() {
        let maxCards = Double(Rules.gameRules.numDecksUsed * 52);
        
        /*Player*/
        playerMaxCardsStepper.maximumValue = maxCards;
        playerMaxCardsStepper.value = Double(Rules.gameRules.maxCardsPerPlayer);
        updateMaxLabel(playerMaxCardsLabel, withNum: Int(playerMaxCardsStepper.value));
        
        maxPlayerPilesStepper.maximumValue = maxCards;
        maxPlayerPilesStepper.value = Double(Rules.gameRules.maxPilesPerPlayer);
        updateMaxLabel(playerMaxPilesLabel, withNum: Int(maxPlayerPilesStepper.value));
        
        playerHandHiddenLabel.text = "\(Rules.gameRules.playerHandHidden)".capitalizedString;
        playerHandInteractLabel.text = "\(Rules.gameRules.playerHandInteractable)".capitalizedString;
        
        /*Pile*/
        pileMaxCardsStepper.maximumValue = maxCards;
        pileMaxCardsStepper.value = Double(Rules.gameRules.maxCardsPerPile);
        updateMaxLabel(pileMaxCardsLabel, withNum: Int(pileMaxCardsStepper.value));
        
        pileHiddenLabel.text = "\(Rules.gameRules.playerPilesHidden)".capitalizedString;
        pileInteractLabel.text = "\(Rules.gameRules.playerPilesInteractable)".capitalizedString;
        
        /*Board*/
        boardMaxCardsStepper.maximumValue = maxCards;
        boardMaxCardsStepper.value = Double(Rules.gameRules.maxCardsOnField);
        updateMaxLabel(boardMaxCardsLabel, withNum: Int(boardMaxCardsStepper.value));
        
        if boardMaxCardsStepper.value == 0 {
            boardMaxPilesStepper.maximumValue = maxCards;
        }
        else {
            boardMaxPilesStepper.maximumValue = boardMaxCardsStepper.value;
        }
        boardMaxPilesStepper.value = Double(Rules.gameRules.maxPilesOnField);
        updateMaxLabel(boardMaxPilesLabel, withNum: Int(boardMaxPilesStepper.value));
        
        boardDecksUsedStepper.maximumValue = 4;
        boardDecksUsedStepper.value = Double(Rules.gameRules.numDecksUsed);
        updateMaxLabel(boardDecksUsedLabel, withNum: Int(boardDecksUsedStepper.value));
        
        boardDeckShuffledLabel.text = "\(Rules.gameRules.deckStartsShuffled)".capitalizedString;
    }
    
    func updateMaxLabel(label: UILabel, withNum num: Int) {
        if num == 0 {
            label.text = "No Limit";
        }
        else {
            label.text = "\(num)";
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 { return 4; }
        if section == 1 { return 3; }
        if section == 2 { return 4; }
        
        return 0;
    }
    
    @IBAction func maxCardsIncremented(sender: UIStepper) {
        switch sender.tag {
        case 0:
            Rules.gameRules.maxCardsPerPlayer = UInt(sender.value);
            updateMaxLabel(playerMaxCardsLabel, withNum: Int(sender.value));
            break;
        case 1:
            Rules.gameRules.maxCardsPerPile = UInt(sender.value);
            updateMaxLabel(pileMaxCardsLabel, withNum: Int(sender.value));
            break;
        case 2:
            Rules.gameRules.maxCardsOnField = UInt(sender.value);
            updateMaxLabel(boardMaxCardsLabel, withNum: Int(sender.value));
            boardMaxPilesStepper.maximumValue = boardMaxCardsStepper.value;
            updateMaxLabel(boardMaxPilesLabel, withNum: Int(boardMaxPilesStepper.value));
        default:
            break;
        }
        
    }
    
    @IBAction func maxPilesIncremented(sender: UIStepper) {
        switch sender.tag {
        case 0:
            Rules.gameRules.maxPilesPerPlayer = UInt(sender.value);
            updateMaxLabel(playerMaxPilesLabel, withNum: Int(sender.value));
            break;
        case 1:
            Rules.gameRules.maxPilesOnField = UInt(sender.value);
            updateMaxLabel(boardMaxPilesLabel, withNum: Int(sender.value));
            break;
        default:
            break;
        }
    }
    
    @IBAction func numDecksIncremented(sender: UIStepper) {
        Rules.gameRules.numDecksUsed = UInt(sender.value);
        updateMaxLabel(boardDecksUsedLabel, withNum: Int(sender.value));
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 2:
                let rule = !Rules.gameRules.playerHandHidden
                Rules.gameRules.playerHandHidden = rule;
                playerHandHiddenLabel.text = "\(rule)".capitalizedString;
                break;
            case 3:
                let rule = !Rules.gameRules.playerHandInteractable;
                Rules.gameRules.playerHandInteractable = rule;
                playerHandInteractLabel.text = "\(rule)".capitalizedString;
                break;
            default:
                break;
            }
        case 1:
            switch indexPath.row {
            case 1:
                let rule = !Rules.gameRules.playerPilesHidden;
                Rules.gameRules.playerPilesHidden = rule;
                pileHiddenLabel.text = "\(rule)".capitalizedString;
                break;
            case 2:
                let rule = !Rules.gameRules.playerPilesInteractable;
                Rules.gameRules.playerPilesInteractable = rule;
                pileInteractLabel.text = "\(rule)".capitalizedString;
                break;
            default:
                break;
            }
        case 2:
            switch indexPath.row {
            case 3:
                let rule = !Rules.gameRules.deckStartsShuffled;
                Rules.gameRules.playerPilesInteractable = rule;
                boardDeckShuffledLabel.text = "\(rule)".capitalizedString;
                break;
            default:
                break;
            }
        default:
            break;
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
