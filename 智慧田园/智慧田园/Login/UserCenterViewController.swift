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
import MBProgressHUD
class UserCenterViewController: UIViewController {

    @IBOutlet weak var ConstraintButtonExitBottomDis: NSLayoutConstraint!
    @IBOutlet weak var TextFieldUserName: UITextField!
    @IBOutlet weak var ButtonExit: UIButton!
    @IBOutlet weak var ImgView: UIImageView!
    @IBOutlet weak var ButtonEdit: UIButton!
    @IBOutlet weak var ButtonExpert: UIButton!
    @IBOutlet weak var ButtonUploadPhoto: UIButton!
    var backgroundTaskID:UIBackgroundTaskIdentifier!
    lazy var loadingHUD:MBProgressHUD = {
        let hud = MBProgressHUD.showMessage("正在上传头像", view: nil)
        return hud
    }()
    lazy var imagePickerViewController:UIImagePickerController = {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.allowsEditing = true
        imagePickerViewController.delegate = self
        return imagePickerViewController
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        TextFieldUserName.text = TYUserDefaults.username.value
        ImgView.sd_setImageWithURL(NSURL(string:TYUserDefaults.headImage.value)!)
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(300, 330)
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
    
    @IBAction func ButtonEditClicked(sender: UIButton) {
        sender.selected = !sender.selected
        ButtonExit.selected = sender.selected
        TextFieldUserName.enabled = sender.selected
        ButtonExpert.hidden = sender.selected
        ButtonUploadPhoto.hidden = sender.selected
        
        if sender.selected == true{
            TextFieldUserName.becomeFirstResponder()
            TextFieldUserName.background = UIImage(named: "UserCenter_TextFieldNameBK_W")
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
            TYRequest(.Logout, parameters: nil).TYresponseJSON(completionHandler: { response in
                    TYUserDefaults.cookie.value = ";JSESSIONID=FC5E8F590ACF0AFDBF095F1222E83B4C"
                    TYUserDefaults.lastConnectTime.value = 0
                    TYUserDefaults.userID.value = nil
                    ModelManager.removeAll()
                    ExpertClient.shareClient.disConnect()
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
        }
    }
    
    @IBAction func ButtonExpertClicked() {
        self.dismissViewControllerAnimated(true) {
            ExpertViewController.PushExpertViewController()
        }
    }
    
    @IBAction func ButtonUploadPhotoClicked() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "从相册选择", style: .Default, handler: { [weak self] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else{
                MBProgressHUD.showError("访问相册失败", toView: nil)
                return
            }
            if let sSelf = self {
                sSelf.imagePickerViewController.sourceType = .PhotoLibrary
                sSelf.presentViewController(sSelf.imagePickerViewController, animated: true, completion: nil)
            }
            }))
        alertController.addAction(UIAlertAction(title: "拍照", style: .Default, handler: { [weak self] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.Camera) else{
                MBProgressHUD.showError("无法打开相机", toView: nil)
                return
            }
            if let sSelf = self {
                sSelf.imagePickerViewController.sourceType = .Camera
                sSelf.presentViewController(sSelf.imagePickerViewController, animated: true, completion: nil)
            }
            
            }))
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}

//MARK:-TextField's Delegate
extension UserCenterViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        TextFieldUserName.resignFirstResponder()
        return true
    }
}

//MARK: - UIImagePickerControllerDelegate
extension UserCenterViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        let preImage = ImgView.image
        let origionHeight = image.size.height
        let newImage = image.kt_drawRectWithRoundedCorner(radius: origionHeight/2, image.size)
        ImgView.image = newImage
        let realSize = CGSizeMake(min(50,origionHeight), min(50,origionHeight))
        let lowQualityImage = image.resizeToSize(realSize, withInterpolationQuality: .High)?.kt_drawRectWithRoundedCorner(radius: realSize.height/2, realSize)
        self.backgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            [weak self] in
            if let sSelf = self {
            UIApplication.sharedApplication().endBackgroundTask(sSelf.backgroundTaskID)
                sSelf.backgroundTaskID = UIBackgroundTaskInvalid
            }
        })
        NetWorkManager.uploadUserPhoto(newImage, lowQualityImage: lowQualityImage!) { (tg) in
            if(tg){
                MBProgressHUD.showSuccess("头像上传成功", toView: nil)
                let headURL = TYUserDefaults.headImage.value
                var array = headURL.componentsSeparatedByString("/")
                let sourceName = array.last!
                array.removeLast()
                var sourceArray = sourceName.componentsSeparatedByString(".")
                sourceArray[0] = TYUserDefaults.userID.value!
                let newURL = array.reduce("", combine: { (pre, now) -> String in
                    return pre + now + "/"
                }) + sourceArray[0] + ".png"
                TYUserDefaults.headImage.value = newURL
                self.ImgView.sd_setImageWithURL(NSURL(string: newURL)!, placeholderImage: newImage, options: [.RefreshCached,.AvoidAutoSetImage])
                self.ImgView.sd_setImageWithURL(NSURL(string: newURL.imageLowQualityURL())!, placeholderImage: newImage, options: [.RefreshCached,.AvoidAutoSetImage])
            }else{
                MBProgressHUD.showError("上传失败，请稍后重试", toView: nil)
                self.ImgView.image = preImage
                
            }
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}
