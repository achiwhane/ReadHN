//
//  HackerNewsBrain.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/7/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import Foundation

class HackerNewsBrain {
    private let topStories = "https://hacker-news.firebaseio.com/v0/topstories.json"
    private let newStories = "https://hacker-news.firebaseio.com/v0/newstories.json"
    private var submissionIDs = [Int]()
    private var stories = [Story]()
    
    struct Story {
        var title: String
        var url: String
    }
    
    func startConnection() {
        var url = NSURL(string: topStories)
        if let hnUrl = url {
            let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
            dispatch_async(queue){
                var session = NSURLSession.sharedSession()
                let jsonReuest = session.dataTaskWithURL(hnUrl, completionHandler: { (data, response, error) -> Void in
                    
                    println("in session handler")
                    if error != nil {
                        println("\(error.localizedDescription)")
                    }
                    var err: NSError?
                    var dataArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSArray?
                    if err != nil {
                        println("\(err?.localizedDescription)")
                    }
                    
                    if let arr = dataArray {
                        for elem in arr {
                            self.submissionIDs.append(elem as! Int)
                        }
                    }
                    
                    println("\(self.submissionIDs)")
                    
                })
                jsonReuest.resume()
            }
        }
    }
    
    func genTopTwentyStories(){
        if self.submissionIDs.count > 0{
            var count = 20
            while (count > 0){
                self.generateStoryFromID(self.submissionIDs[count])
                count = count - 1
            }
        }
        println("\(self.stories.count)")
    }
    
    
    // we want this to return nil in the event that we don't get a valid ID or
    // if the item gets deleted
    private func generateStoryFromID(id: Int){
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
                    
                    var title: String = "NOT INITIATIED TITLE"
                    var url: String = "NOT INITIATED URL"
                    if let storyJson = jsonData as! NSDictionary? {
                        // extract the story title
                        if let tempTitle = storyJson["title"] as! String? {
                            title = tempTitle
                        }
                        if let tempUrl = storyJson["url"] as! String? {
                            url = tempUrl
                        }
                    }
                    self.stories.append(Story(title: title, url: url))
                })
                jsonRequest.resume()
            }
        }
    }


    
    
}