//
//  ForumViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MJRefresh
import MBProgressHUD
class ForumViewController: TYViewController{

    
    @IBOutlet weak var ConstraintPageViewTop: NSLayoutConstraint!
    @IBOutlet weak var ConstraintContentWidth: NSLayoutConstraint!
    @IBOutlet weak var PageButtonUnSolve: PageButtonMidLine!
    @IBOutlet weak var PageButtonSolve: PageButtonMidLine!
    @IBOutlet weak var VScrollView: UIScrollView!
    @IBOutlet weak var unSolveTableView: UITableView!
    @IBOutlet weak var SolveTableView: UITableView!
    @IBOutlet weak var NavBarButtonItemMe: UIBarButtonItem!
    var OnlyMeData = false
    var pageViewHidden = false
    var direction:Bool = false//false 表示向上 true表示向下
    var preDragY:CGFloat! = 0
    var solveForm = [Forum]()
    var unSolveForm = [Forum]()
    var selectedForum:Forum!
    var HScrollViewHidden:Bool = false
    var solveDataIndex = 0
    var solveDataCount = 0
    var solveDataEnd = 0
    var solveDataPageSize = 20
    var unSolveDataIndex = 0
    var unSolveDataCount = 0
    var unSolveDataEnd = 0
    var unSolveDataPageSize = 20
    var unSolveCellHeight = [Int:CGFloat]()
    var crops:Crops!
    var SolveCellHeight = [Int:CGFloat]()
    var dataInfo:(index:Int,count:Int,end:Int,pageSize:Int){
        get{
            if !PageButtonUnSolve.selected {
                return (solveDataIndex,solveDataCount,solveDataEnd,solveDataPageSize)
            }else{
                return (unSolveDataIndex,unSolveDataCount,unSolveDataEnd,unSolveDataPageSize)
            }
        }
        set{
            if !PageButtonUnSolve.selected {
               solveDataCount = newValue.1
               solveDataEnd = newValue.2
               solveDataIndex = newValue.0
            }else{
               unSolveDataCount = newValue.1
               unSolveDataEnd = newValue.2
               unSolveDataIndex = newValue.0
            }
        }
    }
    var forums:[Forum]{
        get{
            if !PageButtonUnSolve.selected {
                return solveForm
            }else{
                return unSolveForm
            }
        }
        set{
            if !PageButtonUnSolve.selected {
                 solveForm = newValue
            }else{
                 unSolveForm = newValue
            }
        }
    }
    var cellHeight:[Int:CGFloat]{
        get{
            if !PageButtonUnSolve.selected {
                return SolveCellHeight
            }else{
                return unSolveCellHeight
            }
        }
        set{
            if !PageButtonUnSolve.selected {
                SolveCellHeight = newValue
            }else{
                unSolveCellHeight = newValue
            }
        }
    }
    
    var forumStatus:String{
        get{
            if !PageButtonUnSolve.selected{
                return "Resolved"
            }else{
                return "Unsolved"
            }
        }
    }
    
    var tableView:UITableView{
        get{
            if !PageButtonUnSolve.selected{
                return SolveTableView
            }else{
                return unSolveTableView
            }

        }
    }
    lazy var cell:ForumTableViewCell = {
        let cell = self.unSolveTableView.dequeueReusableCellWithIdentifier(ForumTableViewCell.reuseIdentifier) as! ForumTableViewCell
        cell.frame.size.width = ScreenWidth
        return cell
    }()
    
