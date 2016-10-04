//
//  ExpertPresentViewController.swift
//  智慧田园
//
//  Created by jason on 2016/9/23.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MBProgressHUD
import STPopup
private let reuseIdentifier = "Cell"

class ExpertPresentViewController: UICollectionViewController {

    var nums = [5,9,18,66,99,200]
    var user:(name:String,photo:String)!
    lazy var labelName:UILabel = {
        let label = UILabel()
        label.font = UIFont(name: NormalLanTingHeiFontName, size: 18)
        return label
    }()
    lazy var imagePhoto:UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var popController: STPopupController = {
        let popController = STPopupController(rootViewController: self)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.blackColor()
        popController.navigationBar.setBackgroundImage(UIImage(named: "NavigationBackgroundImg"), forBarMetrics: UIBarMetrics.Default)
        return popController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    func prepareUI(){
//        layoutConfigure()
        collectionViewConfigure()
        userConfigure()
        self.title = "赞赏" + user.name
    }
    
    func layoutConfigure(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSizeMake(80, 40)
        self.collectionView?.setCollectionViewLayout(layout, animated: false)
    }
    
    func collectionViewConfigure(){
        collectionView?.backgroundColor = UIColor.BackgroundColor()
        collectionView?.contentInset = UIEdgeInsetsMake(140, 0, 0, 0)
        collectionView?.registerReusableCell(ExpertPresentCollectionViewCell)
    }
    
    func userConfigure(){
        self.view.addSubview(imagePhoto)
        self.view.addSubview(labelName)
        imagePhoto.snp_makeConstraints { (make) in
            make.width.height.equalTo(60)
            make.top.equalTo(self.view!).offset(20)
            make.centerX.equalTo(self.collectionView!)
        }
        labelName.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.collectionView!)
            make.top.equalTo(imagePhoto.snp_bottom).offset(10)
        }
        imagePhoto.sd_setImageWithURL(NSURL(string: user.photo))
        labelName.text = user.name
        labelName.sizeToFit()
        imagePhoto.sizeToFit()
        
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nums.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ExpertPresentCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! ExpertPresentCollectionViewCell
        cell.money = nums[indexPath.row]
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.dismissViewControllerAnimated(true) { 
            MBProgressHUD.showSuccess("成功打赏(待建设)", toView: nil)
        }
    }
    
    func PushViewControllerInViewController(viewController:UIViewController){
        popController.presentInViewController(viewController)
    }
    
}
