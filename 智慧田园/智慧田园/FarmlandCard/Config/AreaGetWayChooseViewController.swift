//
//  AreaGetWayChooseViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/25.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
class AreaGetWayChooseViewController: UIViewController {

    var block:((Double) -> Void)?
    lazy var areaViewController:AreaViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("AreaViewController") as! AreaViewController
        vc.block = self.block
        return vc
    }()
    
    lazy var GPSViewController:GPSWayViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("GPSWayViewController") as! GPSWayViewController
        vc.block = self.block
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "测量方式"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.popupController.style != .FormSheet{
            self.popupController.style = .FormSheet
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.popupController.navigationBar.tintColor = UIColor.MidBlackColor()
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(310, 170)
    }

    @IBAction func ButtonManualWayClicked(sender: AnyObject) {
        self.popupController.pushViewController(self.areaViewController, animated: true)
    }
    
    @IBAction func ButtonGPSWayClicked(sender: AnyObject) {
        self.popupController.pushViewController(self.GPSViewController, animated: true)
    }
    
    class func pushAlertInViewController(viewController:TYViewController, block:(Double) -> Void){
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("AreaGetWayChooseViewController") as! AreaGetWayChooseViewController
        vc.block = block
        let popController = STPopupController(rootViewController: vc)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.MidBlackColor()
        popController.navigationBar.subviews[0].alpha = 0
        popController.presentInViewController(viewController, completion: nil)
    }

}
