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
        //print("start connection")
        if let urlStr = delegate?.categoryUrl {
            //print(urlStr)
            Alamofire.request(.GET, urlStr).responseJSON() {
                data in
                //print(data.data)
                
                let json = JSON(data.result.value!)
                print(json)
//                json.
//                let count = data.data!.length / sizeof(Int)
//                self.submissionIDs = [Int](count: count, repeatedValue: 0)
//                data.data?.getBytes(&self.submissionIDs, length: count * sizeof(Int))
//                print(self.submissionIDs)
                //self.submissionIDs = json as? [Int] ?? []
                self.submissionIDs = (json.arrayObject as? [Int])!
                // load this array into NSUserDefaults
                defaults.setObject(self.submissionIDs, forKey: Key.sID)
                print("done loading key")
                callback()
                
            }
        }
    }
    
    func generateSubmissionForID(id: Int, callback: () -> ()) {
        let url = "https://hacker-news.firebaseio.com/v0/item/\(id).json"
        Alamofire.request(.GET, url).responseJSON() { (data) -> Void in
            self.parseSubmissionJsonForID(id, jsonData: data.result.value)
            callback()
        }
        
    }

    
    func parseSubmissionJsonForID(id: Int, jsonData: AnyObject?) {
        let s = Submission(id: id)
        let json = JSON(jsonData!)
        //print(json)
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
                //print(s.url)
            } else {
                s.url = url
            }
        }
        s.score = json["score"].int ?? -1
        s.title = json["title"].string ?? "INVALID TITLE"
        s.descendants = json["descendants"].int ?? -1
        s.save()
        //NSLog("Wrote data for submission w/ id = \(s.id)")
    }
}