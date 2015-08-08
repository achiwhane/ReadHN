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
    private var submissionIDs = [Int]()
    private var stories = [Story]()
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    struct Story {
        var title: String
        var url: String
    }
    
    
    struct Key {
        static let sID: String = "submissionids.array"
    }
    
    
    func startConnection(callback: () -> ()) {
        if let url = NSURL(string: "https://hacker-news.firebaseio.com/v0/topstories.json") {
            var session = NSURLSession.sharedSession()
            let jsonReuest = session.dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                
                println("in session handler")
                if error != nil {
                    println("\(error.localizedDescription)")
                }
                var err: NSError?
                var dataArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as! NSArray?
                if err != nil {
                    println("\(err?.localizedDescription)")
                }
                
                // create a temp array of ints to hold the session ids
                var tempSID = [Int]()
                if let array = dataArray {
                    for elem in array {
                        tempSID.append(elem as! Int)
                    }
                }
                
                // load this array into NSUserDefaults
                self.defaults.setObject(tempSID, forKey: Key.sID)
                println("done loading key")
                callback()
                
            })
            jsonReuest.resume()
            
        }
    }
    
    // we want this to return nil in the event that we don't get a valid ID or
    // if the item gets deleted

}