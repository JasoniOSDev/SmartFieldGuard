//
//  MessagePhotoScanController.swift
//  MessagePhotoViewDemo
//
//  Created by jason on 2016/7/13.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class MessagePhotoScanController: UIViewController,UIScrollViewDelegate {
    static let shareMessagePhotoScan = MessagePhotoScanController(OK: "234")
    convenience init (OK:String){
        self.init()
        prepareUI()
        gestureConfigure()
    }
    let width = UIScreen.mainScreen().bounds.width
    let height = UIScreen.mainScreen().bounds.height
    private var scrollView = UIScrollView()
    private let scrollViewContentView = UIView()
    private var index:Int = 0{
        didSet{
            labelInfo.text = "\(index + 1) / \(total)"
            labelInfo.sizeToFit()
            animatedImageView = self.images[index]
            fromPoint = CGPointMake(origionPoint.x + width * CGFloat(index), origionPoint.y)
            toPoint = CGPointMake(width * CGFloat(index * 2 + 1 )/2, height / 2)
        }
    }
    private var total:Int!
    private var images = [UIImageView]()
    private var labelInfo:UILabel = UILabel()
    private var slide = false
    private var tapGesture:UITapGestureRecognizer!
    private(set) var backView = UIView()
    private(set) var animatedImageView:UIImageView!
    private(set) var fromTransform:CGAffineTransform!
    private(set) var toTransform:CGAffineTransform = CGAffineTransformMakeScale(1, 1)
    private(set) var fromPoint:CGPoint!
    private(set) var origionPoint:CGPoint!
    private(set) var toPoint:CGPoint = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
    private func gestureConfigure(){
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureAction))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func tapGestureAction(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func prepareUI(){
        self.view.backgroundColor = UIColor.clearColor()
        backViewConfigure()
        scrollViewConfigure()
        labelInfoConfigure()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        labelInfo.center.x = self.view.frame.width / 2
    }
    
    private func backViewConfigure(){
        self.view.addSubview(backView)
        backView.backgroundColor = UIColor.blackColor()
        backView.alpha = 0.6
        backView.frame = self.view.bounds
    }
    
    private func scrollViewConfigure(){
        self.view.addSubview(scrollView)
        scrollView.frame = self.view.bounds
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.maximumZoomScale = 2.0
    }
    
    private func labelInfoConfigure(){
        self.view.addSubview(labelInfo)
        labelInfo.frame.origin.y = 50
        labelInfo.center.x = self.view.frame.width / 2
        labelInfo.textAlignment = .Center
        labelInfo.font = UIFont.systemFontOfSize(18)
        labelInfo.textColor = UIColor.whiteColor()
        labelInfo.text = "1 / 5"
        labelInfo.sizeToFit()
    }
    
    private func refreshUI(){
        let width = UIScreen.mainScreen().bounds.width
        //设置图片大小
        let MaxPhotoWidth = width - 100 //两旁预留50
        let posY = UIScreen.mainScreen().bounds.height / 2
        var posX = width / 2
        //考虑到图片比例不一定，所以这边高度要根据具体情况
        //获得fromTransform
        let fromSize = animatedImageView.frame.size
        animatedImageView.sizeToFit()
        var photoWidth = min(MaxPhotoWidth,animatedImageView.frame.width)
        var scale = photoWidth / fromSize.width
        let toSize = CGSizeMake(fromSize.width * scale, fromSize.height * scale)
        fromTransform = CGAffineTransformMakeScale(fromSize.width/toSize.width, fromSize.height/toSize.height)
        for x in images{
            x.clipsToBounds = false
            x.sizeToFit()
            photoWidth = min(MaxPhotoWidth,x.frame.width)
            scale = photoWidth / x.frame.width
            x.frame.size = CGSizeMake(x.frame.width * scale, x.frame.height * scale)
            x.center = CGPointMake(posX, posY)
            x.clipsToBounds = true
            x.layer.cornerRadius = 4
            posX += width
            scrollView.addSubview(x)
        }
        scrollView.contentSize = CGSizeMake(width * CGFloat(total), UIScreen.mainScreen().bounds.height)
        scrollView.contentOffset.x = width * CGFloat(index)
    }
    
    class func setImages(images:[UIImageView],index:Int = 0,fromPoint:CGPoint = CGPointMake(shareMessagePhotoScan.width/2, shareMessagePhotoScan.height / 2)){
        for x in shareMessagePhotoScan.images{
            x.removeFromSuperview()
        }
        shareMessagePhotoScan.images.removeAll(keepCapacity: false)
        shareMessagePhotoScan.images = images
        shareMessagePhotoScan.total = images.count
        shareMessagePhotoScan.setFromPoint(fromPoint)
        shareMessagePhotoScan.index = index
        shareMessagePhotoScan.refreshUI()
    }
    
    func setFromPoint(fromPoint:CGPoint){
        self.fromPoint = fromPoint
        self.origionPoint = fromPoint
    }
    
    class func setIndex(index:Int){
        shareMessagePhotoScan.index = index
    }
    
    class func pushScanController(point:CGPoint? = nil){
        shareMessagePhotoScan.modalPresentationStyle = .Custom
        shareMessagePhotoScan.transitioningDelegate = shareMessagePhotoScan
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as? TYNavigationViewController{
            rootViewController.visibleViewController!.presentViewController(shareMessagePhotoScan, animated: true, completion: nil)
        }else{
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(shareMessagePhotoScan, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard !scrollView.zooming else{return}
        let contentOffset = scrollView.contentOffset
        let width = UIScreen.mainScreen().bounds.width
        self.index = Int((contentOffset.x + 50) / width)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        slide = false
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return animatedImageView
    }

}

extension MessagePhotoScanController:UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate{
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning){
        guard let containerView = transitionContext.containerView() else {return}
        let duration = self.transitionDuration(transitionContext)
        if let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? MessagePhotoScanController,
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey){
            if toVC.isBeingPresented(){
                let animatedView = toVC.animatedImageView
                let backView = toVC.backView
                containerView.addSubview(toView)
                animatedView.transform = toVC.fromTransform
                animatedView.center = toVC.fromPoint
                backView.alpha = 0
                UIView.animateWithDuration(duration, animations: { 
                    animatedView.transform = toVC.toTransform
                    animatedView.center = toVC.toPoint
                    backView.alpha = 0.6
                    }, completion: { (_) in
                        let isCancelled = transitionContext.transitionWasCancelled()
                        transitionContext.completeTransition(!isCancelled)
                })
            }
        }else{
            if let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? MessagePhotoScanController,let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey){
                if fromVC.isBeingDismissed(){
                    let animatedView = fromVC.animatedImageView
                    let backView = fromVC.backView
                    UIView.animateWithDuration(duration, animations: {
                        animatedView.transform = fromVC.fromTransform
                        animatedView.center = fromVC.fromPoint
                        backView.alpha = 0
                        }, completion: { (_) in
                            fromView.removeFromSuperview()
                            let isCancelled = transitionContext.transitionWasCancelled()
                            transitionContext.completeTransition(!isCancelled)
                    })
                }
            }
        }
    }
}
