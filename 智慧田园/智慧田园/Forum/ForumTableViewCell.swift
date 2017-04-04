//
//  ForumTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import SDWebImage
class ForumTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var LabelName: UILabel!
    @IBOutlet weak var StackViewImgButton: UIStackView!
    @IBOutlet weak var ImgTipSolved: UIImageView!
    @IBOutlet weak var NewContentView: UIView!
    @IBOutlet weak var ImgPhoto: UIImageView!
    @IBOutlet weak var LabelContent: UILabel!
    @IBOutlet weak var ConstraintLabelBottom: NSLayoutConstraint!
    @IBOutlet weak var LabelTime: UIButton!
    @IBOutlet weak var ImageViewOne: UIImageView!
    @IBOutlet weak var ImageViewTwo: UIImageView!
    @IBOutlet weak var ImageViewThd: UIImageView!
    var imageViews = [UIImageView]()
    var forum:Forum!
    var haveImg:Bool = false{
        didSet{
            StackViewImgButton.hidden = !haveImg
            ConstraintLabelBottom.active = haveImg
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageViews.append(ImageViewOne)
        imageViews.append(ImageViewTwo)
        imageViews.append(ImageViewThd)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = touches.first?.view as? UIImageView where (view.tag >= 101 && view.tag <= 103) && view.image != nil{
            let index = view.tag - 101
            MessagePhotoScanController.setImages(imageViews, imagesURL: forum.images, index: index)
            MessagePhotoScanController.pushScanController()
            return
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    func loadData(){
        if self.forum.images.count > 0{
            haveImg = true
        }else{
            haveImg = false
        }
        
        for btn in imageViews {
            btn.hidden = true
        }
        //可能没有图片，采用默认图片，后期修改
        ImgPhoto.sd_setImageWithURL(NSURL(string:forum.headImage.imageLowQualityURL())!)
        LabelName.text = forum.username
        LabelContent.text = forum.content
        LabelTime.setTitle(forum.createDate.dateDescription, forState: .Normal)
        for i in 0..<forum.images.count{
            imageViews[i].sd_setImageWithURL(NSURL(string: forum.images[i].imageLowQualityURL()))
            imageViews[i].hidden = false
        }
    }
    
}
