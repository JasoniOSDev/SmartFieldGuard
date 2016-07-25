//
//  TYTabBarItem.swift
//  智慧田园
//
//  Created by jason on 16/5/21.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class TYTabBarItem: UITabBarItem {

    override func awakeFromNib() {
        super.awakeFromNib()
        //解决高亮默认为蓝色的bug
        
        self.selectedImage = self.selectedImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor(RGB: 0x979797, alpha: 1)], forState: .Selected)
    }
}
