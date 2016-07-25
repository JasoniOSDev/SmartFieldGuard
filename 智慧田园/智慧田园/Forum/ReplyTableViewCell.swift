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
    @IBAction func ButtonSupportClicked(sender: AnyObject) {
        NetWorkManager.updateSession{ [weak self] in
            if let sSelf = self{
                TYRequest(.ReplySupport, parameters: ["postNo":sSelf.reply.postNo,"replySn":sSelf.reply.replySn]).TYresponseJSON(completionHandler: { (response) in
                    if response.result.isSuccess{
                        if let json = response.result.value as? [String:AnyObject]{
                            if let msg = json["message"] as? String where msg == "success"{
                                sSelf.reply.IfSupport = !sSelf.reply.IfSupport
                                sSelf.ButtonSupport.selected = sSelf.reply.IfSupport
                                sSelf.reply.agreeNum =  sSelf.reply.agreeNum + (sSelf.reply.IfSupport == true ? 1 : -1)
                                sSelf.ButtonSupport.setTitle("\(sSelf.reply.agreeNum)", forState: .Normal)
                            }
                        }
                    }
                })
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        ImgPhoto.layer.cornerRadius = 15
        ImgPhoto.clipsToBounds = true
    }


}
