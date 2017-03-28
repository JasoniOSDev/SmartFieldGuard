//
//  AlertAddDeviceSecondViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import SystemConfiguration
//import Reachability
class AlertAddDeviceSecondViewController: TYViewController,UITextFieldDelegate {
    static var wifiName = "?"
    static var wifiPassWord = "?"
    @IBOutlet weak var LabelWiFiName: UILabel!
    @IBOutlet weak var TextFieldWiFiPassWord: UITextField!
    @IBOutlet weak var ButtonNext: UIButton!
    var reach: Reachability?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "第二步"
        self.reach = Reachability.reachabilityForInternetConnection()
        self.reach!.reachableBlock = {
            [weak self] reach in
            dispatch_async(dispatch_get_main_queue()) {
                self?.nextworkStatusChange()
            }
        }
        self.reach!.unreachableBlock = {
            [weak self] reach in
            dispatch_async(dispatch_get_main_queue()) {
                self?.nextworkStatusChange()
            }
        }
        self.reach!.startNotifier()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateButtonNext(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(335, 250)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nextworkStatusChange()
        ButtonNext.enabled = false
    }
    
    func updateButtonNext(noti:NSNotification){
        let info = noti.object as! UITextField
        if let content = info.text {
            if(content.characters.count>=8){
                ButtonNext.enabled = true
            }else{
                ButtonNext.enabled = false
            }
        }else{
            ButtonNext.enabled = false
        }
    }
    
    func nextworkStatusChange(){
        if let name = UIDevice.currentDevice().SSID{
            LabelWiFiName.text = name
            LabelWiFiName.textColor = UIColor.HightBlackColor()
            TextFieldWiFiPassWord.enabled = true
            TextFieldWiFiPassWord.text = nil
        }else{
            LabelWiFiName.text = "请连接Wi-Fi"
            LabelWiFiName.textColor = UIColor.LowBlackColor()
            TextFieldWiFiPassWord.enabled = false
            TextFieldWiFiPassWord.text = nil
        }
    }

    //保存wifi名称和密码
    func saveNetInfo(){
        AlertAddDeviceSecondViewController.wifiName = LabelWiFiName.text!
        AlertAddDeviceSecondViewController.wifiPassWord = TextFieldWiFiPassWord.text!
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        saveNetInfo()
        return true
    }

    @IBAction func ButtonNextClicked(sender: AnyObject) {
        saveNetInfo()
        let story = UIStoryboard(name: "AddDevice", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("Third") as! AlertAddDeviceThirdViewController
        self.popupController.pushViewController(vc, animated: true)
    }
    
    deinit{
        self.reach!.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
