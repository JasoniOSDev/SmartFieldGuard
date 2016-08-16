//
//  AlertAddDeviceViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
class AlertAddDeviceViewController: TYViewController {
    
    @IBOutlet weak var imaView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "第一步"
        imaView.layer.shadowColor = UIColor.LowBlackColor().CGColor
        imaView.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(335, 250)
    }
    
    class func PushAlertAddDeviceInViewController(viewController:UIViewController){
        let story = UIStoryboard(name: "AddDevice", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("First") as! AlertAddDeviceViewController
        let popController = STPopupController(rootViewController: vc)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.NavigationBarTitleColor()]
        popController.navigationBar.tintColor = UIColor.blackColor()
        for x in popController.navigationBar.subviews{
            x.subviews[0].removeFromSuperview()
        }
         popController.navigationBar.setBackgroundImage(UIImage(named: "NavigationBackgroundImg"), forBarMetrics: UIBarMetrics.Default)
        popController.presentInViewController(viewController)

    }
    @IBAction func ButtonNextClicked(sender: AnyObject) {
        let story = UIStoryboard(name: "AddDevice", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("Second") as! AlertAddDeviceSecondViewController
        self.popupController.pushViewController(vc, animated: true)
    }
}
