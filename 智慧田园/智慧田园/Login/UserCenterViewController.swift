//
//  UserCenterViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/27.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
import SDWebImage
class UserCenterViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var ConstraintButtonExitBottomDis: NSLayoutConstraint!
    @IBOutlet weak var TextFieldUserName: UITextField!
    @IBOutlet weak var ButtonExit: UIButton!
    @IBOutlet weak var ImgView: UIImageView!
    @IBOutlet weak var ButtonEdit: UIButton!
    @IBOutlet weak var ButtonExpert: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        TextFieldUserName.text = TYUserDefaults.username.value
        if let url = TYUserDefaults.headImage.value{
            ImgView.sd_setImageWithURL(NSURL(string:url)!,placeholderImage: UIImage(named: "DefaultHeaderPhoto"))
        }
        ImgView.clipsToBounds = true
        ImgView.layer.cornerRadius = 50
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(300, 391)
    }


    @IBAction func ButtonEditClicked(sender: UIButton) {
        
        sender.selected = !sender.selected
        ButtonExit.selected = sender.selected
        TextFieldUserName.enabled = sender.selected
        if sender.selected == true{
            TextFieldUserName.becomeFirstResponder()
            TextFieldUserName.background = UIImage(named: "Login_LoginWriteFrame")
        }else{
            TextFieldUserName.background = nil
            TextFieldUserName.resignFirstResponder()
        }
    }
    
    @IBAction func ButtonExitClicked(sender: UIButton) {
        
        if sender.selected == true{
            TextFieldUserName.text = TYUserDefaults.username.value
            ButtonEditClicked(ButtonEdit)
        }else{
            TYRequest(.Logout, parameters: nil).TYresponseJSON(completionHandler: { [weak self] response in
                if let sSelf = self {
                    TYUserDefaults.cookie.value = ";JSESSIONID=FC5E8F590ACF0AFDBF095F1222E83B4C"
                    TYUserDefaults.lastConnectTime.value = 0
                    TYUserDefaults.userID.value = nil
                    ModelManager.removeAll()
                    ExpertClient.shareClient.disConnect()
                    sSelf.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func ButtonExpertClicked() {
        self.dismissViewControllerAnimated(true) { 
            ExpertViewController.PushExpertViewController()
        }
    }
    class func pushAlertInViewController(viewController:UIViewController){
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("UserCenterViewController") as! UserCenterViewController
        let popController = STPopupController(rootViewController: vc)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.whiteColor()
        popController.navigationBar.subviews[0].alpha = 0
        popController.presentInViewController(viewController, completion: nil)
    }

    //MARK:-TextField's Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        TextFieldUserName.resignFirstResponder()
        return true
    }
    
}


