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
    var content:String!{
        didSet{
            LabelContent.text = content
        }
    }
    
    var message:ExpertMessage!{
        didSet{
            self.content = message.content
            self.ImageViewHead.sd_setImageWithURL(NSURL(string: message.headPhoto))
            self.ButtonTime.setTitle(message.time, forState: .Normal)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.BackgroundColor()
        newContentViewUI()
        ImageViewHead.layer.cornerRadius = 17.5
        ImageViewHead.clipsToBounds = true
    }

    func newContentViewUI(){
        newContentView.layer.shadowColor = UIColor.LowBlackColor().CGColor
        newContentView.layer.shadowOffset = CGSizeMake(1, 1.5)
        newContentView.layer.shadowRadius = 2
        newContentView.layer.shadowOpacity = 1
        newContentView.layer.cornerRadius = 4
    }
}
