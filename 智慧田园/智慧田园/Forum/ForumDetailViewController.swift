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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ConstraintViewTipTop: NSLayoutConstraint!
    @IBOutlet weak var ViewTip: UIView!
    @IBOutlet weak var LabelUserName: UILabel!
    @IBOutlet weak var TextViewContent: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TextFieldSend: UITextField!
    @IBOutlet weak var ConstraintContentbarBottom: NSLayoutConstraint!
    @IBOutlet weak var ConstraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var LabelClass: UIButton!
    @IBOutlet weak var ButtonTime: UIButton!
    @IBOutlet weak var ImgPhoto: UIImageView!
    @IBOutlet weak var ConstraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var MainContentView: UIView!
    var MainContentViewScale = true
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
    
    func calcHeightAtIndex(index:Int) -> CGFloat{
        //计算
        if cellHeight[index] == nil{
            cell.reply = replies[index]
            cell.layoutIfNeeded()
            cellHeight[index] = cell.NewContentView.frame.height
        }
        return cellHeight[index]!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConstraintTableViewHeight.constant = ScreenHeight
        ImgPhoto.layer.cornerRadius = 17.5
        ImgPhoto.clipsToBounds = true
        tableViewConfigure()
        loadForum()
        keyboardMan.animateWhenKeyboardAppear = {
            [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            if let strongSelf = self{
                strongSelf.ConstraintContentbarBottom.constant = keyboardHeight
                strongSelf.view.layoutIfNeeded()
            }
        }
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            
            if let strongSelf = self {
                
                strongSelf.ConstraintContentbarBottom.constant = 0
                strongSelf.view.layoutIfNeeded()
            }
        }
        
        loadDataFromNet()
        
    }
    
    func loadForum(){
        if forum.userId == TYUserDefaults.userID.value && self.forum.status == "Unsolved"{
            ConstraintViewTipTop.constant = 0
            myForum = true
        }else{
            ConstraintViewTipTop.constant = -30
        }
        LabelUserName.text = self.forum.username
        ImgPhoto.sd_setImageWithURL(NSURL(string: self.forum.headImage)!)
        ButtonTime.setTitle(forum.createDate.ForumDateDescription, forState: .Normal)
        TextViewContent.text = self.forum.content
    }
    
    func TagGestureToScrollView() {
        TextFieldSend.resignFirstResponder()
    }
    
    func tableViewConfigure(){
        tableView.clearOtherLine()
        tableView.registerReusableCell(ReplyTableViewCell)
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(self.loadDataFromNet))
    }
    
    func loadDataFromNet(){
        NetWorkManager.updateSession{ [weak self] in
            if let sSelf = self{
                let tableViewTmp = sSelf.tableView
                TYRequest(.Reply, parameters: ["pageIndex":sSelf.pageIndex + (sSelf.currentCount == sSelf.pageCount ? 1 : 0),"pageCount":sSelf.pageCount,"postNo":sSelf.forum.postNo]).TYresponseJSON { response in
                    print(response)
                    if response.result.isSuccess{
                        if let json = response.result.value as? [String:AnyObject] {
                            if let message = json["message"] as? String where message == "success"{
                                if let content = json["replyList"] as? [String:AnyObject]{
                                    if let list = content["list"] as? NSArray{
                                        if sSelf.currentCount == sSelf.pageCount {
                                            sSelf.currentCount = 0
                                        }
                                        sSelf.pageIndex = content["pageIndex"] as! Int
                                        for i in sSelf.currentCount..<list.count{
                                            if let dict = list[i] as? [String:AnyObject] {
                                                let forumObject = Replay(dict: dict)
                                                sSelf.replies.append(forumObject)
                                            }
                                        }
                                        sSelf.currentCount = content["currentCount"] as! Int
                                        tableViewTmp.mj_footer.endRefreshing()
                                        tableViewTmp.reloadData()
                                    }else{
                                        tableViewTmp.mj_footer.endRefreshingWithNoMoreData()
                                        tableViewTmp.mj_footer.resetNoMoreData()
                                    }
                                }
                            }else{
                                print(json["message"])
                            }
                        }
                    }
                }
            }
        }
    }

    @IBAction func ButtonHidenContentView(sender: AnyObject) {
        TapGestureContentViewTap()
    }
    func TapGestureContentViewTap() {
        MainContentViewScale = !ConstraintContentHeight.active
        UIView.animateWithDuration(0.5) {
            [weak self] in
            if let sSelf = self{
                sSelf.ConstraintContentHeight.active = !sSelf.ConstraintContentHeight.active
                sSelf.view.layoutIfNeeded()
            }
        }
    }
    @IBAction func ButtonSenderClicked(sender: UIButton) {
        if let content = TextFieldSend.text {
            NetWorkManager.updateSession({[weak self] in
                if let sSelf = self {
                    TYRequest(.PushAReply, parameters: ["content":content,"postNo":sSelf.forum.postNo]).TYresponseJSON(completionHandler: { (response) in
                        if response.result.isSuccess{
                            if let json = response.result.value as? [String:AnyObject]{
                                if let msg = json["message"] as? String where msg == "success"{
                                    dispatch_async(dispatch_get_main_queue(), { 
                                        MBProgressHUD.showSuccess("发送成功", toView: nil)
                                        sSelf.loadDataFromNet()
                                    })
                                }else{
                                    dispatch_async(dispatch_get_main_queue(), {
                                        MBProgressHUD.showError("发送失败", toView: nil)
                                    })
                                }
                            }
                        }
                    })
                }
            })
        }
        TextFieldSend.text = nil
        TextFieldSend.resignFirstResponder()
    }

}

extension ForumDetailViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ForumDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard MainContentViewScale == false else {return}
        UIView.animateWithDuration(0.5) {
            [weak self] in
            if let sSelf = self{
                sSelf.ConstraintContentHeight.active = !sSelf.ConstraintContentHeight.active
                sSelf.view.layoutIfNeeded()
            }
        }
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
                                print(response)
                            })
                        })
                    }
                }))
                alertController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}
