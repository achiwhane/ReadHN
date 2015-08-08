//
//  StoriesTableViewController.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/7/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import UIKit

class StoriesTableViewController: UITableViewController {
    
    let numberStories = 20
    let defaults = NSUserDefaults.standardUserDefaults()
    
    var brain = HackerNewsBrain()
    
    struct Key {
        static let sID: String = "submissionids.array"
    }

    // we want this to return nil in the event that we don't get a valid ID or
    // if the item gets deleted
    private func generateStoryFromID(id: Int, storyIndex: Int, callback: () -> ()){
        println("\(storyIndex)")
        let url = NSURL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")
        if let storyUrl = url {
            // create an empty story
            // tart an async session to retrieve and parse json object for story
            let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
            dispatch_async(queue) {
                var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
                let jsonRequest = session.dataTaskWithURL(storyUrl, completionHandler: { (data, response, error) -> Void in
                    if error != nil {
                        println("\(error.localizedDescription)")
                    }
                    
                    var parseError: NSError? // just in case
                    var jsonData: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &parseError)
                    
                    if parseError != nil {
                        println("\(parseError?.localizedDescription)")
                    }
                    
                    if let storyJson = jsonData as! NSDictionary? {
                        // set the story title and url in defaults
                        if let title = storyJson["title"] as! String? {
                            self.defaults.setObject(title, forKey: "\(storyIndex).title")
                        }
                        if let url = storyJson["url"] as! String? {
                            self.defaults.setObject(url, forKey:"\(storyIndex).url")
                        }
                        if let score = storyJson["score"] as! Int?{
                            self.defaults.setObject(score, forKey: "\(storyIndex).score")
                        }
                        if let by = storyJson["by"] as? String {
                            self.defaults.setObject(by, forKey: "\(storyIndex).by")
                        }
                    }
                    println("loaded data for item number: \(storyIndex)")
                })
                jsonRequest.resume()
            }
        }
    }

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain.startConnection() {
            let storyIDs = self.defaults.objectForKey(Key.sID) as? [Int] ?? []
            println("\(storyIDs.count)")
            if storyIDs.count > 0{
                var count = 20
                var i = 0
                while (i < count){
                    self.generateStoryFromID(storyIDs[i], storyIndex: i) {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.tableView.reloadData()
                        })
                    }
                    i++
                }
            }
        }
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return
    }*/

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return numberStories
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let dequeued: AnyObject = tableView.dequeueReusableCellWithIdentifier("storyCell", forIndexPath: indexPath)
        let cell = dequeued as! UITableViewCell
        
        if let title = defaults.objectForKey("\(indexPath.row).title") as? String {
            cell.textLabel?.text = title
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(CGFloat(16.0))
            
            var tempStr = ""
            if let score = defaults.objectForKey("\(indexPath.row).score") as? Int {
                tempStr += "\(score) point(s) | "
            }
            if let user = defaults.objectForKey("\(indexPath.row).by") as? String {
                tempStr += "by \(user)"
            }
            
            cell.detailTextLabel?.text = tempStr

        } else {
            var title = defaults.objectForKey("\(indexPath.row).title") as? String ?? ""
            println("current title: \(title)")
            println("intended title: \(indexPath.row).title")
        }
        
        return cell
    }
    

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
