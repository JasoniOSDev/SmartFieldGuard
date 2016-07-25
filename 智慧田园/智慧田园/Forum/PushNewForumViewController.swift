//
//  PushNewForumViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import Alamofire
import MBProgressHUD
class PushNewForumViewController: TYViewController,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var ButtonAdd: UIButton!
    @IBOutlet weak var TextViewContent: UITextView!
    @IBOutlet weak var StackViewAddPicture: UIStackView!
    @IBOutlet weak var ButtonContentClass: UIButton!
    @IBOutlet weak var StackViewImg: UIStackView!
    lazy var ImgPickViewController:UIImagePickerController = {
        let viewController = UIImagePickerController()
        viewController.sourceType = .PhotoLibrary
        viewController.allowsEditing = false
        viewController.delegate = self
        viewController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.NavigationBarTitleColor()]
        if let leftItem:UIBarButtonItem = viewController.navigationItem.leftBarButtonItem{
            leftItem.image = UIImage(named:"Close_White")
            leftItem.tintColor = UIColor.LowBlackColor()
        }
        if let rightItem:UIBarButtonItem = viewController.navigationItem.rightBarButtonItem{
            rightItem.image = UIImage(named:"OK_White")
            rightItem.tintColor = UIColor.LowBlackColor()
        }
        return viewController
    }()
    var cropsID:String!
    var cropsName:String!
    var contentClass:String!
    var imgs = [UIImage]()
    var imgButtons = [UIButton]()
    var imgButton:UIButton {
        get{
            let btn = UIButton()
            btn.setImage(UIImage(named:"PushNew_Button_Delete"), forState: .Normal)
            btn.addTarget(self, action: #selector(self.imgButtonDelete(_:)), forControlEvents: .TouchUpInside)
            btn.snp_makeConstraints { (make) in
                make.height.width.equalTo(80)
            }
            return btn
        }
    }
    enum NewStyle{
        case Forum
        case Expert
    }
    
    var style:NewStyle = .Forum
    override func viewDidLoad() {
        super.viewDidLoad()
        switch style {
        case .Forum:
            self.title = "发问题"
        case .Expert:
            self.title = "专家咨询"
        }
        contentClass = "水稻"
        ButtonContentClass.setTitle(self.contentClass, forState: .Normal)
    }

    @IBAction func LeftButtonClicked(sender: UIBarButtonItem) {
        TextViewContent.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    @IBAction func RightBarButtonClicked(sender: AnyObject) {
        TextViewContent.resignFirstResponder()
        if style == .Forum{
            if let content = TextViewContent.text {
                NetWorkManager.updateSession({ 
                    Alamofire.upload(.POST, ContentType.PulishNewForum.url, multipartFormData: { [weak self] data in
                        if let sSelf = self{
                            var i = 0
                            for image in sSelf.imgs{
                                if let imageData = UIImageJPEGRepresentation(image, 0.95) {
                                    //                            data.appendBodyPa rt(data: imageData, name: "fileImages")
                                    data.appendBodyPart(data: imageData, name: "file", fileName: "images.jpg", mimeType: "image/jpg")
                                    i += 1
                                }
                            }
                        }
                        let contentData = content.dataUsingEncoding(NSUTF8StringEncoding)
                        data.appendBodyPart(data: contentData!, name: "content")
                        }, encodingCompletion: { (result) in
                            switch result{
                            case .Success(let request,  _,  _):
                                request.TYresponseJSON(completionHandler: { (response) in
                                    TYUserDefaults.NewForum.value = true
                                })
                            case .Failure(_):
                                break
                            }
                    })
                })
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }else{
            if let content = TextViewContent.text {
                let topic = ExpertTheme()
                topic.classifyID = cropsID
                topic.classifyName = cropsName
                topic.content = content
                topic.headPhoto = TYUserDefaults.headImage.value!
                topic.userID = TYUserDefaults.userID.value!
                NetWorkManager.PushNewExpertTopic(topic, images: imgs, callback: { (tag) in
                    if tag {
                        MBProgressHUD.showSuccess("发送成功", toView: nil)
                        self.closeCurrentView()
                    }else{
                        MBProgressHUD.showError("发送失败", toView: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func ButtonAddClicked(sender: AnyObject) {
        self.presentViewController(ImgPickViewController, animated: true, completion: nil)
    }
    
    func AddImg(img:UIImage){
        let btn = imgButton
        btn.tag = imgs.count
        btn.setBackgroundImage(img, forState: .Normal)
        imgs.append(img)
        imgButtons.append(btn)
        StackViewImg.addArrangedSubview(btn)
        if btn.tag == 2 {
            ButtonAdd.hidden = true
        }
    }
    
    func imgButtonDelete(sender:UIButton){
        StackViewImg.removeArrangedSubview(sender)
        imgs.removeAtIndex(imgs.indexOf(sender.backgroundImageForState(.Normal)!)!)
        imgButtons.removeAtIndex(imgButtons.indexOf(sender)!)
        sender.removeFromSuperview()
        if ButtonAdd.hidden == true{
            ButtonAdd.hidden = false
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        AddImg(image)
        print(editingInfo)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}
