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
    
    enum NewStyle{
        case Forum
        case Expert
    }
    
    @IBOutlet weak var ButtonAdd: UIButton!
    @IBOutlet weak var TextViewContent: UITextView!
    @IBOutlet weak var StackViewAddPicture: UIStackView!
    @IBOutlet weak var ButtonContentClass: UIButton!
    @IBOutlet weak var StackViewImg: UIStackView!
    var finishBlock:((Bool)->Void)?
    var completeBlock:((Bool)->Void)?//发送完毕的回调
    var cropsID:String!
    var cropsName:String!
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
    
    lazy var ImgPickViewController:UIImagePickerController = {
        let viewController = UIImagePickerController()
        viewController.allowsEditing = false
        viewController.delegate = self
        return viewController
    }()
    
    var style:NewStyle = .Forum
    override func viewDidLoad() {
        super.viewDidLoad()
        switch style {
        case .Forum:
            self.title = "发问题"
        case .Expert:
            self.title = "专家咨询"
        }
        ButtonContentClass.setTitle(self.cropsName, forState: .Normal)
    }
    
    private func AddImg(img:UIImage){
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
    
    func clearContent(){
        guard TextViewContent != nil else{return}
        TextViewContent.text = nil
        for x in imgButtons{
            imgButtonDelete(x)
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
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func LeftButtonClicked(sender: UIBarButtonItem) {
        TextViewContent.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func RightBarButtonClicked(sender: AnyObject) {
        TextViewContent.resignFirstResponder()
        if style == .Forum{
            if let content = TextViewContent.text {
                NetWorkManager.PushNewForum(content, images: imgs, cropsID: self.cropsID,block:{tg in
                    if let block = self.completeBlock{
                        block(tg)
                    }
                })
                if let block = finishBlock{
                    block(imgs.count != 0)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }else{
            if let content = TextViewContent.text {
                let topic = ExpertTheme()
                topic.classifyID = cropsID
                topic.classifyName = cropsName
                topic.content = content 
                topic.headPhoto = TYUserDefaults.headImage.value
                topic.userID = TYUserDefaults.userID.value!
                NetWorkManager.PushNewExpertTopic(topic, images: imgs, callback: { tag in
                    if let block = self.completeBlock{
                        block(tag)
                    }
                })
                if let block = finishBlock{
                    block(imgs.count != 0)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    @IBAction func ButtonAddClicked(sender: AnyObject) {
        self.view.endEditing(true)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "从相册选择", style: .Default, handler: { [weak self] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else{
                MBProgressHUD.showError("访问相册失败", toView: nil)
                return
            }
            if let sSelf = self {
                sSelf.ImgPickViewController.sourceType = .PhotoLibrary
                sSelf.presentViewController(sSelf.ImgPickViewController, animated: true, completion: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: "拍照", style: .Default, handler: { [weak self] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.Camera) else{
                MBProgressHUD.showError("无法打开相机", toView: nil)
                return
            }
            if let sSelf = self {
                sSelf.ImgPickViewController.sourceType = .Camera
                sSelf.presentViewController(sSelf.ImgPickViewController, animated: true, completion: nil)
            }

        }))
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}
