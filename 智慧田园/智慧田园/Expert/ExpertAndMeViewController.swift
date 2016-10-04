 //
//  ExpertAndMeViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import KeyboardMan
import RealmSwift
import MBProgressHUD
class ExpertAndMeViewController: TYViewController {

    @IBOutlet weak var ButtonAddImg: UIButton!
    @IBOutlet weak var StackViewPhoto: UIStackView!
    @IBOutlet weak var ViewRegionMSG: UIView!//输入框所在的视图
    @IBOutlet weak var ButtonAdd: UIButton!
    @IBOutlet weak var TextFieldSend: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ConstraintContentbarBottom: NSLayoutConstraint!
    var replaing = false//是否正在发送回复
    var cellHeights = [Int:CGFloat]()
    let keyboardMan = KeyboardMan()
    var messages:Results<ExpertMessage>?
    var token:NotificationToken?
    var replyImages = [UIImage](){
        didSet{
            if replaing == true {
                return
            }
            UIView.animateWithDuration(0.3) { 
                if self.replyImages.count > 0{
                    if self.ConstraintContentbarBottom.constant != 120{
                        self.ConstraintContentbarBottom.constant = 120
                    }
                    
                   self.ButtonAdd.setImage(UIImage(named: "Forum_Send"),forState: .Normal)
                }else{
                    self.ConstraintContentbarBottom.constant = 0
                    self.ButtonAdd.setImage(UIImage(named: "item_more"),forState: .Normal)
                }
                self.view.layoutIfNeeded()
            }
        }
    }
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
    lazy var ReplyCell:MyReplyTableViewCell = {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MyReplyTableViewCell.reuseIdentifier) as! MyReplyTableViewCell
        cell.frame.size.width = self.view.frame.size.width
        return cell
    }()
    
    lazy var imagePickViewController:UIImagePickerController = {
        let viewController = UIImagePickerController()
        viewController.allowsEditing = false
        viewController.delegate = self
        return viewController
    }()
    
    lazy var buttonCompletion:UIBarButtonItem = {
        let barButton = UIBarButtonItem(title: "完成", style: .Plain, target: self, action: #selector(self.TopicCompletionAction))
        return barButton
    }()
    
    var theme:ExpertTheme!{
        didSet{
            cellHeights.removeAll()
            self.messages = ModelManager.getObjects(ExpertMessage).filter("self.Theme.ID == %@", theme.ID).sorted("timeInterval", ascending: true)
            theme.setRead()
            if token == nil {
                token = self.messages?.addNotificationBlock({ [weak self ]change in
                    switch change{
                    case .Initial(_):
                        self?.tableView.reloadData()
                        self?.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: (self?.messages!.count)!, inSection: 0), atScrollPosition: .Bottom, animated: false)
                    case .Update(_, deletions: _, insertions: let insertions, modifications: _):
                        if self?.tableView != nil {
                            if insertions.count>0{
                                self?.theme.setRead()
                                self?.tableView.insertRowsAtIndexPaths(insertions.map{NSIndexPath(forRow: $0 + 1, inSection: 0)}, withRowAnimation: .Automatic)
                                self?.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: (self?.messages?.count)!, inSection: 0), atScrollPosition: .Bottom, animated: true)
                            }
                        }
                    case .Error(_):break
                    }
                })
            }
        }
    }
    var user:(name:String,photo:String,id:String) = ("Jasooon","http://funwewhere.com/upload/SZTY/UserHead/US001609070001.png","US001609070001")
    
    lazy var experPresentController:ExpertPresentViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSizeMake(100, 40)
        let viewController = ExpertPresentViewController(collectionViewLayout: layout)
        viewController.user = (self.user.name,self.user.photo)
        viewController.contentSizeInPopup = CGSizeMake(ScreenWidth-40, 300)
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        keyboardManConfigure()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.locationInView(ViewRegionMSG)
            if(!ViewRegionMSG.pointInside(point, withEvent: event)){
                TextFieldSend.resignFirstResponder()
            }
        }
    }
    
    private func prepareUI(){
        tableViewConfigure()
        CompletionBarButtonItemConfigure()
        self.title = "详情"
    }
    
    private func AddImg(img:UIImage){
        let btn = imgButton
        btn.tag = replyImages.count
        btn.setBackgroundImage(img, forState: .Normal)
        replyImages.append(img)
        imgButtons.append(btn)
        StackViewPhoto.addArrangedSubview(btn)
        if btn.tag == 2 {
            ButtonAddImg.hidden = true
            
        }
    }
    
    private func CompletionBarButtonItemConfigure(){
        
        if (theme.status & ExpertTheme.ThemeStatus.Finish.rawValue) > 0{
            self.navigationItem.rightBarButtonItem = buttonCompletion
            buttonCompletion.title = "打赏"
            buttonCompletion.tintColor = UIColor.WarnColor()
        }else{
            if theme.userID == TYUserDefaults.userID.value! && TYUserDefaults.role.value == "NormalMember"{
                 self.navigationItem.rightBarButtonItem = buttonCompletion
                buttonCompletion.title = "完成"
                buttonCompletion.tintColor = UIColor.MainColor()
            }
        }
    }
    
    private func keyboardManConfigure(){
        keyboardMan.animateWhenKeyboardAppear = {
            [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            if let strongSelf = self{
                strongSelf.ConstraintContentbarBottom.constant = keyboardHeight
                strongSelf.view.layoutIfNeeded()
            }
        }
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            if let strongSelf = self {
                strongSelf.ConstraintContentbarBottom.constant = strongSelf.replyImages.count > 0 && strongSelf.replaing == false ? 120 : 0
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
    
    private func tableViewConfigure(){
        tableView.registerReusableCell(AskExpertTableViewCell)
        tableView.registerReusableCell(ExpertReplyTableViewCell)
        tableView.registerReusableCell(MyReplyTableViewCell)
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.BackgroundColor()
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView.contentOffset = CGPointMake(0, -10)
        tableView.clearOtherLine()
        tableView.reloadData()
    }
    
    private func cellHeightForIndex(index:Int) -> CGFloat{
        guard messages != nil else {return 0 }
        let key =  index == 0 ? 0 : messages![index - 1].replySn
        if cellHeights[key] == nil {
            switch index {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier(AskExpertTableViewCell.reuseIdentifier) as! AskExpertTableViewCell
                cell.frame.size.width = self.view.frame.size.width
                cell.theme = self.theme
                cell.layoutIfNeeded()
                cellHeights[key] = cell.newContentView.frame.height + 5
            default:
                ReplyCell.message = messages![index - 1]
                ReplyCell.layoutIfNeeded()
                cellHeights[key] = ReplyCell.newContentView.frame.height + 5
            }
        }
        return cellHeights[key]!
    }
    
    func MessageSendAction() {
        if replaing == true {
            MBProgressHUD.showError("上次回复正在发送", toView: nil)
            return
        }
        replaing = true
        UIView.animateWithDuration(0.3) { 
            self.ConstraintContentbarBottom.constant = 0
            self.view.layoutIfNeeded()
        }
        self.TextFieldSend.resignFirstResponder()
        if let content = TextFieldSend.text{
            let message = ExpertMessage()
            message.Theme = self.theme
            message.content = content
            message.headPhoto = TYUserDefaults.headImage.value
            message.name = TYUserDefaults.username.value!
            message.userID = TYUserDefaults.userID.value!
            NetWorkManager.PushNewExpertReplay(message, postID: theme.ID,images: replyImages,callback: {
                tag in
                self.replaing = false
                if tag == false{
                    MBProgressHUD.showError("发送失败", toView: nil)
                    self.TextFieldSend.becomeFirstResponder()
                }else{
                    for x in self.imgButtons{
                        self.imgButtonDelete(x)
                    }
                    self.TextFieldSend.text = nil
                }
            })
        }
    }

    func TopicCompletionAction(){
        //话题完成所要执行的操作
        if !((theme.status & ExpertTheme.ThemeStatus.Finish.rawValue) > 0){
            NetWorkManager.updateSession({
                TYRequest(.ForumChooseAgreedAnswer, parameters: ["postNo":self.theme.ID]).TYResponseJSON(Block: { (JSON) in
                    if let msg = JSON["message"] as? String where msg == "success"
                    {
                        try! ModelManager.realm.write({ 
                            self.theme.status |= ExpertTheme.ThemeStatus.Finish.rawValue
                            self.CompletionBarButtonItemConfigure()
                        })
                    }})
            })
        }else{
            experPresentController.PushViewControllerInViewController(self)
        }
    }
    
    func imgButtonDelete(sender:UIButton){
        StackViewPhoto.removeArrangedSubview(sender)
        replyImages.removeAtIndex(replyImages.indexOf(sender.backgroundImageForState(.Normal)!)!)
        imgButtons.removeAtIndex(imgButtons.indexOf(sender)!)
        sender.removeFromSuperview()
        if ButtonAddImg.hidden == true{
            ButtonAddImg.hidden = false
        }
    }
    
    @IBAction func ButtonMoreClicked() {
        if(replyImages.count > 0){
            MessageSendAction()
        }else{
            ButtonAddClicked()
        }
    }
    
    @IBAction func ButtonAddClicked() {
        self.view.endEditing(true)
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "从相册选择", style: .Default, handler: { [weak self] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) else{
                MBProgressHUD.showError("访问相册失败", toView: nil)
                return
            }
            if let sSelf = self {
                sSelf.imagePickViewController.sourceType = .PhotoLibrary
                sSelf.presentViewController(sSelf.imagePickViewController, animated: true, completion: nil)
            }
            }))
        alertController.addAction(UIAlertAction(title: "拍照", style: .Default, handler: { [weak self] _ in
            guard UIImagePickerController.isSourceTypeAvailable(.Camera) else{
                MBProgressHUD.showError("无法打开相机", toView: nil)
                return
            }
            if let sSelf = self {
                sSelf.imagePickViewController.sourceType = .Camera
                sSelf.presentViewController(sSelf.imagePickViewController, animated: true, completion: nil)
            }
            
            }))
        alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    
}
 
 extension ExpertAndMeViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        AddImg(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
 }
 
extension ExpertAndMeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        MessageSendAction()
        return true
    }
}

extension ExpertAndMeViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (messages == nil ? 0 : messages!.count)+1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AskExpertTableViewCell
            cell.theme = self.theme
            return cell
        }else{
            if messages![indexPath.row - 1].userID == theme.userID{
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as MyReplyTableViewCell
                cell.message = messages![indexPath.row - 1]
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ExpertReplyTableViewCell
                cell.message = messages![indexPath.row - 1]
                return cell
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeightForIndex(indexPath.row)
    }
}
