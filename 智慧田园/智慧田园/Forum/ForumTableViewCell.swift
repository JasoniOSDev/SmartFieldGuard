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
    var haveImg:Bool = false{
        didSet{
            if haveImg == false{
                ConstraintLabelBottom.constant = 20
            }else{
                ConstraintLabelBottom.constant = 110
            }
        }
    }
    var forum:Forum!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ImgPhoto.layer.cornerRadius = 17.5
        ImgPhoto.clipsToBounds = true
        imageViews.append(ImageViewOne)
        imageViews.append(ImageViewTwo)
        imageViews.append(ImageViewThd)
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
        ImgPhoto.sd_setImageWithURL(NSURL(string:forum.headImage)!)
        LabelContent.text = forum.content
        LabelTime.setTitle(forum.createDate.ForumDateDescription, forState: .Normal)
        for i in 0..<forum.images.count{
            imageViews[i].sd_setImageWithURL(NSURL(string: forum.images[i]))
            imageViews[i].hidden = false
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let view = touches.first?.view where (view.tag >= 101 && view.tag <= 103){
            let index = view.tag - 101
            var array = [UIImageView]()
            for x in imageViews where x.hidden == false{
                array.append(x.copy() as! UIImageView)
            }
            MessagePhotoScanController.setImages(array, index: index, fromPoint: StackViewImgButton.convertPoint(imageViews[index].center, toView: MessagePhotoScanController.shareMessagePhotoScan.view))
            MessagePhotoScanController.pushScanController()
            return
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    
}
