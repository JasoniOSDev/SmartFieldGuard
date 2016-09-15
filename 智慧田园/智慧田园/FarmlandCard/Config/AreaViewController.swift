//
//  AreaViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/26.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class AreaViewController: UIViewController,UITextFieldDelegate {

    lazy var GPSViewController:GPSWayViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("GPSWayViewController") as! GPSWayViewController
        vc.block = self.block
        return vc
    }()
    
    var block:((Double) -> Void)?
    var area:Double = 0{
        didSet{
            if TextFieldArea != nil {
                TextFieldArea.text = String(format: "%.f 亩", area)
            }
        }
    }
    var from = "Way"//"GPS"表示从哪里来，影响了ButtonGPS的内容
    @IBOutlet weak var TextFieldArea: UITextField!
    @IBOutlet weak var ButtonGPS: UIButton!
    
    
    override func loadView() {
        super.loadView()
        if from == "GPS" {
            ButtonGPS.selected = true
        }
        self.contentSizeInPopup = CGSizeMake(330, 200)
        self.title = "农田面积"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TextFieldArea.text = String(format: "%.f", area)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.popupController.navigationBar.tintColor = UIColor.MidBlackColor()
    }
    
    
    @IBAction func ButtonGPSClicked(sender: UIButton) {
        if sender.selected == true{
            self.popupController.popViewControllerAnimated(true)
        }else{
            let viewController = GPSViewController
            let popController = self.popupController
            self.popupController.popViewControllerAnimated(false)
            popController.pushViewController(viewController, animated: true)
        }
    }
    @IBAction func ButtonSureClicked(sender: AnyObject) {
        if let finishBlock = block{
            TextFieldArea.resignFirstResponder()
            finishBlock(area)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //MARK:-TextField代理
    func textFieldDidBeginEditing(textField: UITextField) {
        if let str = textField.text as? NSString {
            if str.length > 5{
                textField.text = str.substringWithRange(NSRange(location: 0,length: str.length - 2))
            }else{
                textField.text = nil
            }
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if let str = textField.text  {
            if let Value = Double(str){
                area = Value
            }
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

