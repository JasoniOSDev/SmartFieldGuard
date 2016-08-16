//
//  ReplyTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class ReplyTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var ImgFinalAnswer: UIImageView!
    @IBOutlet weak var ImgPhoto: UIImageView!
    @IBOutlet weak var NewContentView: UIView!
    @IBOutlet weak var LabelUserName: UILabel!
    @IBOutlet weak var LabelTime: UILabel!
    @IBOutlet weak var ButtonSupport: UIButton!
    @IBOutlet weak var LabelContent: UILabel!
    var reply:Replay!{
        didSet{
            ImgPhoto.sd_setImageWithURL(NSURL(string: reply.headImage)!)
            LabelUserName.text = reply.username
            LabelTime.text = reply.replyDate.ReplyDateDescription
            ButtonSupport.selected = reply.IfSupport
            ButtonSupport.setTitle("\(reply.agreeNum)", forState: .Normal)
            LabelContent.text = reply.content
            if reply.replySn == 0{
                ImgFinalAnswer.hidden = false
            }else{
                ImgFinalAnswer.hidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImgPhoto.layer.cornerRadius = 15
        ImgPhoto.clipsToBounds = true
    }
    
    @IBAction func ButtonSupportClicked(sender: AnyObject) {
        NetWorkManager.updateSession{
            TYRequest(.ReplySupport, parameters: ["postNo":self.reply.postNo,"replySn":self.reply.replySn]).TYresponseJSON(completionHandler: { (response) in
                    if response.result.isSuccess{
                        if let json = response.result.value as? [String:AnyObject]{
                            if let msg = json["message"] as? String where msg == "success"{
                                self.reply.IfSupport = !self.reply.IfSupport
                                self.ButtonSupport.selected = self.reply.IfSupport
                                self.reply.agreeNum =  self.reply.agreeNum + (self.reply.IfSupport == true ? 1 : -1)
                                self.ButtonSupport.setTitle("\(self.reply.agreeNum)", forState: .Normal)
                            }
                        }
                    }
                })
        }
    }
}
