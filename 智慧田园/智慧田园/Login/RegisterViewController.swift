//
//  RegisterViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/26.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MBProgressHUD
class RegisterViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var TextFieldPassWord: UITextField!
    @IBOutlet weak var TextFieldPhone: UITextField!
    @IBOutlet weak var TextFieldUserName: UITextField!
    var UserNameForUser = false
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(300, 441)
    }

    @IBAction func ButtonRegisterClicked(sender: UIButton) {
        if let phone = TextFieldPhone.text{
            if let passWord = TextFieldPassWord.text{
                if let username = TextFieldUserName.text{
                    let hud = MBProgressHUD.showMessage(nil, view: nil)
                    TYRequest(.Register, parameters: ["tel":phone,"password":passWord,"username":username]).TYresponseJSON(completionHandler: {[weak self] response in
                        if let sSelf = self {
                            if response.result.isSuccess{
                                if let json = response.result.value as? [String:AnyObject]{
                                    if let message = json["message"] as? String where message == "success",let userID = json["userId"] as? String{
                                        TYUserDefaults.username.value = username
                                        TYUserDefaults.tel.value = phone
                                        TYUserDefaults.passWord.value = passWord
                                        TYUserDefaults.userID.value = userID
                                        NetWorkManager.updateSession({
                                            sSelf.dismissViewControllerAnimated(true, completion: nil)
                                            dispatch_async(dispatch_get_main_queue(), {
                                                hud.hide(true)
                                                NSThread.sleepForTimeInterval(0.5)
                                                MBProgressHUD.showSuccess("注册成功", toView: nil)
                                            })
                                        })
                                        
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(), {
                                            hud.hide(true)
                                            NSThread.sleepForTimeInterval(0.5)
                                            MBProgressHUD.showError(json["message"] as! String, toView: nil)
                                        })
                                    }
                                }
                            }
                        }
                    })
                }
            }
        }
        
        
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 103{
            textField.resignFirstResponder()
        }else{
            if textField.tag == 101{
                TextFieldPassWord.becomeFirstResponder()
            }else{
                TextFieldUserName.becomeFirstResponder()
            }
        }
        
        return true
    }
    
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField.tag == 103 && textField.text != nil && textField.text != ""{
            UserNameForUser = true
        }else{
            UserNameForUser = false
        }
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 101 && !UserNameForUser {
            if let phone = textField.text{
                TextFieldUserName.text = "手机用户" + phone
            }else{
                TextFieldUserName.text = nil
            }
        }

    }
}
