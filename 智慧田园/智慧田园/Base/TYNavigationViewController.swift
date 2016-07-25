//
//  BaseNavigationViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/19.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class TYNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarTitleFont(),NSForegroundColorAttributeName:UIColor.NavigationBarTitleColor()]
        self.navigationBar.tintColor = UIColor.MidBlackColor()

    }

}
