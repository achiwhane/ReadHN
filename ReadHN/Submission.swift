//
//  Submission.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 9/1/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import Foundation

enum Type {
    case Job
    case Story
    case Comment
    case Poll
    case PollOpt
    case None // in case we get a malformed response or something
}

// a general-purpose class to encapsulate a story (i.e. a submission or comment)
// on Hacker News
// see the [HN API Docs](https://github.com/HackerNews/API) for
// more into regarding each attribute
class Submission: NSObject, NSCoding {
    var id:         Int
    var isDeleted:  Bool
    var by:         String
    var type:       Type
    var time:       Int
    var text:       String
    var isDead:     Bool
    var parent:     Int
    var kids:       [Int]
    var url:        String
    var score:      Int // promotions don't have a score so might be nil
    var title:      String // comments don't have titles
    var descendants: Int
    //  var parts: [Submission]? -- wont consider polls for the time being
    
    override init() {
        id = 0
        isDeleted = false
        by = ""
        type = Type.None
        time = 0
        text = ""
        isDead = false
        parent = 0
        kids = []
        url = ""
        score = -1
        title = ""
        descendants = -1
    }
    
    convenience init(id: Int) {
        self.init()
        self.id = id
    }
    
    @objc func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(self.id, forKey: "id")
        encoder.encodeObject(self.isDeleted, forKey: "isDeleted")
        encoder.encodeObject(self.by, forKey: "by")
        encoder.encodeObject(self.type.hashValue, forKey: "type")
        encoder.encodeObject(self.time, forKey: "time")
        encoder.encodeObject(self.text, forKey: "text")
        encoder.encodeObject(self.isDead, forKey: "isDead")
        encoder.encodeObject(self.parent, forKey: "parent")
        encoder.encodeObject(self.kids, forKey: "kids")
        encoder.encodeObject(self.url, forKey: "url")
        encoder.encodeObject(self.score, forKey: "score")
        encoder.encodeObject(self.title, forKey: "title")
        encoder.encodeObject(self.descendants, forKey: "descendants")
    }
    
    @objc required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeObjectForKey("id") as? Int ?? -1
        self.isDeleted = aDecoder.decodeObjectForKey("isDeleted") as? Bool ?? false
        self.by = aDecoder.decodeObjectForKey("by") as? String ?? "INVALID"
        self.type = aDecoder.decodeObjectForKey("type") as? Type ?? Type.None
        self.time = aDecoder.decodeObjectForKey("time") as? Int ?? -1
        self.text = aDecoder.decodeObjectForKey("text") as? String ?? ""
        self.isDead = aDecoder.decodeObjectForKey("isDead") as? Bool ?? false
        self.parent = aDecoder.decodeObjectForKey("parent") as? Int ?? -1
        self.kids = aDecoder.decodeObjectForKey("kids") as? [Int] ?? []
        self.url = aDecoder.decodeObjectForKey("url") as? String ?? ""
        self.score = aDecoder.decodeObjectForKey("score") as? Int ?? -1
        self.title = aDecoder.decodeObjectForKey("title") as? String ?? ""
        self.descendants = aDecoder.decodeObjectForKey("descendants") as? Int ?? -1
    }
    
    func save() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(self)
        defaults.setObject(data, forKey: "\(self.id)")
    }
    
    class func loadSaved(id: Int) -> Submission? {
        if let data = defaults.objectForKey(id.description) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? Submission
        }
        return nil
    }
}

