//
//  CropsChooseViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/25.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MJRefresh
class CropsChooseViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var cropClass:String!
    var cropTypeNo = ""
    var crops = [Crops]()
    @IBOutlet weak var collectionView: UICollectionView!
    var block:((Crops) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionViewConfigure()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.mj_footer.hidden = false
        collectionView.mj_footer.beginRefreshing()
    }
    
    func collectionViewConfigure(){
        collectionView.registerNib(CropsCollectionViewCell.nib, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = UIColor.whiteColor()
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(160, 160)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
        let mjfooter = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            NetWorkManager.updateSession{[weak self] in
                if let sSelf = self{
                    TYRequest(ContentType.CropsList, parameters: ["cropTypeNo":sSelf.cropTypeNo]).TYresponseJSON(completionHandler: { (response) in
                        if response.result.isSuccess {
                            if let json = response.result.value as? [String:AnyObject]{
                                if let msg = json["message"] as? String where msg == "success"{
                                    if let cropList = json["cropList"] as? NSArray{
                                        cropList.forEach({ (x) in
                                            if let object = x as? [String:AnyObject] {
                                                let crop = Crops()
                                                crop.name = object["cropName"] as! String
                                                crop.id = object["cropNo"] as! String
                                                let urls = (object["imageUrl"] as! String).componentsSeparatedByString("|")
                                                if urls.count == 3{
                                                    crop.urlHome = TYUserDefaults.UrlPrefix.value + urls[0]
                                                    crop.urlDetail = TYUserDefaults.UrlPrefix.value +  urls[1]
                                                    crop.url = TYUserDefaults.UrlPrefix.value +  urls[2]
                                                }else{
                                                    crop.url = TYUserDefaults.UrlPrefix.value + urls[0]
                                                }
                                                sSelf.crops.append(crop)
                                            }
                                        })
                                        sSelf.collectionView.reloadData()
                                        sSelf.collectionView.mj_footer.endRefreshing()
                                        sSelf.collectionView.mj_footer.hidden = true
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
        mjfooter.setTitle("正在加载农作物,请稍后", forState: MJRefreshState.Refreshing)
        collectionView.mj_footer = mjfooter
    }
    
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
