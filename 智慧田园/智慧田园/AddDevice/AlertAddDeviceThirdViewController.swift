//
//  AlertAddDeviceThirdViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
class AlertAddDeviceThirdViewController: TYViewController {
    @IBOutlet weak var LabelTip: UILabel!
    @IBOutlet weak var LabelCurrentNetName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "第三步"
        LabelTip.text = "请切换WiFi至\"ZHTY_xxx\"\n然后返回APP"
        LabelCurrentNetName.text = UIDevice.currentDevice().SSID ?? "请连接Wi-Fi"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateStatus), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateStatus()
    }
    
    //检查一下wifi的状态
    func updateStatus(){
        if let name = UIDevice.currentDevice().SSID{
            if(name.hasPrefix("ZHTY_") == true){
                let story = UIStoryboard(name: "AddDevice", bundle: NSBundle.mainBundle())
                let vc = story.instantiateViewControllerWithIdentifier("Four") as! AlertAddDeviceFourViewController
                self.popupController.pushViewController(vc, animated: true)
            }else{
                LabelCurrentNetName.text = name
            }
        }else{
            LabelCurrentNetName.text = "请连接Wi-Fi"
        }

    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(335, 373)
    }
    @IBAction func ButtonSetClicked(sender: AnyObject) {
       UIApplication.sharedApplication().openURL(NSURL(string: "prefs:root=WIFI")!)
    }
}
