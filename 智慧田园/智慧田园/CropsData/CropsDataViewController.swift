//
//  CropsDataViewController.swift
//  智慧田园
//
//  Created by jason on 2016/9/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MBProgressHUD
class CropsDataViewController: UIViewController {

    @IBOutlet weak var LabelCropsName: UILabel!
    @IBOutlet weak var cropsDataBackView: CropsDataBackView!
    @IBOutlet weak var ButtonCreateCode: UIButton!
    @IBOutlet weak var ButtonClose: UIButton!
    @IBOutlet weak var ImageViewCrops: UIImageView!
    var field:Farmland!
    var imageViewBinaryCode:UIImageView?
    var CropsDataViewAddress: CropsDataView!
    var CropsDataViewSun: CropsDataView!
    var CropsDataViewWater: CropsDataView!
    var CropsDataViewFer: CropsDataView!
    var CropsDataViewTemp: CropsDataView!
    lazy var longPressGesture:UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer()
        gesture.minimumPressDuration = 0.5
        gesture.addTarget(self, action: #selector(self.longPressBinaryCodeAction))
        return gesture
    }()
    lazy var imageScanController:MessagePhotoScanController = {
        let viewController = MessagePhotoScanController(OK: "123")
        viewController.view.addGestureRecognizer(self.longPressGesture)
        viewController.singleTapGesture.requireGestureRecognizerToFail(self.longPressGesture)
        viewController.view.removeGestureRecognizer(viewController.doubleTapGesture)
        return viewController
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageViewCropsConfigure()
        cropsDataViewConfgire()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func longPressBinaryCodeAction(){
        let alterController = UIAlertController(title: nil, message: "将作物档案共享给其他人", preferredStyle: .ActionSheet)
        alterController.addAction(UIAlertAction(title: "保存到本地图库", style: .Default, handler: { (_) in
            //保存到本地图库
            UIImageWriteToSavedPhotosAlbum((self.imageViewBinaryCode?.image)!, self, #selector(self.imageCodeSaveCompletion(_:error:info:)), nil)
        }))
        alterController.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        imageScanController.presentViewController(alterController, animated: true, completion: nil)
    }
    
    func imageCodeSaveCompletion(image:UIImage,error:NSError?,info:AnyObject){
        if error == nil {
            MBProgressHUD.showSuccess("保存成功", toView: nil)
            imageScanController.dismissViewControllerAnimated(true, completion: nil)
        }else{
            MBProgressHUD.showError("保存失败,请重试", toView: nil)
        }
    }
    
    private func cropsDataViewConfgire(){
        CropsDataViewAddress = CropsDataView()
        CropsDataViewSun = CropsDataView()
        CropsDataViewTemp = CropsDataView()
        CropsDataViewFer = CropsDataView()
        CropsDataViewWater = CropsDataView()
        self.cropsDataBackView.addSubview(CropsDataViewWater)
        self.cropsDataBackView.addSubview(CropsDataViewFer)
        self.cropsDataBackView.addSubview(CropsDataViewSun)
        self.cropsDataBackView.addSubview(CropsDataViewTemp)
        self.cropsDataBackView.addSubview(CropsDataViewAddress)
        CropsDataViewSun.dataType = .Sun
        CropsDataViewWater.dataType = .Water
        CropsDataViewFer.dataType = .Fer
        CropsDataViewTemp.dataType = .Temp
        loadData()
    }
    
    private func setCropsDataViewFrame(){
        CropsDataViewAddress.translatesAutoresizingMaskIntoConstraints = false
        CropsDataViewAddress.SetConstraint()
        CropsDataViewAddress.snp_makeConstraints { (make) in
            make.top.equalTo(LabelCropsName).offset(50)
            make.centerX.equalTo(self.view)
        }
        CropsDataViewSun.translatesAutoresizingMaskIntoConstraints = false
        CropsDataViewSun.SetConstraint()
        CropsDataViewSun.snp_makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-10)
            make.centerY.equalTo(self.ImageViewCrops).offset(-120)
        }
        CropsDataViewWater.translatesAutoresizingMaskIntoConstraints = false
        CropsDataViewWater.SetConstraint()
        CropsDataViewWater.snp_makeConstraints { (make) in
            make.right.equalTo(CropsDataViewSun)
            make.centerY.equalTo(self.ImageViewCrops).offset(110)
        }
        CropsDataViewFer.translatesAutoresizingMaskIntoConstraints = false
        CropsDataViewFer.SetConstraint()
        CropsDataViewFer.snp_makeConstraints { (make) in
            make.left.equalTo(self.view).offset(10)
            make.centerY.equalTo(self.ImageViewCrops).offset(120)
        }
        CropsDataViewTemp.translatesAutoresizingMaskIntoConstraints = false
        CropsDataViewTemp.SetConstraint()
        CropsDataViewTemp.snp_makeConstraints { (make) in
            make.left.equalTo(CropsDataViewFer)
            make.centerY.equalTo(self.ImageViewCrops).offset(-110)
        }
        self.view.layoutIfNeeded()
    }
    
