//
//  TaskDetailViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/29.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
import MBProgressHUD
class TaskDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var firstCellHeight:CGFloat = 0
    var secondCelleHeight:CGFloat = 0
    var tableViewRegister = false
    var headerView = [InstroduceHeaderView(type: .Green,title: "类型"),InstroduceHeaderView(type: .Yellow,title: "阶段"),InstroduceHeaderView(type: .Blue, title: "任务内容"),InstroduceHeaderView(type: .Red, title: "注意事项")]
    var tasking:Tasking!{
        didSet{
            self.title = tasking.name
        }
    }
    
    lazy var buttonFinish:UIView = {
        let view = UIView()
        let btn = UIButton()
        btn.setImage(UIImage(named: "TaskDetail_Finish"), forState: .Normal)
        btn.addTarget(self, action: #selector(self.taskFinish), forControlEvents: .TouchUpInside)
        view.addSubview(btn)
        view.frame = CGRectMake(0, 0, ScreenWidth - 40 , 60)
        btn.snp_makeConstraints(closure: { (make) in
            make.center.equalTo(view)
        })
        btn.sizeToFit()
        return view
    }()
    
    lazy var popController:STPopupController = {
        let popController = STPopupController(rootViewController: self)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.MidBlackColor()
        for x in popController.navigationBar.subviews{
            x.subviews.first?.removeFromSuperview()
        }
        popController.navigationBar.setBackgroundImage(UIImage(named: "NavigationBackgroundImg"), forBarMetrics: UIBarMetrics.Default)
        return popController
    }()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableViewConfigure()
        contentSizeInPopupCalc()
         self.tableView.reloadData()
    }
    
    func taskFinish(){
        tasking.taskCompete()
        MBProgressHUD.showSuccess("任务已经完成", toView: nil)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func tableViewConfigure(){
        if tableViewRegister == false{
            tableViewRegister = true
            tableView.registerReusableCell(InstroduceTableViewCell)
            if tasking.status == false{
                tableView.tableFooterView = buttonFinish
            }
        }
    }
    
    func contentSizeInPopupCalc(){
        var height:CGFloat = 160
        let cell = tableView.dequeueReusableCellWithIdentifier(InstroduceTableViewCell.reuseIdentifier) as! InstroduceTableViewCell
        cell.frame.size.width = ScreenWidth - 40
        cell.content = tasking.operation
        cell.layoutIfNeeded()
        firstCellHeight = cell.newContentView.frame.height
        height += firstCellHeight
        cell.content = tasking.note
        cell.layoutIfNeeded()
        secondCelleHeight = cell.newContentView.frame.height
        height += secondCelleHeight
        if tasking.status == false{
            height += 60
        }
        if height > ScreenHeight - 150{
            height = ScreenHeight - 150
        }
        self.contentSizeInPopup = CGSizeMake(ScreenWidth - 40, height)
    }
    
    func PushViewControllerInViewController(viewController:UIViewController){
        popController.presentInViewController(viewController)
    }
    
}
//tableView's Delegate
extension TaskDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 0
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as InstroduceTableViewCell
        if indexPath.section == 2{
            cell.content = tasking.operation
        }
        if indexPath.section == 3{
            cell.content = tasking.note
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2{
            return firstCellHeight
        }else{
            return secondCelleHeight
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            headerView[section].title = "类型:  \(tasking.taskType == "Everyday" ? "日常任务":"临时任务")"
        }
        if section == 1{
            headerView[section].title = "阶段:  " + ((tasking.crop?.propertyDict[tasking.periodNo] as? String) ?? "无")
        }
        return headerView[section]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}
