//
//  LoginViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/26.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
class LoginHomeViewController: UIViewController {

    lazy var loginViewController:LoginViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        return vc
    }()
    
    lazy var registerViewController:RegisterViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("RegisterViewController") as! RegisterViewController
        return vc
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(300, 331)
    }
    
    class func pushAlertInViewController(viewController:UIViewController){
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("LoginHomeViewController") as! LoginHomeViewController
        let popController = STPopupController(rootViewController: vc)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.whiteColor()
        popController.navigationBar.subviews[0].alpha = 0
        popController.presentInViewController(viewController, completion: nil)
    }
    @IBAction func ButtonRegisterClicked(sender: AnyObject) {
        self.popupController.pushViewController(registerViewController, animated: true)
    }

    @IBAction func ButtonLoginClicked(sender: AnyObject) {
        
        self.popupController.pushViewController(loginViewController, animated: true)
    }
}
