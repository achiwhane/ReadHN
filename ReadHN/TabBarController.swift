//
//  TabBarController.swift
//  ReadHN
//
//  Created by Akshay Chiwhane on 8/8/15.
//  Copyright (c) 2015 Akshay Chiwhane. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.tintColor = UIColor.blackColor()
        let tabItems = self.tabBar.items! as [UITabBarItem]
        
        for item in tabItems {
            item.titlePositionAdjustment.horizontal = 0
            item.titlePositionAdjustment.vertical = -self.tabBar.bounds.midY/2
            //item.titlePositionAdjustment(UIOffset(horizontal: 0, vertical: -self.tabBar.bounds.midY/2))
            let titleDict = [NSFontAttributeName: UIFont.systemFontOfSize(CGFloat(16))]

            
            item.setTitleTextAttributes(titleDict, forState: UIControlState.Normal)
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
