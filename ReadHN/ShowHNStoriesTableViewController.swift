//
//  ShowHNStoriesTableTableViewController.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/8/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import UIKit

class ShowHNStoriesTableViewContoller: StoriesTableViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        super.categoryUrl = "https://hacker-news.firebaseio.com/v0/showstories.json"
        super.brain.delegate = self
        super.refresh()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "View ShowHN Content":
                if let wvc = segue.destinationViewController as? WebViewController {
                    if let cell = sender as? UITableViewCell {
                        wvc.pageTitle = cell.textLabel?.text
                        
                        if let cellIndexPath = self.tableView.indexPathForCell(cell) {
                            if let cellUrl = defaults.objectForKey("\(cellIndexPath.row).url") as? String {
                                wvc.pageUrl = cellUrl
                                println(cellUrl)
                            }
                            
                            if cellIndexPath.row == self.numberStories - 1 {
                                numberStories += 20
                                refresh()
                            }
                        }
                    }
                }
            default: break
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("View ShowHN Content", sender: self)
    }
}
