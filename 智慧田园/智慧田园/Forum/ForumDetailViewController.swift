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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        loadDataFromNet()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
                sSelf.ConstraintContentbarBottom.constant = 0
                sSelf.view.layoutIfNeeded()
            }
        }
        if TYUserDefaults.needShowForumTip.value == false{
            
            dispatch_after(dispatch_time( DISPATCH_TIME_NOW, Int64( 500 * NSEC_PER_MSEC)),dispatch_get_main_queue()) {
                self.presentViewController(self.tipAlertController, animated: true, completion: nil)
            }
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
                        }else{
//                            print(json["message"])
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
            NetWorkManager.updateSession({
                TYRequest(.PushAReply, parameters: ["content":content,"postNo":self.forum.postNo]).TYresponseJSON(completionHandler: { (response) in
                    if response.result.isSuccess{
                        if let json = response.result.value as? [String:AnyObject]{
                            if let msg = json["message"] as? String where msg == "success"{
                                dispatch_async(dispatch_get_main_queue(), { 
                                    MBProgressHUD.showSuccess("发送成功", toView: nil)
                                    self.loadDataFromNet()
                                })
                            }else{
                                dispatch_async(dispatch_get_main_queue(), {
                                    MBProgressHUD.showError("发送失败", toView: nil)
                                })
                            }
                        }
                    }
                })
            })
        }
        TextFieldSend.text = nil
        TextFieldSend.resignFirstResponder()
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard  !contentViewFold else {return}
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
