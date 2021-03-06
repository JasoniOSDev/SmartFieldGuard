//
//  CropsChooseViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/25.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MJRefresh
class CropsChooseViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var cropClass:String!
    var crops = [LocalCrops]()
    var block:((LocalCrops) -> Void)?
    var cropTypeNo = ""{
        didSet{
            NetWorkManager.GetCropsList(cropTypeNo) { list in
                self.crops = list
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    private func prepareUI(){
        collectionViewConfigure()
    }
    
    private func collectionViewConfigure(){
        collectionView.registerNib(CropsCollectionViewCell.nib, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(160, 160)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
    }
}

extension CropsChooseViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return crops.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! CropsCollectionViewCell
        cell.imgName = crops[indexPath.row].url
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let finishBlock = block{
            finishBlock(crops[indexPath.row])
        }
        self.popupController.dismissWithCompletion(nil)
    }
}
