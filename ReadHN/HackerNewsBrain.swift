//
//  HackerNewsBrain.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/7/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


protocol StoryCategoryDelegate {
    var categoryUrl: String {get set}
}



class HackerNewsBrain {
    var submissionIDs = [Int]()
    private var stories = [Story]()
    
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
                defaults.setObject(self.submissionIDs, forKey: Key.sID)
                println("done loading key")
                callback()
                
            }
        }
    }
    
    func generateSubmissionForID(id: Int, callback: () -> ()) {
        let url = "https://hacker-news.firebaseio.com/v0/item/\(id).json"
        Alamofire.request(.GET, url).responseJSON() { (_, _, data, _) -> Void in
            self.parseSubmissionJsonForID(id, jsonData: data)
            callback()
        }
    }

    
    func parseSubmissionJsonForID(id: Int, jsonData: AnyObject?) {
        let s = Submission(id: id)
        let json = JSON(jsonData!)
        s.isDeleted = json["deleted"].bool ?? false
        s.by = json["by"].string ?? ""
        s.time = json["time"].int ?? -1
        s.text = json["text"].string ?? "NIL"
        s.isDead = json["dead"].bool ?? false
        s.parent = json["parent"].int ?? -1
        s.kids = json["kids"].arrayObject as? [Int] ?? [Int]()
        if let url = json["url"].string {
            if url == "" {
                s.url = "https://news.ycombinator.com/item?id=\(id)"
            } else {
                s.url = url
            }
        }
        s.score = json["score"].int ?? -1
        s.title = json["title"].string ?? ""
        s.descendants = json["descendants"].int ?? -1
        s.save()
        NSLog("Wrote data for submission w/ id = \(s.id)")
    }
}