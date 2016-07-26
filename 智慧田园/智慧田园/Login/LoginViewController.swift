//
//  LoginViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/26.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import Alamofire
class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var TextFieldPhone: UITextField!
    @IBOutlet weak var TextFieldPassWord: UITextField!
    @IBOutlet weak var ButtonLogin: UIButton!
    @IBOutlet weak var LabelTip: UILabel!
    var WrongTag = 100
    override func viewDidLoad() {
        super.viewDidLoad()
        TextFieldPhone.text = TYUserDefaults.tel.value
    }

    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(300, 391)
    }
    
    @IBAction func ButtonLoginClicked(sender: AnyObject) {
        var phone:String = ""
        var passWord:String = ""
        //清空数据
        ModelManager.removeAll()
        removeRedFrame()
        
        if let str = TextFieldPhone.text where str != "" {
            phone = str
        }else{
            TextFieldPhone.background = UIImage(named: "Login_LoginWriteFrame_Red")
            LabelTip.text = "手机号码为空"
            WrongTag = 101
            return
        }
        
        if let str = TextFieldPassWord.text where str != "" {
            passWord = str
        }else{
            TextFieldPassWord.background = UIImage(named: "Login_LoginWriteFrame_Red")
            LabelTip.text = "密码为空"
            WrongTag = 102
            return
        }
        
        WrongTag = 100
        
    NetWorkManager.login(["username":phone,"password":passWord]) { [weak self] json in
                let message = json["message"] as! String
                if(message == "success"){
                    if let sSelf = self{
                        sSelf.dismissViewControllerAnimated(true, completion: {
                            //登录之后，下载对应的专家话题
                            NetWorkManager.LoadExperTopic(true)
                            //下载植物分类
                            NetWorkManager.GetCropsClass({ (_) in
                                
                            })
                            //后期整理应将登录后所要做的操作分出来
                        })
                        
                    }
                }else{
                    if let sSelf = self{
                        sSelf.wrongInfo(message)
                    }
                }
        }
    }
    
    func wrongInfo(info:String){
        LabelTip.text = info
    }
    
    func removeRedFrame(){
        
        if(TextFieldPhone.tag == WrongTag){
            TextFieldPhone.background = UIImage(named: "Login_LoginWriteFrame")
        }
        
        if(TextFieldPassWord.tag == WrongTag){
            TextFieldPassWord.background = UIImage(named: "Login_LoginWriteFrame")
        }

    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == WrongTag {
            textField.background = UIImage(named: "Login_LoginWriteFrame")
            WrongTag = 100
            LabelTip.text = nil
        }
        if WrongTag == 100{
            LabelTip.text = nil
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 101{
            textField.resignFirstResponder()
            TextFieldPassWord.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
            ButtonLoginClicked(ButtonLogin)
        }
        return true
    }
    
}
