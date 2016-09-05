//
//  PhotoScanModel.swift
//  智慧田园
//
//  Created by jason on 2016/9/4.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class PhotoScanModel: NSObject {

    var preImageView:UIImageView!//为缩略图，并且用于提供一些值得计算
    var url:String!//图片的链接
    var preSize:CGSize!
    var aftSize:CGSize!
    var scale:CGFloat!
    var destinationImageWidth = (ScreenWidth - 20) //图片的目标宽度设置为屏幕宽度-40
    lazy var fromTransform:CGAffineTransform = {
        return CGAffineTransformMakeScale(self.preSize.width/self.aftSize.width, self.preSize.height/self.aftSize.height)
    }()
    
    lazy var toTransform:CGAffineTransform = {
        return CGAffineTransformMakeScale(1, 1)
    }()
    
    convenience init(preImageView:UIImageView,url:String){
        self.init()
        //缩略图的宽高比应该要与原图一致
        self.preImageView = preImageView
        self.url = url
        self.preSize = preImageView.frame.size
        self.scale = destinationImageWidth/preSize.width
        self.aftSize = CGSizeMake(destinationImageWidth, preSize.height * scale)
    }
    
    
}
