//
//  PhotoScanCollectionViewCell.swift
//  智慧田园
//
//  Created by jason on 2016/9/4.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import YYWebImage
class PhotoScanCollectionViewCell: UICollectionViewCell,Reusable,UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var lastTapTime:NSDate = NSDate()
    var doubleTap = false
    let backView = UIView()
    var origionSize:CGSize!
    override func awakeFromNib() {
        super.awakeFromNib()
        backViewConfigure()
        scrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight)
        scrollView.delegate = self
        scrollView.multipleTouchEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delaysContentTouches = false
        scrollView.maximumZoomScale = 2.5
        scrollView.minimumZoomScale = 1.0
        scrollView.bouncesZoom = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2)
    }
    
    private func backViewConfigure(){
        self.backgroundColor = UIColor.clearColor()
        self.contentView.backgroundColor = UIColor.clearColor()
        self.contentView.insertSubview(backView, belowSubview: scrollView)
        backView.backgroundColor = UIColor.blackColor()
        backView.alpha = 0.6
        backView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight)
    }

    func loadImage(placehold:UIImage,url:String){
        imageView.yy_setImageWithURL(NSURL(string: url), placeholder: placehold, options: [.ProgressiveBlur,.SetImageWithFadeAnimation,.ShowNetworkActivity], completion: nil)
    }
    
    func setImageViewSize(size:CGSize){
        imageView.frame.size = size
        origionSize = size
        imageView.center = CGPointMake(ScreenWidth / 2, ScreenHeight / 2)
    }
    
    func zoom(tg:Int = -1){
        //tg 三种状态来控制缩放，当-1的时候自动处理
        //当0的时候，变大到1.6，当1的时候恢复正常
        if(tg == 0){
            scrollView.setZoomScale(1.6, animated: true)
            return
        }
        if(tg == 1){
            scrollView.setZoomScale(1.0, animated: true)
            imageView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2)
            return
        }
        
        if(scrollView.zoomScale > 1.5){
            scrollView.setZoomScale(1.0, animated: true)
        }else{
            scrollView.setZoomScale(1.6, animated: true)
        }
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let offx = (scrollView.frame.width - scrollView.contentSize.width)
        let offy = (scrollView.frame.height - scrollView.contentSize.height)
        imageView.center = CGPointMake((scrollView.contentSize.width  + (offx > 0 ? offx : 0))/2, (scrollView.contentSize.height  + (offy > 0 ? offy : 0))/2)
    }

}
