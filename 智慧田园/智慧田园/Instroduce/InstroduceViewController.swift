//
//  InstroduceViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/23.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
class InstroduceViewController: TYViewController {

    @IBOutlet weak var tableView: UITableView!
    lazy var popController: STPopupController = {
        let popController = STPopupController(rootViewController: self)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.blackColor()
        popController.navigationBar.setBackgroundImage(UIImage(named: "NavigationBackgroundImg"), forBarMetrics: UIBarMetrics.Default)
        return popController
    }()
    var contents = [String]()
    var cellHeights = [CGFloat]()
    var headerViews = [InstroduceHeaderView(type: .Yellow, title: "温度"),InstroduceHeaderView(type: .Green, title: "光照"),InstroduceHeaderView(type: .Blue, title: "水分"),InstroduceHeaderView(type: .Red, title: "土壤")]
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(ScreenWidth - 40, ScreenHeight - 150)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        calcHeight()
        tableView.clearOtherLine()
    }
    
    func prepareUI(){
        view.backgroundColor = UIColor.whiteColor()
        tableViewConfigure()
        
    }
    
    func tableViewConfigure(){
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .None
        tableView.registerReusableCell(InstroduceTableViewCell)
    }
    
    func calcHeight(){
        let cell = tableView.dequeueReusableCellWithIdentifier(InstroduceTableViewCell.reuseIdentifier) as! InstroduceTableViewCell
        cell.frame = self.view.bounds
        for i in 0..<contents.count{
            cell.content = contents[i]
            cell.layoutIfNeeded()
            cellHeights.append(cell.newContentView.frame.height + 1)
        }
        for i in 0..<4{
             headerViews[i].frame.size = CGSizeMake(ScreenWidth - 40, 40)
        }
    }
    
    func PushViewControllerInViewController(viewController:UIViewController){
        popController.presentInViewController(viewController)
    }
    
}

extension InstroduceViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InstroduceTableViewCell
        cell.content = contents[indexPath.section]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeights[indexPath.section]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0){
            return 0
        }
        return 40
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0){
            return nil
        }
        return headerViews[section - 1]
    }
}
