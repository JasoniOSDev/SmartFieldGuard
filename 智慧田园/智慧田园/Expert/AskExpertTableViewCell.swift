//
//  AskExpertTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class AskExpertTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var StackViewImageView: UIStackView!
    @IBOutlet weak var LabelClassify: UILabel!
    @IBOutlet weak var ConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var LabelContent: UILabel!
    @IBOutlet weak var ButtonTime: UIButton!
    @IBOutlet weak var ImageViewReplayTag: UIImageView!
    @IBOutlet weak var ImageViewHead: UIImageView!
    @IBOutlet weak var newContentView: UIView!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewThd: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    var theme:ExpertTheme!{
        didSet{
            for x in self.imageViews{
                x.hidden = true
            }
            if theme.images == nil || theme.images.count == 0 {
                ConstraintBottom.constant = 44
            }else{
                for x in theme.images.enumerate(){
                    self.imageViews[x.index].sd_setImageWithURL(NSURL(string: x.element))
                    self.imageViews[x.index].hidden = false
                }
                ConstraintBottom.constant = 124
            }
            self.ButtonTime.setTitle(theme.time, forState: .Normal)
            self.ImageViewHead.sd_setImageWithURL(NSURL(string: theme.headPhoto))
            self.LabelContent.text = theme.content
            self.ImageViewReplayTag.hidden = !theme.unRead
            //由于服务器没有存储类名，所以此处需要从本地获取
            if theme.classifyName == ""{
                try! ModelManager.realm.write({ 
                    theme.classifyName = (ModelManager.getObjects(LocalCrops).filter("self.id = %@", theme.classifyID).first?.name)!
                })
            }
            self.LabelClassify.text = theme.classifyName
        }
    }
    var imageViews = [UIImageView]();
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.BackgroundColor()
        newContentViewUI()
        imageViews.appendContentsOf([imageViewOne,imageViewTwo,imageViewThd])
        ImageViewHead.layer.cornerRadius = 17.5
        ImageViewHead.clipsToBounds = true
        for x in imageViews{
            x.layer.cornerRadius = 4
            x.clipsToBounds = true
        }
    }
    
    func newContentViewUI(){
        newContentView.layer.shadowColor = UIColor.LowBlackColor().CGColor
        newContentView.layer.shadowOffset = CGSizeMake(1, 1.5)
        newContentView.layer.shadowRadius = 2
        newContentView.layer.shadowOpacity = 1
        newContentView.layer.cornerRadius = 4
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = touches.first?.view where (view.tag >= 101 && view.tag <= 103){
            let index = view.tag - 101
            var array = [UIImageView]()
            for x in imageViews where x.hidden == false{
                array.append(x.copy() as! UIImageView)
            }
            MessagePhotoScanController.setImages(array, index: index, fromPoint: StackViewImageView.convertPoint(imageViews[index].center, toView: MessagePhotoScanController.shareMessagePhotoScan.view))
            MessagePhotoScanController.pushScanController()
            return
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
}
