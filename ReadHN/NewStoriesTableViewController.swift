//
//  StoriesTableTableViewController.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/8/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import UIKit

class NewStoriesTableViewController: StoriesTableViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    
    private func updateUI() {
        super.categoryUrl = "https://hacker-news.firebaseio.com/v0/newstories.json"
        super.brain.delegate = self
        super.refresh()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            println(identifier)
            switch identifier {
            case "View New Content":
                if let wvc = segue.destinationViewController as? WebViewController {
                    if let cell = sender as? UITableViewCell {
                        wvc.pageTitle = cell.textLabel?.text
                        
                        if let cellIndexPath = self.tableView.indexPathForCell(cell) {
                            let data = Submission.loadSaved(storyTableCellData[cellIndexPath.row] ?? 0)
                            wvc.pageUrl = data?.url
                        }
                    }
                }
            default: break
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("View New Content", sender: self)
    }
    
}
