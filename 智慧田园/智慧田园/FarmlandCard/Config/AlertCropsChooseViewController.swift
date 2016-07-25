//
//  AlertCropsChooseViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/25.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
import MJRefresh
class AlertCropsChooseViewController: TYViewController {

    @IBOutlet weak var tableView: UITableView!
    var block:((Crops) -> Void)?
    var cropsClass = [CropsClass]()
    lazy var cropChooseViewController:CropsChooseViewController = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("CropsChooseViewController") as! CropsChooseViewController
        vc.contentSizeInPopup = self.contentSizeInPopup
        vc.block = self.block
        return vc
    }()
    var needAnimation = true
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewConfigure()
        self.title = "分类选择"
    }
    
    func tableViewConfigure(){
        tableView.registerReusableCell(CropClassTableViewCell)
        tableView.separatorStyle = .None
        let mjfooter = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            NetWorkManager.updateSession{
                if let sSelf = self {
                    TYRequest(ContentType.CropsClassName, parameters: ["cropTypeNo":"000"]).TYresponseJSON(completionHandler: { (response) in
                        if response.result.isSuccess {
                            if let json = response.result.value as? [String : AnyObject]{
                                if let msg = json["message"] as? String where msg == "success"{
                                    if let cropTypes = json["cropTypes"] as? NSArray{
                                        cropTypes.forEach({ (x) in
                                            if let object = x as? [String : AnyObject]{
                                                let cropClass = CropsClass()
                                                cropClass.id = object["cropTypeNo"] as! String
                                                cropClass.name = object["cropTypeName"] as! String
                                                cropClass.imageUrl = TYUserDefaults.UrlPrefix.value + (object["imageUrl"] as! String)
                                                sSelf.cropsClass.append(cropClass)
                                            }
                                        })
                                        sSelf.tableView.reloadData()
                                        sSelf.tableView.mj_footer.endRefreshing()
                                        sSelf.tableView.mj_footer.hidden = true
                                    }
                                }
                            }
                        }
                    })
                }
            }
            })
        mjfooter.setTitle("正在加载农作物分类,请稍后", forState: MJRefreshState.Refreshing)
        tableView.mj_footer = mjfooter
        tableView.mj_footer.beginRefreshing()
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSize(width: ScreenWidth - 40 , height: ScreenHeight - 140)
    }
    
    
    class func pushAlertInViewController(viewController:TYViewController, block:(Crops) -> Void){
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("AlertCropsChooseViewController") as! AlertCropsChooseViewController
        vc.block = block
        let popController = STPopupController(rootViewController: vc)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.MidBlackColor()
        popController.presentInViewController(viewController, completion: nil)
    }
}

extension AlertCropsChooseViewController:UITableViewDelegate,UITableViewDataSource{
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if needAnimation == true{
            needAnimation = false
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cropsClass.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as CropClassTableViewCell
        cell.imgURL = cropsClass[indexPath.row].imageUrl
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if needAnimation{
            cell.transform = CGAffineTransformMakeTranslation(0, 80)
            cell.alpha = 0
            UIView.animateWithDuration(0.5) {
                cell.alpha = 1
                cell.transform = CGAffineTransformIdentity
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.cropChooseViewController.title = cropsClass[indexPath.row].name
        self.cropChooseViewController.cropTypeNo = cropsClass[indexPath.row].id
        self.popupController.pushViewController(self.cropChooseViewController, animated: true)
    }
}