    lazy var forumTableViewCell:ForumTableViewCell = {
        return self.SolveTableView.dequeueReusableCellWithIdentifier(ForumTableViewCell.reuseIdentifier) as! ForumTableViewCell
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        LoadData()
        userDefaultConfigure()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ForumDetailViewController{
            vc.forum = self.selectedForum
        }
        if let vc = segue.destinationViewController as? TYNavigationViewController{
            if let vc2 = vc.visibleViewController as? PushNewForumViewController{
                vc2.cropsID = self.crops.id
                vc2.cropsName = self.crops.name
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        ConstraintContentWidth.constant = 2 * self.view.frame.size.width
        super.viewWillLayoutSubviews()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    private func userDefaultConfigure(){
        TYUserDefaults.NewForum.bindListener("ForumViewController") { (value) in
            if value == true {
                self.ButtonPageClicked(self.PageButtonUnSolve)
                self.dataInfo = (0,0,0,20)
                self.forums.removeAll()
                self.cellHeight.removeAll()
                self.LoadData()
                TYUserDefaults.NewForum.value = false
                MBProgressHUD.showSuccess("发送成功", toView: nil)
            }
        }
    }
    
    private func prepareUI(){
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        tableViewConfigure()
        self.title = crops.name + "讨论区"
        //self.view.addSubview(fpsLabel)
    }
    
    func LoadData(){
        NetWorkManager.updateSession{
            let tableViewTmp = self.tableView
            TYRequest(.Forum, parameters: ["pageIndex":self.dataInfo.0 + 1,"pageCount":self.dataInfo.3,"parentArea":"","status":self.forumStatus,"type":"Discuss"]).TYresponseJSON { response in
                if response.result.isSuccess{
                    if let json = response.result.value as? [String:AnyObject] {
                        if let message = json["message"] as? String where message == "success"{
                           let UrlPrefix = TYUserDefaults.UrlPrefix.value
                            if let content = json["postList"] as? [String:AnyObject]{
                                if let list = content["list"] as? NSArray{
                                    self.dataInfo.0 = content["pageIndex"] as! Int
                                    self.dataInfo.1 = content["dataCount"] as! Int
                                    self.dataInfo.2 = content["dataEnd"] as! Int
                                    for object in list{
                                        if let dict = object as? [String:AnyObject] {
                                            var dict2 = dict
                                            dict2["UrlPrefix"] = UrlPrefix
                                            let forumObject = Forum(dict: dict2)
                                            self.forums.append(forumObject)
                                        }
                                    }
                                    if self.OnlyMeData {
                                        self.forums = self.forums.filter{$0.userId == TYUserDefaults.userID.value}
                                    }
                                    tableViewTmp.mj_footer.endRefreshing()
                                    tableViewTmp.reloadData()
                                }else{
                                    tableViewTmp.mj_footer.endRefreshingWithNoMoreData()
                                    tableViewTmp.mj_footer.resetNoMoreData()
                                }
                            }
                        }else{
                            print(json["message"])
                        }
                    }
                }
            }
        }
    }
    
    private func tableViewConfigure(){
        unSolveTableView.separatorInset = UIEdgeInsetsZero
        unSolveTableView.clearOtherLine()
        unSolveTableView.registerReusableCell(ForumTableViewCell)
        unSolveTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(self.LoadData))
        SolveTableView.separatorInset = UIEdgeInsetsZero
        SolveTableView.registerReusableCell(ForumTableViewCell)
        SolveTableView.clearOtherLine()
        SolveTableView.mj_footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: #selector(self.LoadData))
    }
    
    private func calcHeightAtIndex(index:Int,solve:Bool) -> CGFloat{
        //计算
        if cellHeight[index] == nil{
            cell.forum = forums[index]
            cell.loadData()
            cell.layoutIfNeeded()
            cellHeight[index] = cell.NewContentView.frame.height
        }
        return cellHeight[index]!
    }
    
    @IBAction func ButtonPageClicked(sender: PageButtonMidLine) {
        sender.selected = true
        switch sender.tag - 100 {
        case 1:
            PageButtonSolve.selected = false
            VScrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        default:
            PageButtonUnSolve.selected = false
            VScrollView.setContentOffset(CGPointMake(self.view.frame.size.width, 0), animated: true)
        }
        if dataInfo.index == 0 {
            LoadData()
        }
    }
    
    @IBAction func LeftButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ButtonAddClicked(sender: AnyObject) {
        
    }
    
    @IBAction func ButtonMeClicked(sender: AnyObject) {
        dataInfo.index = 0
        self.forums.removeAll()
        self.OnlyMeData = !self.OnlyMeData
        self.NavBarButtonItemMe.tintColor = self.OnlyMeData ? UIColor.MainColor():UIColor.MidBlackColor()
        LoadData()
    }
}

extension ForumViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ForumTableViewCell
        cell.forum = forums[indexPath.row]
        cell.loadData()
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forums.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return calcHeightAtIndex(indexPath.row, solve: tableView.tag == 102)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedForum = self.forums[indexPath.row]
        self.performSegueWithIdentifier("ShowDetail", sender: self)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
}

extension ForumViewController:UIScrollViewDelegate{
    
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if(scrollView.contentOffset.x / self.view.frame.size.width == 1){
            ButtonPageClicked(PageButtonSolve)
        }else{
            ButtonPageClicked(PageButtonUnSolve)
        }
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        preDragY = scrollView.panGestureRecognizer.locationInView(view).y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
         let nowDragY = scrollView.panGestureRecognizer.locationInView(view).y
        if(preDragY == nowDragY){
            return
        }
        let direction = nowDragY - preDragY
        if(!(scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == ScreenWidth)) {
            return
        }
        if(direction < 0){
            if(!pageViewHidden){
                pageViewHidden = true
                UIView.animateWithDuration(0.3, animations: { 
                    self.ConstraintPageViewTop.constant = -40
                    self.view.layoutIfNeeded()
                })
                
            }
        }else{
            if(pageViewHidden && scrollView.contentOffset.y < 20){
                pageViewHidden = false
                UIView.animateWithDuration(0.3, animations: {
                    self.ConstraintPageViewTop.constant = 0
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
}
