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
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewThd: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
        var imageViews = [UIImageView]()
    @IBOutlet weak var ConstraintBottom: NSLayoutConstraint!
    var reply:Replay!{
        didSet{
            ImgPhoto.sd_setImageWithURL(NSURL(string: reply.headImage.imageLowQualityURL())!)
            LabelUserName.text = reply.username
            LabelTime.text = reply.replyDate.dateDescription
            ButtonSupport.selected = reply.IfSupport
            ButtonSupport.setTitle("\(reply.agreeNum)", forState: .Normal)
            LabelContent.text = reply.content
            if reply.replySn == 0{
                ImgFinalAnswer.hidden = false
            }else{
                ImgFinalAnswer.hidden = true
            }
            for x in imageViews{
                x.hidden = true
            }
            if reply.images.count == 0 {
                ConstraintBottom.constant = 15
            }else{
                ConstraintBottom.constant = 100
                for x in reply.images.enumerate(){
                    self.imageViews[x.index].sd_setImageWithURL(NSURL(string: x.element.imageLowQualityURL()))
                    self.imageViews[x.index].hidden = false
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImgPhoto.layer.cornerRadius = 15
        ImgPhoto.clipsToBounds = true
         imageViews.appendContentsOf([imageViewOne,imageViewTwo,imageViewThd])
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
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = touches.first?.view as? UIImageView where (view.tag >= 101 && view.tag <= 103) && view.image != nil{
            let index = view.tag - 101
            MessagePhotoScanController.setImages(imageViews, imagesURL: reply.images, index: index)
            MessagePhotoScanController.pushScanController()
            return
        }
        super.touchesEnded(touches, withEvent: event)
    }
}
