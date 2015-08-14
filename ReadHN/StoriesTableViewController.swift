//
//  StoriesTableViewController.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/7/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import UIKit

class StoriesTableViewController: UITableViewController, StoryCategoryDelegate {

    struct Key {
        static let sID: String = "submissionids.array"
    }
    
    struct StoryContents {
        var title: String
        var subtitle: String
    }
    
    var storyTableCellData = [StoryContents?](count: 20, repeatedValue: nil)
    var numberStories = 20
    let defaults = NSUserDefaults.standardUserDefaults()
    var categoryUrl = ""
    
    
    var brain = HackerNewsBrain()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.layoutMargins = UIEdgeInsetsZero
        initDelegate("https://hacker-news.firebaseio.com/v0/topstories.json")
        initRefreshControl()
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        refresh()
    }
    // refreshes the table view
    func refresh() {
        tableView.reloadData()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        println("\(numberStories)")
        brain.startConnection() {
            let storyIDs = self.defaults.objectForKey(Key.sID) as? [Int] ?? []
            println("\(storyIDs.count)")
            if storyIDs.count > 0{
                var count = self.numberStories
                var i = 0
                while (i < count){
                    self.brain.generateStoryFromID(storyIDs[i], storyIndex: i) {
                        let storyData = self.formatCellContents(atRow: $0)
                        println(storyData)
                        
                        if let title = storyData.title, subtitle = storyData.subtitle {
                            self.storyTableCellData[$0] = StoryContents(title: title, subtitle: subtitle)
                        }
                    }
                    i++
                }
            }

        }
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(80.0)
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
    
    
    // formats a specified cell on refresh
    func formatTableDataAfterStoryGeneration(index: Int) {
        dispatch_async(dispatch_get_main_queue()) {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) {
                self.formatCellContents(atRow: index)
            }
        }
    }
    
    
    // formats a cell's title and subtitle at a given row
    private func formatCellContents(atRow row: Int) -> (title: String?, subtitle: String?){
        var res_title = ""
        var tempStr = ""
        if let title = self.defaults.objectForKey("\(row).title") as? String {
            res_title = title
            if let score = self.defaults.objectForKey("\(row).score") as? Int {
                tempStr += "\(score) point(s) | "
            }
            if let user = self.defaults.objectForKey("\(row).by") as? String {
                tempStr += "by \(user) | "
            }
            if let url = self.defaults.objectForKey("\(row).url") as? String {
                if let fmtNsUrl = NSURL(string: url) {
                    let reducedUrl = fmtNsUrl.host!
                    tempStr += reducedUrl
                }
            }
        }
        return (res_title, tempStr)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return numberStories
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let dequeued: AnyObject = tableView.dequeueReusableCellWithIdentifier("storyCell", forIndexPath: indexPath)
        let cell = dequeued as! UITableViewCell
        
        let cellData = storyTableCellData[indexPath.row]
        println(cellData)
        if let title = cellData?.title, subtitle = cellData?.subtitle {
            cell.textLabel?.text = title
            cell.detailTextLabel?.text = subtitle
        } else {
            cell.textLabel?.text = "Loading...."
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
                                if let cellUrl = defaults.objectForKey("\(cellIndexPath.row).url") as? String {
                                    wvc.pageUrl = cellUrl
                                    println(cellUrl)
                                }
                                
                            }
                        }
                    }
                default: break
            }
        }
    }
}

