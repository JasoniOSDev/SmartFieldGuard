//
//  MainViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/19.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import SystemConfiguration
import SnapKit
import Alamofire
import MJRefresh
import MBProgressHUD
import RealmSwift
class MainViewController: TYViewController {

    @IBOutlet weak var LabelTip: UILabel!
    @IBOutlet weak var ButtonItemUser: UIBarButtonItem!
    let tableView = UITableView()
    lazy var cardDetailViewController:CardDetailViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("CardDetailViewController") as! CardDetailViewController
        return vc
    }()
    let farmLands = ModelManager.getObjects(Farmland)
    var needAnimation = true
    var notiToken:NotificationToken!
    var tip:String? = nil{
        didSet{
            if tip == nil {
                LabelTip.hidden = true
            }else{
                LabelTip.hidden = false
                if let ttip = tip {
                    switch ttip {
                        case "NOLOGIN": LabelTip.text = "请先登录"
                        case "NODATA": LabelTip.text = "点击\"+\"，立即添加一个农田"
                    default:break
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        notificationConfigure()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.subviews[0].alpha = 0
        self.navigationController?.navigationBar.tintColor = UIColor.MidBlackColor()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }

    func prepareUI(){
        tableViewConfigure()
    }
    
    func notificationConfigure(){
        TYUserDefaults.userID.bindAndFireListener("MainViewController") { _ in
            if TYUserDefaults.isLogined{
                self.tip = nil
                self.tableView.mj_header.hidden = false
                if self.farmLands.count > 0 {
                    NetWorkManager.updateFarmland({ tag in
                        if tag == true{
                            self.tableView.reloadData()
                        }
                        if self.farmLands.count > 0{
                            self.tip = nil
                        }else{
                            self.tip = "NODATA"
                        }
                    })
                }else{
                    self.tableView.mj_header.beginRefreshing()
                }
            }else{
                self.tip = "NOLOGIN"
                self.tableView.reloadData()
                self.tableView.mj_header.hidden = true
            }
        }
        
        //农田数据发生变化的通知
        self.notiToken = farmLands.addNotificationBlock { [weak self] result in
            switch(result){
            case .Initial(_):break
            case .Update(_, deletions: _, insertions: _, modifications: let modify):
                self?.needAnimation = false
                if modify.count > 0 {
                     self?.tableView.reloadRowsAtIndexPaths(modify.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
                }
            case .Error(_):break
            }
        }
    }
    
    func tableViewConfigure(){
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.view).offset(64)
        }
        tableView.backgroundColor = UIColor.BackgroundColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerReusableCell(FarmlandCardTableViewCell)
        tableView.clearOtherLine()
        tableView.separatorStyle = .None
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        self.view.bringSubviewToFront(LabelTip)
        let headerFresh = MJRefreshNormalHeader {[weak self] in
            self?.needAnimation = true
            NetWorkManager.updateFarmland({ tag in
                self?.tableView.mj_header.endRefreshing()
                if tag == true{
                    self?.tableView.reloadData()
                }
                if self?.farmLands.count > 0{
                    self?.tip = nil
                    for x in (self?.farmLands)!{
                        x.updateEnvironmentData(nil)
                    }
                }else{
                    self?.tip = "NODATA"
                }
            })
            
        }
        headerFresh.setTitle("正在获取农田信息", forState: MJRefreshState.Refreshing)
        headerFresh.setTitle("下拉获取农田信息", forState: MJRefreshState.Idle)
        tableView.mj_header = headerFresh
    }
    
    @IBAction func ButtonAddDeviceClicked(sender: AnyObject) {
        if TYUserDefaults.isLogined == false{
            ButtonUserClicked(ButtonItemUser)
        }else{
            AlertAddDeviceViewController.PushAlertAddDeviceInViewController(self)
        }
    }
    
    @IBAction func ButtonUserClicked(sender: AnyObject) {
        
        if TYUserDefaults.isLogined == false{
            LoginHomeViewController.pushAlertInViewController(self)
        }else{
            UserCenterViewController.pushAlertInViewController(self)
        }
    }
    
    deinit{
        TYUserDefaults.userID.removeListenerWithName("MainViewController")
    }

}

extension MainViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tip == "NOLOGIN"{
            return 0
        }
        return farmLands.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as FarmlandCardTableViewCell
        cell.farmLand = farmLands[indexPath.row]
        cell.farmLand.fillDataInView()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 135
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        cardDetailViewController.farmland = self.farmLands[indexPath.row]
        self.navigationController?.pushViewController(self.cardDetailViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard needAnimation else {return}
        cell.transform = CGAffineTransformMakeTranslation(0, 80)
        cell.alpha = 0
        UIView.animateWithDuration(1.0) {
            cell.alpha = 1
            cell.transform = CGAffineTransformIdentity
        }
    }
}
