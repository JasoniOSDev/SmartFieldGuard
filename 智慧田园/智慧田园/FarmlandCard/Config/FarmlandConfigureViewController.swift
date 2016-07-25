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
    weak var labelTime:UILabel?
    weak var labelCropsName:UILabel?
    weak var labelArea:UILabel?
    weak var labelPostion:UILabel?
    var time:String?
    var cropsName:String?
    var area = 0.0
    var position:CLLocationCoordinate2D?
    var positionStr:String?
    var cropCreateTime:NSTimeInterval = 0
    var cropCreateDate:NSDate?
    var selectCrop:Crops?
    let locationManager = AMapLocationManager()
    var farmLand:Farmland!{
        didSet{
            if let crop = farmLand.crops{
                cropCreateDate = crop.startDate
                cropCreateTime = crop.starTime
            }
            self.time = self.formatter.stringFromDate(cropCreateDate!)
            self.cropsName = self.farmLand.name
            area = farmLand.mianji
            if farmLand.positionStr != ""{
                positionStr = farmLand.positionStr
                position = CLLocationCoordinate2D(latitude: farmLand.latitude, longitude: farmLand.longitude)
            }
        }
    }
    lazy var formatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }()
    var nameChange = false
    var timeChange = false
    var cropChange = false
    var areaChange = false
    var positionChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    func prepareUI(){
        tableViewConfigure()
        navigationItemConfigure()
    }
    
    func navigationItemConfigure(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Close_White"), style: .Plain, target: self, action: #selector(self.closeAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "OK_White"), style: .Plain, target: self, action: #selector(self.FinishAction))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadData()
    }
    
    func locationManagerConfigure(){
        AMapLocationServices.sharedServices().apiKey = GDKey
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        getFarmLandPostion()
    }
    
    func getFarmLandPostion(){
        self.labelPostion?.text = "正在获取位置"
        locationManager.requestLocationWithReGeocode(true) { [weak self] location, geoCode, error in
            if let sSelf = self where error == nil{
                sSelf.position = location.coordinate
                sSelf.positionStr = geoCode.province + " " + geoCode.city + " " + geoCode.district
                sSelf.positionChange = true
                sSelf.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 0)], withRowAnimation: .None)
            }
        }
    }
    
    func loadData(){
        if let crop = farmLand.crops{
            LabelTitle.text = farmLand.name
            LabelStartTime.text = "播种日期 " + farmLand.startTimeStr
            CropsImg.sd_setImageWithURL(NSURL(string: crop.urlDetail), placeholderImage: UIImage(named:  "FarmCard_Crops_UnSet"))
        }
         locationManagerConfigure()
    }

    
    func closeAction(){
        //执行一些操作
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func FinishAction(){
        var wrongInfo = "名称过长或为空"
        if let name = textFieldName?.text where (name.characters.count <= 6 && name != "") {
            wrongInfo = "播种日期未选择"
            if let _ = labelTime?.text where cropCreateDate != nil{
                wrongInfo = "农作物未选择"
                if let cropsName = labelCropsName?.text where cropsName != "选择中" && cropsName != ""{
                    wrongInfo = "农田面积未设置"
                    if area != 0.0{
                        wrongInfo = "等待农田定位"
                        if position != nil{
                            wrongInfo = "Success"
                            //向服务器发送请求
                            if self.selectCrop == nil {
                                self.selectCrop = farmLand.crops
                            }
                            NetWorkManager.updateSession{
                                TYRequest(ContentType.fieldSet, parameters: ["fieldNo":self.farmLand.id,"fieldName":name,"fieldArea":String(format: "%.f",self.area),"longitude":self.position!.longitude,"latitude":self.position!.latitude,"cropNo":self.selectCrop!.id,"startTime":String(format: "%.f",Double(self.cropCreateTime))]).TYresponseJSON(completionHandler: { [weak self] response in
                                    print(response)
                                     try! ModelManager.realm.write({
                                        if self?.positionChange == true{
                                            self?.farmLand.positionStr = (self?.labelPostion?.text)!
                                            self?.farmLand.latitude = (self?.position!.latitude)!
                                            self?.farmLand.longitude = (self?.position!.longitude)!
                                        }
                                        if self?.areaChange == true{
                                            self?.farmLand.mianji = (self?.area)!
                                        }
                                        self?.farmLand.name = name
                                        if let crop = self!.farmLand.crops,let sSelf = self{
                                            crop.startDate = sSelf.cropCreateDate!
                                            crop.starTime = sSelf.cropCreateTime
                                        }
                                    })
                                    self?.loadData()
                                    if self?.cropChange == true{
                                        if let sSelf = self,let crop = sSelf.selectCrop {
                                            NetWorkManager.getCrops(crop.id, action: { [weak self] crop in
                                                try! ModelManager.realm.write({
                                                    if let sSelf = self {
                                                        crop.operatorid = sSelf.farmLand.id + crop.id + String(format: "%.f", (NSDate().timeIntervalSinceReferenceDate)%10000)
                                                        crop.startDate = sSelf.cropCreateDate!
                                                        crop.starTime = sSelf.cropCreateTime
                                                        sSelf.farmLand.crops = crop
                                                        sSelf.farmLand.tasking.removeAll()
                                                        MBProgressHUD.showSuccess("设置成功", toView: nil)
                                                        sSelf.loadData()
                                                    }
                                                })
                                                
                                            })
                                        }
                                    }else{
                                        MBProgressHUD.showSuccess("设置成功", toView: nil)
                                    }
                                })
                            }
                            
                        }
                    }
                }
            }
        }
        if wrongInfo != "Success"{
            MBProgressHUD.showError(wrongInfo, toView: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.subviews[0].alpha = 0
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
    }
    
    func tableViewConfigure(){
        tableView.registerReusableCell(FarmlandConfigTableViewCell)
        tableView.clearOtherLine()
    }
    
}
extension FarmlandConfigureViewController:UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
            cell.TextFieldDetail.text = farmLand.name == "未设置" ? nil : farmLand.name
            self.textFieldName = cell.TextFieldDetail
            self.textFieldName?.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
            cell.textLabel?.text = titles[indexPath.row]
            switch indexPath.row {
            case 1:
                //先要获取一下当前有没有设置了时间
                if self.labelTime == nil {
                    self.labelTime = cell.detailTextLabel
                }
                if cropCreateDate != nil{
                    cell.detailTextLabel?.text = time
                }
                
            case 2:
                if self.labelCropsName == nil{
                    self.labelCropsName = cell.detailTextLabel
                }
                cell.detailTextLabel?.text = cropsName
                
            case 3:
                if self.labelArea == nil {
                    self.labelArea = cell.detailTextLabel
                }
                cell.detailTextLabel?.text = String(format: "%.f亩", area)
            case 4:
                if self.labelPostion == nil {
                    self.labelPostion = cell.detailTextLabel
                }
                if farmLand.positionStr != ""{
                    self.labelPostion?.text = self.positionStr
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
            switch indexPath.row {
            case 1:
                AlertTimeChooseViewController.pushAlertInViewController(self, date: cropCreateDate ?? NSDate(), block: { [weak self] date in
                    //要把数据替换掉
                    //然后显示出来
                    self?.cropCreateDate = date
                    self?.cropCreateTime = date.timeIntervalSince1970
                    self?.time = self?.formatter.stringFromDate(date)
                    self?.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    })
            case 2:
                AlertCropsChooseViewController.pushAlertInViewController(self, block: { [weak self] crop in
                    if let sSelf = self {
                        if sSelf.selectCrop?.id != crop.id{
                            sSelf.selectCrop = crop
                            sSelf.cropChange = true
                            sSelf.cropsName = crop.name
                            sSelf.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                        }
                    }
                })
            case 3:
                AreaGetWayChooseViewController.pushAlertInViewController(self, block: { [weak self] value in
                    if let sSelf = self {
                        sSelf.area = value
                        sSelf.areaChange = true
                        sSelf.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    }
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
