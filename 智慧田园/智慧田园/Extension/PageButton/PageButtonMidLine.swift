//
//  PageButtonMidLine.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class PageButtonMidLine: UIButton {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeContentCenter()
        self.addObserver(self, forKeyPath: "selected", options: .New, context: nil)
        self.addObserver(self, forKeyPath: "highlighted", options: .New, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if(keyPath == "selected" || keyPath == "highlighted"){
            makeContentCenter()
        }
    }
    
    deinit{
        self.removeObserver(self, forKeyPath: "selected")
        self.removeObserver(self, forKeyPath: "highlighted")
    }
    
    //添加一个方法，使得线在下面，整体居中
    //有bug，取巧一下吧，日后再解决
    var selectedImageEdgeInsets:UIEdgeInsets?
    var selectedTitleEdgeInsets:UIEdgeInsets?
    func makeContentCenter(){
        if(self.selected == true && self.highlighted == false){
            self.contentVerticalAlignment = .Bottom
//            if(selectedImageEdgeInsets == nil){
//                let buttonSize = self.bounds.size
//                let imgCenter = self.imageView!.center
//                let imgLastPos = CGPointMake(buttonSize.width/2, buttonSize.height - 0.5)
//                let titleCenter = self.titleLabel!.center
//                let titleLastPos = CGPointMake(buttonSize.width/2, buttonSize.height/2)
//                self.selectedImageEdgeInsets = UIEdgeInsetsMake(imgLastPos.y - imgCenter.y , imgLastPos.x - imgCenter.x, 0, 0)
//                self.selectedTitleEdgeInsets = UIEdgeInsetsMake(titleLastPos.y - titleCenter.y  ,titleLastPos.x - titleCenter.x , 0, 0)
//                self.imageEdgeInsets = self.selectedImageEdgeInsets!
//                self.titleEdgeInsets = self.selectedTitleEdgeInsets!
//                //折中方法
//                self.imageEdgeInsets = UIEdgeInsetsZero
//                self.titleEdgeInsets = UIEdgeInsetsZero
//                self.contentVerticalAlignment = .Center
//                self.contentHorizontalAlignment = .Center
//                self.selected = false
//            }else{
//                self.imageEdgeInsets = selectedImageEdgeInsets!
//                self.titleEdgeInsets = selectedTitleEdgeInsets!
//            }

        }else{
            self.contentVerticalAlignment = .Center
            self.contentHorizontalAlignment = .Center
        }
    }
    
    
}
