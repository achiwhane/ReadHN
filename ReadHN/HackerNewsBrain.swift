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
        let submission = Submission(id: id)
        if let theJson = jsonData as? NSDictionary {
            if let deleted = theJson["deleted"] as? Bool {
                submission.isDeleted = deleted
            }
            if let type = theJson["type"] as? String {
                func setType(submissionType: Type) {
                    submission.type = submissionType
                }
                switch type{
                case "job":     setType(Type.Job)
                case "story":   setType(Type.Story)
                case "comment": setType(Type.Comment)
                    
                    // wont worry about polls for now
                    //                  case "poll":    setType(Type.Poll)
                    //                  case "pollopt": setType(Type.PollOpt)
                    
                default:        setType(Type.None)
                }
            }
            if let by = theJson["by"] as? String {
                submission.by = by
            }
            if let time = theJson["time"] as? Int {
                submission.time = time
            }
            if let text = theJson["text"] as? String {
                submission.text = text
            }
            if let dead = theJson["dead"] as? Bool {
                submission.isDead = dead
            }
            if let parent = theJson["parent"] as? Int {
                submission.parent = parent
            }
            if let kids = theJson["kids"] as? [Int] {
                submission.kids = kids
            }
            if let url = theJson["url"] as? String {
                submission.url = url
            }
            if let score = theJson["score"] as? Int {
                submission.score = score
            }
            if let title = theJson["title"] as? String {
                submission.title = title
            }
        }
        submission.save()
        NSLog("Wrote data for submission w/ id = \(submission.id)")
    }
}