    private func loadData(){
        //模拟
        LabelCropsName.text = "品名: " + (field.crops?.name)!
        CropsDataViewAddress.title = field.positionStr
        CropsDataViewAddress.contentPosition = .Top
        CropsDataViewSun.contentPosition = .Right
        CropsDataViewWater.contentPosition = .Right
        CropsDataViewFer.contentPosition = .Left
        CropsDataViewTemp.contentPosition = .Left
        CropsDataViewSun.arrowType = .High
        CropsDataViewTemp.arrowType = .Low
        
        let hud = MBProgressHUD.showMessage("正在获取作物档案", view: nil)
        NetWorkManager.getCropsData(field.id) { (temp, sun, water, liusuanjia, puGai, niaosu, tag) in
            self.CropsDataViewTemp.title = String(format: temp! * 10 % 10 == 0 ? "%.f" : "%.1f", temp!)
            self.CropsDataViewSun.title = String(format: "%.f", sun!)
            self.CropsDataViewWater.title = String(format: "%.f",water!)
            self.CropsDataViewFer.title = String(format: "%.f/%.f/%.f",liusuanjia!,puGai!,niaosu!)
                hud.hidden = true
                self.setCropsDataViewFrame()
                let endPointArray = [
                    self.cropsDataBackView.convertPoint(self.CropsDataViewAddress.anchor, fromView: self.CropsDataViewAddress),
                    self.cropsDataBackView.convertPoint(self.CropsDataViewSun.anchor, fromView: self.CropsDataViewSun),
                    self.cropsDataBackView.convertPoint(self.CropsDataViewWater.anchor, fromView: self.CropsDataViewWater),
                    self.cropsDataBackView.convertPoint(self.CropsDataViewFer.anchor, fromView: self.CropsDataViewFer),
                    self.cropsDataBackView.convertPoint(self.CropsDataViewTemp.anchor, fromView: self.CropsDataViewTemp)]
                var startPointArray = [CGPoint]()
                for x in endPointArray{
                    startPointArray.append(self.getStartPoint(x))
                }
                self.cropsDataBackView.strokeLine(startPointArray, endPoint: endPointArray)
            }
    }
    
    private func getStartPoint(endPoint:CGPoint) -> CGPoint{
        let center = ImageViewCrops.center
        let dis = sqrt(Float((endPoint.y - center.y)*(endPoint.y - center.y) + (endPoint.x - center.x)*(endPoint.x - center.x)))
        let percent = CGFloat(55/dis)
        return CGPointMake(center.x + percent * (endPoint.x - center.x), center.y + percent * (endPoint.y - center.y))
    }
    
    private func ImageViewCropsConfigure(){
        ImageViewCrops.layer.cornerRadius = 70
    }

    @IBAction func ButtonCreateCodeClicked(sender: AnyObject) {
        ButtonClose.hidden = true
        ButtonCreateCode.hidden = true
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64 (500 * NSEC_PER_MSEC)), dispatch_get_main_queue()) { 
            let screenImage = UIImage.screenshot()
            let hud = MBProgressHUD.showMessage(nil, view: nil)
            self.ButtonClose.hidden = false
            self.ButtonCreateCode.hidden = false
            NetWorkManager.uploadBinaryCode(screenImage, block: { (url) in
                hud.hidden = true
                if let url = url {
                    self.imageViewBinaryCode = UIImageView(image: url.binaryCodeCreate())
                    self.imageScanController.setImages([self.imageViewBinaryCode!], imagesURL: [""], index: 0)
                    self.imageScanController.pushScanController()
                    MBProgressHUD.showSuccess("长按将分享给其他人", toView: nil)
                }
            })
        }
    }
    
    @IBAction func ButtonCloseClicked() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
