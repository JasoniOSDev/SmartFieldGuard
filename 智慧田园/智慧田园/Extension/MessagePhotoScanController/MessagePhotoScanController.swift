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
    private var total:Int!
    private var photoScanData = [PhotoScanModel]()
    private var labelInfo:UILabel = UILabel()
    private var slide = false
    var singleTapGesture:UITapGestureRecognizer!
    var doubleTapGesture:UITapGestureRecognizer!
    private var fromPoint:CGPoint!{
        get{
            let preImageView = photoScanData[index].preImageView
            let preSupreView = preImageView.superview
            let point:CGPoint!
            if preSupreView != nil {
                point = preSupreView?.convertPoint(preImageView.center, toView: self.view)
            }else{
                point = self.view.center
            }
            return point
        }
    }
    private(set) var toPoint:CGPoint = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
    private var currentCell:PhotoScanCollectionViewCell? {
        get{
            let indexPath = collectionView.indexPathsForVisibleItems()
            for x in indexPath.enumerate(){
                if(x.element.row == index){
                    return collectionView.visibleCells()[x.index] as! PhotoScanCollectionViewCell
                }
            }
            return nil
        }
    }
    private var currentModel:PhotoScanModel {
        get{
            return photoScanData[index]
        }
    }
    
    private var index:Int = 0{
        didSet{
            labelInfo.text = "\(index + 1) / \(total)"
            labelInfo.sizeToFit()
        }
    }
    private let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(ScreenWidth, ScreenHeight)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .Horizontal
        let collectionView = UICollectionView(frame: CGRectMake(0, 0, ScreenWidth, ScreenHeight), collectionViewLayout: layout)
        collectionView.registerReusableCell(PhotoScanCollectionViewCell)
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.pagingEnabled = true
        collectionView.bounces = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        labelInfo.center.x = self.view.frame.width / 2
    }
    
    private func prepareUI(){
        self.view.backgroundColor = UIColor.clearColor()
        collectionViewConfigure()
        labelInfoConfigure()
    }
    
    private func gestureConfigure(){
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.singleTapGestureAction))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapGestureAction))
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.numberOfTapsRequired = 2
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        self.view.addGestureRecognizer(doubleTapGesture)
        self.view.addGestureRecognizer(singleTapGesture)
    }
    
    func singleTapGestureAction(){
        if let cell = currentCell{
            cell.zoom(1)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doubleTapGestureAction(){
        if let cell = currentCell{
            cell.zoom()
        }
    }
    
    private func collectionViewConfigure(){
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
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
    private func loadCurrentCell(){
        collectionView.reloadData()
        //不加reloadData的话，再选择一个图片数量不一样的时候会发生崩溃
        collectionView.contentSize = CGSizeMake(ScreenWidth * CGFloat(total), ScreenHeight)
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .None, animated: false)
        collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)])
    }
    
    class func setImages(images:[UIImageView],imagesURL:[String],index:Int = 0){
        shareMessagePhotoScan.setImages(images, imagesURL: imagesURL, index: index)
    }

    func setImages(images:[UIImageView],imagesURL:[String],index:Int = 0){
        self.photoScanData.removeAll(keepCapacity: false)
        self.total = imagesURL.count
        self.index = index
        for i in 0..<imagesURL.count{
            self.photoScanData.append(PhotoScanModel(preImageView: images[i], url: imagesURL[i]))
        }
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        let width = UIScreen.mainScreen().bounds.width
        let percent = (contentOffset.x ) / width * 10 % 10 / 10
        let newIndex = Int((contentOffset.x) / width)
        let result = newIndex != index ? percent < 0.3 : percent > 0.7
        if let cell = currentCell where  result{
            cell.zoom(1)
            index = newIndex
        }
    }
    
    class func pushScanController(point:CGPoint? = nil){
        shareMessagePhotoScan.pushScanController(point)
    }
    
    func pushScanController(point:CGPoint? = nil){
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
        if let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as? TYNavigationViewController{
            rootViewController.visibleViewController!.presentViewController(self, animated: true, completion: nil)
        }else{
            UIApplication.sharedApplication().keyWindow?.rootViewController!.presentViewController(self, animated: true, completion: nil)
        }
        let imageView = UIImageView()
        for x in self.photoScanData.enumerate(){
            imageView.yy_setImageWithURL(NSURL(string: x.element.url), options: .AvoidSetImage)
        }
    }

}

extension MessagePhotoScanController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    private func configureCell(cell: PhotoScanCollectionViewCell,data:PhotoScanModel){
        cell.loadImage(data.preImageView.image!, url: data.url)
        cell.setImageViewSize(data.aftSize)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return total
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoScanCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! PhotoScanCollectionViewCell
        configureCell(cell, data: photoScanData[indexPath.row])
        return cell
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
        let containerView = transitionContext.containerView()
        let duration = self.transitionDuration(transitionContext)
        if let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? MessagePhotoScanController,
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey){
            if toVC.isBeingPresented(){
                toVC.loadCurrentCell()
                let animatedView = toVC.currentCell!.imageView
                let backView = toVC.currentCell!.backView
                let model = toVC.currentModel
                containerView.addSubview(toView)
                animatedView.transform = model.fromTransform
                animatedView.center = toVC.fromPoint
                backView.alpha = 0
                UIView.animateWithDuration(duration, animations: {
                    animatedView.transform = model.toTransform
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
                    let animatedView = fromVC.currentCell!.imageView
                    let backView = fromVC.currentCell!.backView
                    let model = fromVC.currentModel
                    UIView.animateWithDuration(duration, animations: {
                        animatedView.transform = model.fromTransform
                        animatedView.center = fromVC.fromPoint
                        backView.alpha = 0
                        }, completion: { (_) in
                            fromView.removeFromSuperview()
                            let isCancelled = transitionContext.transitionWasCancelled()
                            transitionContext.completeTransition(!isCancelled)
                            backView.alpha = 0.6
                            animatedView.transform = model.toTransform
                            animatedView.center = fromVC.toPoint
                    })
                }
            }
        }
    }

}
