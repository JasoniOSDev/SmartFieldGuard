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

    @IBOutlet weak var ViewRegionMSG: UIView!//输入框所在的视图
    @IBOutlet weak var TextFieldSend: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ConstraintContentbarBottom: NSLayoutConstraint!
    var cellHeights = [Int:CGFloat]()
    let keyboardMan = KeyboardMan()
    var messages:Results<ExpertMessage>?
    var token:NotificationToken?
    lazy var ReplyCell:MyReplyTableViewCell = {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(MyReplyTableViewCell.reuseIdentifier) as! MyReplyTableViewCell
        cell.frame.size.width = self.view.frame.size.width
        return cell
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    private func prepareUI(){
        tableViewConfigure()
        keyboardManConfigure()
        self.title = "详情"
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
                strongSelf.ConstraintContentbarBottom.constant = 0
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
        self.TextFieldSend.resignFirstResponder()
        if let content = TextFieldSend.text{
            let message = ExpertMessage()
            message.Theme = self.theme
            message.content = content
            message.headPhoto = TYUserDefaults.headImage.value
            message.name = TYUserDefaults.username.value!
            message.userID = TYUserDefaults.userID.value!
            NetWorkManager.PushNewExpertReplay(message, postID: theme.ID,callback: {
                tag in
                if tag == false{
                    MBProgressHUD.showError("发送失败", toView: nil)
                    self.TextFieldSend.becomeFirstResponder()
                }else{
                    self.TextFieldSend.text = nil
                }
            })
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first{
            let point = touch.locationInView(ViewRegionMSG)
            if(!ViewRegionMSG.pointInside(point, withEvent: event)){
                TextFieldSend.resignFirstResponder()
            }
        }
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
