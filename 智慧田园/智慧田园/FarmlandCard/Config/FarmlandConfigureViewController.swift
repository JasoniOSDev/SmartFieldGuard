//
//  FarmlandConfigureViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/21.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MBProgressHUD
class FarmlandConfigureViewController: TYViewController {

    @IBOutlet weak var CropsImg: UIImageView!
    @IBOutlet weak var LabelStartTime: UILabel!
    @IBOutlet weak var LabelTitle: UILabel!
    @IBOutlet weak var ConstraintTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    var titles = ["名称","播种日期","农作物","农田面积","农田位置"]
    weak var textFieldName:UITextField?
    weak var labelPostion:UILabel?
    var position:CLLocationCoordinate2D?
    var cropCreateTime:NSTimeInterval = 0
    var cropCreateDate:NSDate?
    var selectCrop:LocalCrops?
    let locationManager = AMapLocationManager()
    var nameChange = false
    var dateChange = false
    var cropChange = false
    var areaChange = false
    var positionChange = false
    var preName:String?
    var preDate:String?
    var preCrops:String?
    var preArea = 0.0
    var prePosition:String?
    var farmLand:Farmland!{
        didSet{
            preName = self.farmLand.name
            preArea = farmLand.mianji
           
            if let crop = farmLand.crops{
                preCrops = crop.name
                cropCreateDate = crop.startDate
                cropCreateTime = crop.starTime
                preDate = formatter.stringFromDate(cropCreateDate!)
                //在真机当中，如有作物，则肯定不是第一次配置，则相应的定位都有，但在模拟器中不能定位
                if farmLand.positionStr != ""{
                    prePosition = farmLand.positionStr
                    position = CLLocationCoordinate2D(latitude: farmLand.latitude, longitude: farmLand.longitude)
                }
            }
        }
    }
    lazy var formatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }()
    lazy var cropsDataViewController:CropsDataViewController = {
        let story = UIStoryboard(name: "FarmlandCard", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("CropsDataViewController") as! CropsDataViewController
        vc.field = self.farmLand
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        locationManagerConfigure()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.subviews[0].alpha = 0
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    private func prepareUI(){
        tableViewConfigure()
        navigationItemConfigure()
        if let imageURL = farmLand.crops?.urlDetail{
            CropsImg.sd_setImageWithURL(NSURL(string: imageURL), placeholderImage: UIImage(named:  "FarmCard_Crops_UnSet"))
        }
    }
    
    private func navigationItemConfigure(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close_White"), style: .Plain, target: self, action: #selector(self.closeAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "OK_White"), style: .Plain, target: self, action: #selector(self.FinishAction))
    }
    
    private func locationManagerConfigure(){
        AMapServices.sharedServices().apiKey = GDKey
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    private func getFarmLandPostion(){
        self.labelPostion?.text = "正在获取位置"
        prePosition = "正在获取位置"
        locationManager.requestLocationWithReGeocode(true) { [weak self] location, geoCode, error in
            if let sSelf = self where error == nil{
                sSelf.position = location.coordinate
                sSelf.prePosition = geoCode.formattedAddress
                sSelf.positionChange = true
                sSelf.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
    
    private func loadData(){
        if let crop = farmLand.crops{
            LabelTitle.text = farmLand.name
            LabelStartTime.text = "播种日期 " + farmLand.startTimeStr
            CropsImg.sd_setImageWithURL(NSURL(string: crop.urlDetail), placeholderImage: UIImage(named:  "FarmCard_Crops_UnSet"))
        }
    }

    
    func closeAction(){
        //执行一些操作
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func checkName() -> FarmlandConfigureViewController?{
        
        if(preName == nil || preName == ""){
            MBProgressHUD.showError("名称为空",toView: nil)
            return nil
        }
        
        if(preName?.characters.count > 6){
            MBProgressHUD.showError("名称过长",toView: nil)
            return nil
        }
        
        return self
    }
    private func checkDate() -> FarmlandConfigureViewController?{
        if(preDate == nil){
            MBProgressHUD.showError("播种日期未选择",toView: nil)
            return nil
        }
        
        return self
    }
    private func checkCrops() -> FarmlandConfigureViewController?{
        if preCrops == nil {
            MBProgressHUD.showError("农作物未选择",toView: nil)
            return nil
        }
        
        return self
    }
    private func checkArea() -> FarmlandConfigureViewController?{
        if(preArea == 0.0){
            MBProgressHUD.showError("农田面积未设置",toView: nil)
            return nil
        }
        return self
    }
    
    private func checkPosition() -> FarmlandConfigureViewController?{
        if(position == nil && prePosition == nil){
            MBProgressHUD.showError("还未获取农田位置", toView: nil)
            return nil
        }
        if(prePosition == "正在获取位置"){
            MBProgressHUD.showError("正在获取农田位置", toView: nil)
            return nil
        }
        return self
    }
    
    func saveAction(){
        if self.selectCrop == nil {
            let crops = LocalCrops()
            crops.id = (farmLand.crops?.id)!
            self.selectCrop = crops
        }
        if preCrops != farmLand.crops?.name {
            NetWorkManager.pushAFinishedTask(farmLand.id, cropNo: (self.selectCrop?.id)!, taskNo: "TA000000", operation: "开始种植")
        }
        NetWorkManager.updateSession{
            TYRequest(ContentType.fieldSet, parameters: ["fieldNo":self.farmLand.id,"fieldName":self.preName!,"fieldArea":String(format: "%.f",self.preArea),"longitude":self.position!.longitude,"latitude":self.position!.latitude,"cropNo":self.selectCrop!.id,"startTime":String(format: "%.f",Double(self.cropCreateTime))]).TYresponseJSON(completionHandler: {  response in
                try! ModelManager.realm.write({
                    if self.positionChange == true{
                        self.farmLand.positionStr = self.prePosition!
                        self.farmLand.latitude = self.position!.latitude
                        self.farmLand.longitude = self.position!.longitude
                    }
                    if self.areaChange == true{
                        self.farmLand.mianji = self.preArea
                    }
                    self.farmLand.name = self.preName!
                    if let crop = self.farmLand.crops{
                        crop.startDate = self.cropCreateDate!
                        crop.starTime = self.cropCreateTime
                    }
                })
                self.loadData()
                if self.cropChange == true{
                    if let crop = self.selectCrop {
                        NetWorkManager.getCrops(crop.id, action: { crop in
                            try! ModelManager.realm.write({
                                crop.operatorid = self.farmLand.id + crop.id + String(format: "%.f", (NSDate().timeIntervalSince1970)%10000)
                                crop.startDate = self.cropCreateDate!
                                crop.starTime = self.cropCreateTime
                                self.farmLand.crops = crop
                                self.farmLand.tasking.removeAll()
                                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATIONFARMLANDCONFIGUREMODIFYFINISH, object: nil, userInfo: ["result":true])
                                MBProgressHUD.showSuccess("设置成功", toView: nil)
                                self.loadData()
                            })
                        })
                    }
                }else{
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATIONFARMLANDCONFIGUREMODIFYFINISH, object: nil, userInfo: ["result":false])
                    MBProgressHUD.showSuccess("设置成功", toView: nil)
                }
            })
        }
    }
    
    func FinishAction(){
        self.checkName()?.checkArea()?.checkDate()?.checkCrops()?.checkPosition()?.saveAction()
    }
    
    func tableViewConfigure(){
        tableView.registerReusableCell(FarmlandConfigTableViewCell)
        tableView.clearOtherLine()
    }
    
    @IBAction func ButtonCropsDataClicked() {
        self.presentViewController(cropsDataViewController, animated: true, completion: nil)
    }
    
    
}
extension FarmlandConfigureViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField.text == nil || textField.text == "" {
            MBProgressHUD.showError("名字为空", toView: nil)
            return false
        }
        if textField.text?.characters.count > 6 {
            MBProgressHUD.showError("名字大于6个字符", toView: nil)
            return false
        }
        preName = textField.text
        nameChange = farmLand.name != preName
        return true
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ConstraintTableViewHeight.constant = 5 * 50
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as FarmlandConfigTableViewCell
            cell.selectionStyle = .None
            cell.title = titles[indexPath.row]
            cell.TextFieldDetail.text = farmLand.name == "未设置" ? nil : preName
            textFieldName = cell.TextFieldDetail
            textFieldName?.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
            cell.textLabel?.text = titles[indexPath.row]
            switch indexPath.row {
            case 1:
                if preDate != nil{
                    cell.detailTextLabel?.text = preDate
                }
            case 2:
                cell.detailTextLabel?.text = preCrops
            case 3:
                cell.detailTextLabel?.text = String(format: "%.f亩", preArea)
            case 4:
                if self.labelPostion == nil {
                    self.labelPostion = cell.detailTextLabel
                }
                if prePosition != ""{
                     cell.detailTextLabel?.text = prePosition
                }
            default:
                break
            }
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row != 0 {
            textFieldName?.resignFirstResponder()
            if textFieldName?.isFirstResponder() == true{
                return 
            }
            switch indexPath.row {
            case 1:
                AlertTimeChooseViewController.pushAlertInViewController(self, date: cropCreateDate ?? NSDate(), block: {  date in
                    //要把数据替换掉
                    //然后显示出来
                    self.cropCreateDate = date
                    self.cropCreateTime = date.timeIntervalSince1970
                    self.preDate = self.formatter.stringFromDate(date)
                    self.dateChange = self.preDate != self.formatter.stringFromDate(date)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    })
            case 2:
                AlertCropsChooseViewController.pushAlertInViewController(self, block: { crop in
                    if self.selectCrop?.id != crop.id{
                        self.selectCrop = crop
                        self.preCrops = crop.name
                        self.cropChange = true
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    }
                })
            case 3:
                AreaGetWayChooseViewController.pushAlertInViewController(self, block: { value in
                        self.preArea = value
                        self.areaChange = true
                        self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                })
            case 4:
                getFarmLandPostion()
            default:
                break
            }
        }else{
            textFieldName?.becomeFirstResponder()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
}
