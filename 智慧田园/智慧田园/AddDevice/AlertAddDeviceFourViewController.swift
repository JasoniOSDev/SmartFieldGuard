//
//  AlertAddDeviceFourViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
class AlertAddDeviceFourViewController: TYViewController,GCDAsyncSocketDelegate {
    
    @IBOutlet weak var ViewForProgress: UIView!
    @IBOutlet weak var LabelProgress: UILabel!
    @IBOutlet weak var ButtonClose: UIButton!
    var mySocket:GCDAsyncSocket!
    let shapeLayer = CAShapeLayer()
    var timer:NSTimer?
    var progress:Double = 0{
        didSet{
            if(progress>=100){
                progress = 100
                ButtonClose.enabled = true
            }
            self.LabelProgress.text = String(format: "%.f", progress) + "%"
        }
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(335, 335)
        setProgress()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        self.title = "即将完成"
        self.navigationItem.hidesBackButton = true
        ProgressStart()
        connectToArduino()
    }
    
    func connectToArduino(){
        mySocket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        try! mySocket.connectToHost("192.168.240.1", onPort: 5757)
    }
    
    //socket代理
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
//        print("已连接到")
//        print("host:\(host)\tport:\(port)")
        let wifiInfo = "{\"type\":\"connect_wifi\", \"ssid\":\(AlertAddDeviceSecondViewController.wifiName),\"psw\":\(AlertAddDeviceSecondViewController.wifiPassWord), \"encryption\":\"psk2\",\"userId\":\((TYUserDefaults.userID.value)!)}\n".dataUsingEncoding(NSUTF8StringEncoding)
        mySocket.writeData(wifiInfo!, withTimeout: 10, tag: 1)
        
    }
    
    func socket(sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
//        print("成功写入数据tag:\(tag)")
        mySocket.readDataWithTimeout(5, tag: 1)
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int) {
//        print("成功读取到数据")
//        print( String(data: data, encoding: NSUTF8StringEncoding))
    }
    
    func setProgress(){
        let baseShapeLayer = CAShapeLayer()
        let path = UIBezierPath(ovalInRect: CGRectMake(0, 0, 160, 160)).CGPath
        baseShapeLayer.fillColor = nil
        baseShapeLayer.strokeColor = UIColor.MidBlackColor().CGColor
        baseShapeLayer.lineWidth = 8
        baseShapeLayer.path = path
        ViewForProgress.layer.addSublayer(baseShapeLayer)
        ViewForProgress.layer.addSublayer(shapeLayer)
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.MainColor().CGColor
        shapeLayer.lineWidth = 8
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.path = path
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 0
    }
    
    func updateProgress(){
        var len = Int(arc4random_uniform(7))
        while(len == 0){
            len = Int(arc4random_uniform(7))
        }
        updateProgressWithAnimation(len)
        
        if(self.progress + Double(len) >= 100){
            return
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1*NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.updateProgress()
        }
    }
    
    func updateProgressWithAnimation(len:Int){
        let progressDis = Double(len)/40
        let strokeDis = CGFloat(progressDis/100)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { 
            for _ in 0..<40{
                dispatch_async(dispatch_get_main_queue(), {
                    self.progress += progressDis
                    self.shapeLayer.strokeEnd += strokeDis
                })
                NSThread.sleepForTimeInterval(0.025)
            }
        }
        
    }
    
    func ProgressStart(){
        progress = 0
        shapeLayer.strokeEnd = 0
        shapeLayer.strokeStart = 0
        ButtonClose.enabled = false
        updateProgress()
    }
    
    @IBAction func ButtonCloseClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
