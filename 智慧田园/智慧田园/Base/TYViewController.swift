//
//  BaseViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/19.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import YYFPSLabel
class TYViewController: UIViewController {
    var loading = false
    lazy var fpsLabel:YYFPSLabel = {
        let label = YYFPSLabel()
        label.frame = CGRectMake(30, ScreenHeight - 30, 0, 0)
        label.sizeToFit()
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.BackgroundColor()
        let item = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = item;
    }
    
    func closeCurrentView(completion:(()->Void)?=nil){
        if self.navigationController?.childViewControllers.count > 1{
            self.navigationController?.popViewControllerAnimated(true)
            if let block = completion{
                block()
            }
        }else{
            self.dismissViewControllerAnimated(true, completion: completion)
        }
    }
    
    func closeCurrtenViewNoCompletion(){
        if self.navigationController?.childViewControllers.count > 1{
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
