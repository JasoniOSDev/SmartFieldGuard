//
//  ChooseExpertsViewController.swift
//  智慧田园
//
//  Created by jason on 2016/9/23.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MBProgressHUD
class ChooseExpertsViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout {

    var cropsID:String!
    var block:((String,String,String)->Void)!
    var users = [(name:String,photo:String,id:String)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.registerReusableCell(ExpertChooseCollectionViewCell)
        collectionViewConfigure()
        loadData()
    }
    
    func collectionViewConfigure(){
        collectionView?.backgroundColor = UIColor.BackgroundColor()
    }
    
    func loadData(){
        let hud = MBProgressHUD.showMessage(nil, view: nil)
        NetWorkManager.getExpertList(cropsID,block: {
            list in
            hud.hidden = true
            self.users = list
            self.collectionView!.reloadData()
        })
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ExpertChooseCollectionViewCell.reuseIdentifier, forIndexPath: indexPath) as! ExpertChooseCollectionViewCell
        
        cell.ImageViewPhoto.sd_setImageWithURL(NSURL(string: users[indexPath.row].photo))
        cell.LabelName.text = users[indexPath.row].name
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.block(self.users[indexPath.row].name,self.users[indexPath.row].photo,self.users[indexPath.row].id)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((ScreenWidth - 1) / 2 , 160)
    }
    
    

}
