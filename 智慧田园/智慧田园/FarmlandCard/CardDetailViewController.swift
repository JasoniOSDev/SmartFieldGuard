//
//  CardDetailViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/21.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MBProgressHUD
import RealmSwift
import MJRefresh
class CardDetailViewController: TYViewController {

    @IBOutlet weak var LabelTitle: UILabel!
    @IBOutlet weak var LabelStartTime: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ConstrainTabViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var CropsImg: UIImageView!
    
    //空气
    @IBOutlet weak var LabelAir: UILabel!
    @IBOutlet weak var ImgAir: UIImageView!
    @IBOutlet weak var LabelTitleAir_T: UILabel!
    @IBOutlet weak var LabelTitleAir_W: UILabel!
    @IBOutlet weak var LabelAir_T: UILabel!
    @IBOutlet weak var LabelAir_W: UILabel!
    //土壤
    @IBOutlet weak var LabelSoil: UILabel!
    @IBOutlet weak var ImgSoil: UIImageView!
    @IBOutlet weak var LabelTitle_Soil_T: UILabel!
    @IBOutlet weak var LabelTitle_Soil_W: UILabel!
    @IBOutlet weak var LabelSoil_T: UILabel!
    @IBOutlet weak var LabelSoil_W: UILabel!
    //阳光
    @IBOutlet weak var ImgSun: UIImageView!
    @IBOutlet weak var LabelSun: UILabel!
    @IBOutlet weak var LabelTitleSunStrength: UILabel!
    @IBOutlet weak var LabelSunStrength: UILabel!
    //二氧化碳
    @IBOutlet weak var LabelCO2: UILabel!
    @IBOutlet weak var ImgCO2: UIImageView!
    @IBOutlet weak var LabelTitleCO2Title: UILabel!
    @IBOutlet weak var LabelCO2Strength: UILabel!
    @IBOutlet weak var FertilizerSlider: UISlider!
    @IBOutlet weak var LabeFertilizer: UILabel!
    lazy var fillAction: Farmland.fillAction? = {
        return {
            [weak self] air_t,air_w,soil_t,soil_w,co2,light in
            if let sSelf = self {
                sSelf.LabelAir_T.text = String(format: "%.f℃",air_t)
                sSelf.LabelAir_W.text = String(format: "%.f%%", air_w)
                sSelf.LabelSoil_T.text = String(format: "%.f℃", soil_t)
                sSelf.LabelSoil_W.text = String(format: "%.f%%", soil_w)
                sSelf.LabelCO2Strength.text = String(format: "%.fppm", co2)
                sSelf.LabelSunStrength.text = String(format: "%.fLUX", light)
                //更新颜色及对应的图标
//              sSelf.updateModuleState()
            }
        }

    }()
    lazy var instroduceViewController:InstroduceViewController = {
        
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("InstroduceViewController") as! InstroduceViewController
        if let crop = self.farmland.crops{
            vc.title = crop.name
            vc.contents.append(crop.quickLook)
            vc.contents.append(crop.temperatureQuickLook)
            vc.contents.append(crop.sunQuickLook)
            vc.contents.append(crop.waterQuickLook)
            vc.contents.append(crop.soilQuickLook)
        }
        return vc
    }()
    var taskViewDismiss = false //用来标记引起当前页面出现的原因是否是因为任务窗口的关闭
    lazy var taskDetailViewController:TaskDetailViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("TaskDetailViewController") as! TaskDetailViewController
        return vc
    }()
    
    var farmland:Farmland!{
        didSet{
            farmland.fillDataInViewAction = fillAction
            farmland.updateEnvironmentData(nil)
        }
    }
    var visbileTask:Results<Tasking>!
    var panGesture:UIPanGestureRecognizer!
    var panStartPoint:CGPoint?
    var headRefreshView:TYRefreshNavView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        grestureConfigure()
        notificationConfigure()
        //第一次更新数据
        headRefreshView.beginRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        FertilizerSlider.value = 0
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        if taskViewDismiss {
            taskViewDismiss = false
        }else{
            scrollView.contentOffset.y = 0
            SliderValueChange()
        }
        if scrollView.contentOffset.y == 0{
            self.navigationController?.navigationBar.subviews[0].alpha = 0
        }
    }
    
    private func grestureConfigure(){
        self.panGesture = scrollView.panGestureRecognizer
        self.panGesture.addTarget(self, action: #selector(self.panGestureAction))
    }
    
    private func prepareUI(){
        tableViewConfigure()
        sliderConfigure()
        navigationItemConfigure()
        fillFarmLandData()
        self.view.addSubview(headRefreshView)
        headRefreshView.frame = CGRectMake(0, -54, ScreenWidth, 54)
    }
    private func notificationConfigure(){
        NSNotificationCenter.defaultCenter().addObserverForName(NOTIFICATIONFARMLANDCONFIGUREMODIFYFINISH, object: nil, queue: nil) { noti in
            self.fillFarmLandData()
            if let result = noti.userInfo!["result"] as? Bool where result == true{
                self.loadData()
            }
        }
    }
    
    func panGestureAction(){
        let point = self.panGesture.locationInView(self.scrollView)
        switch self.panGesture.state {
        case .Began:
            self.panStartPoint = point
        case .Ended:
            self.panStartPoint = nil
            headRefreshView.changePosition(0,end: true)
        case .Changed:
            guard headRefreshView.state != .Refreshing else {return }
            let dis = point.y - self.panStartPoint!.y
            guard dis > 0 else {return}
            headRefreshView.changePosition(dis)
        default:
            break
        }
    }
    
    func fillFarmLandData(){
        //用于加载农田的信息
        LabelTitle.text = farmland.name
        LabelStartTime.text = "播种日期 " + farmland.startTimeStr
        if let imageURL = farmland.crops?.urlDetail{
            CropsImg.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named:  "FarmCard_Crops_UnSet"))
        }
    }
    
    func navigationItemConfigure(){
          self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Edit"), style: .Plain, target: self, action: #selector(self.ButtonEditClicked))
    }
    
    func sliderConfigure(){
        FertilizerSlider.setThumbImage(UIImage(named: "SliderThumb"), forState: .Normal)
        FertilizerSlider.continuous = true
        FertilizerSlider.addTarget(self, action: #selector(self.SliderValueChange), forControlEvents: UIControlEvents.AllTouchEvents)
    }
    
    func SliderValueChange(){
        if FertilizerSlider.value < 0.15{
            LabeFertilizer.text = "当前位置 贫瘠(\(String(format: "%.f%%",FertilizerSlider.value * 100)))"
        }else{
            if FertilizerSlider.value < 0.7{
                LabeFertilizer.text = "当前位置 中等(\(String(format: "%.f%%",FertilizerSlider.value * 100)))"
            }else{
                LabeFertilizer.text = "当前位置 肥沃(\(String(format: "%.f%%",FertilizerSlider.value * 100)))"
            }
        }
    }
    
    //主要用于更新任务信息，可以定时更新或者手动更新
    func loadData(block:(()->Void)? = nil){
        guard loading == false else{return}
        loading = true
        //获取农田环境数据
        self.farmland.updateEnvironmentData { [weak self] field in
            //更新任务信息
             field.updateTasking({
                dispatch_async(dispatch_get_main_queue(), { 
                    if let sSelf = self {
                        sSelf.tableView.reloadData()
                        if let backCall = block{
                            backCall()
                        }
                        sSelf.loading = false
                    }
                })
             })
        }
    }
    
    func tableViewConfigure(){
        headRefreshView = TYRefreshNavView.createWithExecuteBlock({ [weak self] in
            if let sSelf = self {
                sSelf.loadData(){
                    sSelf.headRefreshView.endRefreshing()
                }
            }
        })
        tableView.registerReusableCell(TaskTableViewCell)
        tableView.separatorStyle = .SingleLine
        tableView.backgroundColor = UIColor.BackgroundColor()
        tableView.clearOtherLine()
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
    }
    
    func ButtonEditClicked(){
        self.performSegueWithIdentifier("ShowConfig", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? FarmlandConfigureViewController{
            vc.farmLand = self.farmland
        }
        if let vc = segue.destinationViewController as? AnalyzeViewController{
            vc.crop = self.farmland.crops
            vc.field = self.farmland
        }
        if let vc = segue.destinationViewController as? NewRecordViewController{
            vc.Tasks = farmland.tasking.filter(){$0.status == true}
        }
        if let vc = segue.destinationViewController as? TYNavigationViewController{
            if let vc2 = vc.visibleViewController as? ForumViewController{
                vc2.crops = self.farmland.crops
            }
        }
        if let vc = segue.destinationViewController as? TYNavigationViewController{
            if let vc2 = vc.visibleViewController as? ExpertViewController{
                vc2.cropsID = (self.farmland.crops?.id)!
                vc2.cropsName = (self.farmland.crops?.name)!
            }
        }
        
    }

    @IBAction func ButtonFertilizerClicked(sender: AnyObject) {
        if let task = farmland.tasking.filter("self.name = '检测土壤肥力' and self.status = false").first{
            farmland.updateFertility(Double(FertilizerSlider.value * 100))
            MBProgressHUD.showSuccess("成功录入肥力数据", toView: nil)
        }else{
            MBProgressHUD.showError("目前不需要录入", toView: nil)
        }
    }
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

//tabbar代理
extension CardDetailViewController:UITabBarDelegate{
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if farmland.crops != nil{
            switch item.tag - 100 {
            case 1:
                self.performSegueWithIdentifier("showAnalyze", sender: self)
            case 2:
                self.performSegueWithIdentifier("showRecord", sender: self)
            case 3:
                self.performSegueWithIdentifier("showExpert", sender: self)
            case 4:
                self.performSegueWithIdentifier("showForum", sender: self)
            case 5:
                instroduceViewController.PushViewControllerInViewController(self)
            default:
                break
            }
        }else{
            MBProgressHUD.showError("请设置农作物后再进入", toView: nil)
        }
    }
}

extension CardDetailViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        visbileTask = farmland.tasking.filter("self.status == false")
        ConstrainTabViewHeight.constant = 85 * CGFloat(visbileTask.count) + 25
        //这里要计算一下高度
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return visbileTask.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(indexPath: indexPath) as TaskTableViewCell
        cell.taskStatus = .Doing
        cell.task = visbileTask[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = visbileTask.count > 0 ? "您今天还有\(visbileTask.count)项任务未完成" : "目前全部任务都已经完成"
        label.font = UIFont.DetailCardTaskDetailFont()
        label.textColor = UIColor.MainColor()
        label.textAlignment = .Center
        label.backgroundColor = UIColor.BackgroundColor()
        
        return label
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskDetailViewController.tasking = visbileTask[indexPath.row]
        taskDetailViewController.PushViewControllerInViewController(self)
        taskViewDismiss = true
    }
}

//滑动代理
extension CardDetailViewController:UIScrollViewDelegate{
    
    private func ChangeStyle(tag:Bool){
        //转换成黑色,并且显示名字
        if(tag){
            self.title = LabelTitle.text
            self.navigationController?.navigationBar.tintColor = UIColor.MidBlackColor()
            self.navigationItem.rightBarButtonItem!.image = UIImage(named: "Edit_Black")
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }else{
            self.title = nil
            self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
            self.navigationItem.rightBarButtonItem!.image = UIImage(named: "Edit")
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView.contentSize.height > ScreenHeight + 50 else {return}
        if(scrollView.contentOffset.y > 0 && self.navigationController?.navigationBar.subviews[0].alpha == 1){
            return
        }
        let percent = scrollView.contentOffset.y / 64
        self.navigationController?.navigationBar.subviews[0].alpha = percent > 1 ? 1 : percent
        ChangeStyle(percent>=0.8)
    }
}
