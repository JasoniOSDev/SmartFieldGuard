//
//  ForumDetailViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import KeyboardMan
import MJRefresh
import MBProgressHUD
import STPopup
class ForumDetailViewController: TYViewController {
    
    @IBOutlet weak var ButtonAdd: UIButton!
    @IBOutlet weak var ButtonAddImg: UIButton!
    @IBOutlet weak var StackViewPhoto: UIStackView!
    @IBOutlet weak var ConstraintUsernameCenterY: NSLayoutConstraint!
    @IBOutlet weak var ConstraintContentViewTop: NSLayoutConstraint!
    @IBOutlet weak var ConstraintContentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var StackViewImageViews: UIStackView!
    @IBOutlet weak var LabelContent: UILabel!
    @IBOutlet weak var ViewRegionMSG: UIView!
    @IBOutlet weak var TextFieldSend: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LabelUserName: UILabel!
    @IBOutlet weak var ConstraintContentbarBottom: NSLayoutConstraint!
    @IBOutlet weak var LabelClass: UIButton!
    @IBOutlet weak var ButtonTime: UIButton!
    @IBOutlet weak var ImgPhoto: UIImageView!
    @IBOutlet weak var MainContentView: UIView!
    var preDragY:CGFloat!
    var forum:Forum!
    var replies = [Replay]()
    var pageIndex = 1
    var pageCount = 20
    var currentCount = 0
    let keyboardMan = KeyboardMan()
    var cellHeight = [Int:CGFloat]()
    var myForum = false
    lazy var cell:ReplyTableViewCell = {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(ReplyTableViewCell.reuseIdentifier) as! ReplyTableViewCell
        cell.frame.size.width = ScreenWidth
        return cell
    }()
    var contentViewFold = false{
        didSet{
            guard oldValue != contentViewFold else {return}
            contentViewFlodAction()
        }
    }
    lazy var tipAlertController:UIAlertController = {
        let alert = UIAlertController(title: nil, message: "点击回答 可将其设为最佳回复^_^", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .Default, handler: { (_) in
            TYUserDefaults.needShowForumTip.value = true
        }))
        return alert
    }()
    var contentRealHeight:CGFloat!
    var replaing = false
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
    lazy var imagePickViewController:UIImagePickerController = {
        let viewController = UIImagePickerController()
        viewController.allowsEditing = false
        viewController.delegate = self
        return viewController
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadDataFromNet()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first{
            var point = touch.locationInView(ViewRegionMSG)
            if(!ViewRegionMSG.pointInside(point, withEvent: event)){
                if(TextFieldSend.isFirstResponder()){
                    TextFieldSend.resignFirstResponder()
                }else{
                    if let view = touch.view where view.tag >= 111 && view.tag <= 113 {
                        MessagePhotoScanController.setImages(StackViewImageViews.subviews as! [UIImageView], imagesURL: forum.images, index: view.tag - 111)
                        MessagePhotoScanController.pushScanController()
                        return
                    }
                    point = touch.locationInView(MainContentView)
                    if(MainContentView.pointInside(point, withEvent: event)){
                        contentViewFold = !contentViewFold
                    }
                }
                return
            }
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    private func prepareUI(){
        tableViewConfigure()
        loadForum()
        self.title = "问题详情"
        keyboardMan.animateWhenKeyboardAppear = {
            [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            if let sSelf = self{
                sSelf.ConstraintContentbarBottom.constant = keyboardHeight
                sSelf.view.layoutIfNeeded()
            }
        }
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            if let sSelf = self {
                sSelf.ConstraintContentbarBottom.constant = sSelf.replyImages.count > 0 && sSelf.replaing == false ? 120 : 0
                sSelf.view.layoutIfNeeded()
            }
        }
        if TYUserDefaults.needShowForumTip.value == false{
            
            dispatch_after(dispatch_time( DISPATCH_TIME_NOW, Int64( 500 * NSEC_PER_MSEC)),dispatch_get_main_queue()) {
                self.presentViewController(self.tipAlertController, animated: true, completion: nil)
            }
        }
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
    
    private func calcHeightAtIndex(index:Int) -> CGFloat{
        //计算
        if cellHeight[index] == nil{
            cell.reply = replies[index]
            cell.layoutIfNeeded()
            cellHeight[index] = cell.NewContentView.frame.height + 8
        }
        return cellHeight[index]!
    }
    
    private func loadForum(){
        if forum.userId == TYUserDefaults.userID.value && self.forum.status == "Unsolved"{
            myForum = true
        }else{
            myForum = false
        }
        LabelUserName.text = self.forum.username
        ImgPhoto.sd_setImageWithURL(NSURL(string: self.forum.headImage.imageLowQualityURL())!)
        ButtonTime.setTitle(forum.createDate.dateDescription, forState: .Normal)
        LabelContent.text = self.forum.content
        
        StackViewImageViews.hidden = forum.images.count == 0
        let imageViews = StackViewImageViews.arrangedSubviews as! [UIImageView]
        for x in imageViews{
            x.hidden = true
        }
        for i in 0..<forum.images.count{
            imageViews[i].hidden = false
            imageViews[i].sd_setImageWithURL(NSURL(string: forum.images[i].imageLowQualityURL()))
        }
        
        MainContentView.layoutIfNeeded()
        //计算一下content的高度
        let height = LabelContent.frame.maxY + LabelClass.frame.height + 10 + (StackViewImageViews.hidden ? 0 : 90)
        contentRealHeight = height
        ConstraintContentViewHeight.constant = contentRealHeight
    }
    
    private func tableViewConfigure(){
        tableView.backgroundColor = UIColor.BackgroundColor()
        tableView.clearOtherLine()
        tableView.registerReusableCell(ReplyTableViewCell)
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.estimatedRowHeight = 80
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(self.loadDataFromNet))
    }
    
    func loadDataFromNet(){
        NetWorkManager.updateSession{
            let tableViewTmp = self.tableView
            TYRequest(.Reply, parameters: ["pageIndex":self.pageIndex + (self.currentCount == self.pageCount ? 1 : 0),"pageCount":self.pageCount,"postNo":self.forum.postNo]).TYresponseJSON { response in
                if response.result.isSuccess{
                    if let json = response.result.value as? [String:AnyObject] {
                        if let message = json["message"] as? String where message == "success"{
                            if let content = json["replyList"] as? [String:AnyObject]{
                                if let list = content["list"] as? NSArray{
                                    if self.currentCount == self.pageCount {
                                        self.currentCount = 0
                                    }
                                    self.pageIndex = content["pageIndex"] as! Int
                                    for i in self.currentCount..<list.count{
                                        if let dict = list[i] as? [String:AnyObject] {
                                            let forumObject = Replay(dict: dict)
                                            self.replies.append(forumObject)
                                        }
                                    }
                                    self.currentCount = content["currentCount"] as! Int
                                    tableViewTmp.mj_footer.endRefreshing()
                                    tableViewTmp.reloadData()
                                }else{
                                    tableViewTmp.mj_footer.endRefreshingWithNoMoreData()
                                    tableViewTmp.mj_footer.resetNoMoreData()
                                }
                            }
                        }
                        if let hasMore = json["hasMore"] as? NSNumber{
                            if (hasMore.boolValue == false){
                                tableViewTmp.mj_footer.state = .NoMoreData
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func contentViewFlodAction(){

        UIView.animateWithDuration(0.3,  animations: {
            if(self.contentViewFold){
                self.ConstraintContentViewHeight.constant = 99
                self.LabelContent.numberOfLines = 1
                self.StackViewImageViews.hidden = true
                self.ConstraintContentViewTop.constant = -10
                self.ConstraintUsernameCenterY.constant = -10
            }else{
                self.ConstraintContentViewHeight.constant = self.contentRealHeight
                self.ConstraintContentViewTop.constant = 3
                self.ConstraintUsernameCenterY.constant = 0
            }
            self.view.layoutIfNeeded()
            }) { (_) in
                if(!self.contentViewFold){
                    self.LabelContent.numberOfLines = 0
                    self.StackViewImageViews.hidden = !(self.forum.images.count > 0)
                }
        }
    }
    
    func MessageSendAction() {
        if let content = TextFieldSend.text {
            NetWorkManager.PushNewForumReplay(content, postno: self.forum.postNo, images: replyImages, callback: { (tag) in
                if tag == true {
                    MBProgressHUD.showSuccess("发送成功", toView: nil)
                    self.loadDataFromNet()
                }else{
                     MBProgressHUD.showError("发送失败", toView: nil)
                }
            })
        }
        for x in self.imgButtons{
            self.imgButtonDelete(x)
        }
        TextFieldSend.text = nil
        TextFieldSend.resignFirstResponder()
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

extension ForumDetailViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        AddImg(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}


extension ForumDetailViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        MessageSendAction()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        contentViewFold = true
    }
}

extension ForumDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        preDragY = scrollView.panGestureRecognizer.locationInView(self.view).y
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        preDragY = -1
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        preDragY = -1
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard  !contentViewFold  || preDragY != -1 else {return}
        let nowDragY = scrollView.panGestureRecognizer.locationInView(self.view).y
        guard nowDragY - preDragY < 0 else {return}
        contentViewFold = true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ReplyTableViewCell
        cell.reply = self.replies[indexPath.row]
        if myForum == true{
            cell.selectionStyle = .Default
        }else{
            cell.selectionStyle = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return calcHeightAtIndex(indexPath.row)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if myForum{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if replies[indexPath.row].userId == TYUserDefaults.userID.value {
                MBProgressHUD.showError("您不能选择自己", toView: nil)
            }else{
                let alertController = UIAlertController(title: "满意答案", message: "确定选择\(self.replies[indexPath.row].username)的回复为满意答案?", preferredStyle: .ActionSheet)
                alertController.addAction(UIAlertAction(title: "确定", style: .Default, handler: { [weak self] action in
                    if let sSelf = self {
                        NetWorkManager.updateSession({
                            TYRequest(.ForumChooseAgreedAnswer, parameters: ["postNo":sSelf.forum.postNo,"replySn":sSelf.replies[indexPath.row].replySn]).TYresponseJSON(completionHandler: { (response) in
                                sSelf.replies.removeAll()
                                sSelf.cellHeight.removeAll()
                                sSelf.currentCount = 0
                                sSelf.pageIndex = 1
                                sSelf.loadDataFromNet()
                                sSelf.myForum = false
                            })
                        })
                    }
                }))
                alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
}
