//
//  ViewController.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/7/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var hnReader = HackerNewsBrain()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSubmissions()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadSubmissions() {
        hnReader.startConnection()
    }
    
    @IBAction func debugSubmissions(sender: UIButton) {
        hnReader.genTopTwentyStories()
        
    }

}

