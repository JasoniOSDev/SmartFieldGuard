//
//  MyReplyTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class MyReplyTableViewCell: UITableViewCell,Reusable {
    
    @IBOutlet weak var LabelContent: UILabel!
    @IBOutlet weak var newContentView: UIView!
    @IBOutlet weak var ImageViewHead: UIImageView!
    @IBOutlet weak var ButtonTime: UIButton!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewThd: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var ConstraintBottom: NSLayoutConstraint!
    var imageViews = [UIImageView]()
    
    var content:String!{
        didSet{
            LabelContent.text = content
        }
    }
    
    var message:ExpertMessage!{
        didSet{
            self.content = message.content
            self.ImageViewHead.sd_setImageWithURL(NSURL(string: message.headPhoto.imageLowQualityURL()))
            self.ButtonTime.setTitle(message.time, forState: .Normal)
            for x in self.imageViews{
                x.hidden = true
            }
            
            if message.images == nil || message.images.count == 0 {
                ConstraintBottom.constant = 15
            }else{
                ConstraintBottom.constant = 95
                for x in message.images.enumerate(){
                    self.imageViews[x.index].sd_setImageWithURL(NSURL(string: x.element.imageLowQualityURL()))
                    self.imageViews[x.index].hidden = false
                }
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.BackgroundColor()
        newContentViewUI()
        imageViews.appendContentsOf([imageViewOne,imageViewTwo,imageViewThd])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = touches.first?.view as? UIImageView where (view.tag >= 101 && view.tag <= 103) && view.image != nil{
            let index = view.tag - 101
            MessagePhotoScanController.setImages(imageViews, imagesURL: message.images, index: index)
            MessagePhotoScanController.pushScanController()
            return
        }
        super.touchesBegan(touches, withEvent: event)
    }

    func newContentViewUI(){
//        newContentView.layer.shadowColor = UIColor.LowBlackColor().CGColor
//        newContentView.layer.shadowOffset = CGSizeMake(1, 1.5)
//        newContentView.layer.shadowRadius = 2
//        newContentView.layer.shadowOpacity = 1
        newContentView.layer.cornerRadius = 4
    }
}
