//
//  HackerNewsBrain.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/7/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import Foundation
import Alamofire


protocol StoryCategoryDelegate {
    var categoryUrl: String {get set}
}
class HackerNewsBrain {
    private var submissionIDs = [Int]()
    private var stories = [Story]()
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var delegate: StoryCategoryDelegate?
    
    struct Story {
        var title: String
        var url: String
    }
    
    
    struct Key {
        static let sID: String = "submissionids.array"
    }
    
    func startConnection(callback: () -> ()) {
        if let urlStr = delegate?.categoryUrl {
            Alamofire.request(.GET, urlStr).responseJSON() {
                (_, _, data, _) in
                self.submissionIDs = data as? [Int] ?? []
                // load this array into NSUserDefaults
                self.defaults.setObject(self.submissionIDs, forKey: Key.sID)
                println("done loading key")
                callback()
                
            }
        }
    }
    
    // uses Firebase API to get story JSON and parse that to get title, url, etc.
    func generateStoryFromID(id: Int, storyIndex: Int, callback: (index: Int) -> ()){
        let url = "https://hacker-news.firebaseio.com/v0/item/\(id).json"
        Alamofire.request(.GET, url).responseJSON() { (_, _, data, _) -> Void in
            self.parseStoryJson(id, storyIndex: storyIndex, jsonData: data)
            callback(index: storyIndex)
        }
    }
    
    // does the actual parsing of the JSON
    func parseStoryJson(id: Int, storyIndex: Int, jsonData: AnyObject?) {
        if let storyJson = jsonData as! NSDictionary? {
            // set the story title and url in defaults
            if let title = storyJson["title"] as! String? {
                defaults.setObject(title, forKey: "\(storyIndex).title")
            }
            if let url = storyJson["url"] as! String? {
                // self-posts in HN return empty URL params in the JSON, so
                // we simply create the link using the storyID
                // I'll change this to natively display the self-post when I start
                // working on comments
                if url == ""{
                    var alternateUrl = "https://news.ycombinator.com/item?id=\(id)"
                    defaults.setObject(alternateUrl, forKey:"\(storyIndex).url")
                } else {
                    defaults.setObject(url, forKey:"\(storyIndex).url")
                }
            }
            if let score = storyJson["score"] as! Int?{
                defaults.setObject(score, forKey: "\(storyIndex).score")
            }
            if let by = storyJson["by"] as? String {
                defaults.setObject(by, forKey: "\(storyIndex).by")
            }
        }
        println("parsed JSON for id: \(id), ind: \(storyIndex)")
    }

}