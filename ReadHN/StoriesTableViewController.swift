//
//  StoriesTableViewController.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/7/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import UIKit

class StoriesTableViewController: UITableViewController, StoryCategoryDelegate {
    
    var storyTableCellData: [Int: Int] = [Int:Int]() // key - rowIndex, val - id
    var numberStories = 20
    var categoryUrl: String = "https://hacker-news.firebaseio.com/v0/topstories.json"
    var brain = HackerNewsBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.layoutMargins = UIEdgeInsetsZero
        //tableView.estimatedRowHeight = tableView.rowHeight
        //tableView.rowHeight = UITableViewAutomaticDimension
        initDelegate(categoryUrl)
        initRefreshControl()
        refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    // refreshes the table view
    func refresh() {
        tableView.reloadData()
        self.tableView.layoutMargins = UIEdgeInsetsZero
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        brain.startConnection() {
            for i in 0..<self.brain.submissionIDs.count {
                if i < self.numberStories {
                    let id = self.brain.submissionIDs[i]
                    self.storyTableCellData[i] = id
                    self.brain.generateSubmissionForID(id) {
                        if i == self.numberStories - 1 {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.reformatCells()
                            })
                        }
                    }
                } else { break }
            }
        }
        refreshControl?.endRefreshing()
    }
    
    // sets up the pull-down to refresh control -- used only in viewDidLoad()
    func initRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func initDelegate(url: String) {
        categoryUrl = url
        brain.delegate = self
    }
    
    // MARK: - format cell funcs
    
    func refreshCell(row: Int) {
        let indexPath = NSIndexPath(forRow: row, inSection: 0)
        
        if isCellVisible(row) {
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            tableView.endUpdates()
        }
    }
    
    func isCellVisible(index: Int) -> Bool {
        let visibleRows = tableView.indexPathsForVisibleRows()
        
        if let indices = visibleRows as? [NSIndexPath] {
            for rowIndex in indices {
                if rowIndex.row == index {
                    return true
                }
            }
        }
        return false
    }
    
    // formats a cell's title and subtitle at a given row
    private func generateHeadingsforID(id: Int) -> (title: String?, subtitle: String?){
        if let s = Submission.loadSaved(id) {
            return (s.title, "\(s.score ?? -1) points | by \(s.by) | \(formatURL(s.url))")
        }
        return (nil, nil)
    }
    
    private func formatURL(url: String) -> String {
        return NSURL(string: url)?.host ?? ""
    }
    
    private func reformatCells() {
        for i in 0..<numberStories {
            refreshCell(i)
        }
    }
    
    // MARK: - tableView funcs
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80.0)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return numberStories
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dequeued: AnyObject = tableView.dequeueReusableCellWithIdentifier("storyCell", forIndexPath: indexPath)
        let cell = dequeued as! UITableViewCell
        // get the id associated with the row
        // pull the title and subtitle from the id
        // and format cell
        
        let headings = generateHeadingsforID(storyTableCellData[indexPath.row] ?? 0)

        if let title = headings.title, subtitle = headings.subtitle {
            cell.textLabel?.text = title
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(CGFloat(16.0))
            cell.detailTextLabel?.text = subtitle
        } else {
            cell.textLabel?.text = "Loading..."
            cell.detailTextLabel?.text = "Loading..."
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("View Content", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "View Content":
                if let wvc = segue.destinationViewController as? WebViewController {
                    if let cell = sender as? UITableViewCell {
                        wvc.pageTitle = cell.textLabel?.text
                        
                        if let cellIndexPath = self.tableView.indexPathForCell(cell) {
                            if let data = Submission.loadSaved(storyTableCellData[cellIndexPath.row] ?? 0){
                                wvc.pageUrl = data.url
                            }
                        }
                    }
                }
            default: break
            }
        }
    }
}
