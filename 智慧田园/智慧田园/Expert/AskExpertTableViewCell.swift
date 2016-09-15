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
            
            //由于服务器没有存储类名，所以此处需要从本地获取
            if theme.classifyName == ""{
                try! ModelManager.realm.write({
                    if let name = ModelManager.getObjects(LocalCrops).filter("self.id = %@", theme.classifyID).first?.name{
                        theme.classifyName = name
                    }else{
                        theme.classifyName = ""
                    }
                })
                return 
            }
            
            for x in self.imageViews{
                x.hidden = true
            }
            
            if theme.images == nil || theme.images.count == 0 {
                ConstraintBottom.constant = 44
            }else{
                ConstraintBottom.constant = 124
                for x in theme.images.enumerate(){
                    self.imageViews[x.index].sd_setImageWithURL(NSURL(string: x.element.imageLowQualityURL()))
                    self.imageViews[x.index].hidden = false
                }
            }
            
            self.ButtonTime.setTitle(theme.time, forState: .Normal)
            self.ImageViewHead.sd_setImageWithURL(NSURL(string: theme.headPhoto.imageLowQualityURL()))
            self.LabelContent.text = theme.content
            self.ImageViewReplayTag.hidden = !theme.unRead
            self.LabelClassify.text = theme.classifyName
        }
    }
    var imageViews = [UIImageView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.BackgroundColor()
        newContentViewUI()
        imageViews.appendContentsOf([imageViewOne,imageViewTwo,imageViewThd])
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = touches.first?.view as? UIImageView where (view.tag >= 101 && view.tag <= 103) && view.image != nil{
            let index = view.tag - 101
            MessagePhotoScanController.setImages(imageViews, imagesURL: theme.images, index: index)
            MessagePhotoScanController.pushScanController()
            return
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    func newContentViewUI(){
        newContentView.layer.cornerRadius = 4
    }
}
