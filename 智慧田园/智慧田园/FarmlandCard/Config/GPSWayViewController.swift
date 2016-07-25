//
//  GPSWayViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/26.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class GPSWayViewController: UIViewController,MAMapViewDelegate {
    @IBOutlet weak var ConstraintButtonFinishCenterY: NSLayoutConstraint!
    @IBOutlet weak var ButtonAgain: UIButton!
    @IBOutlet weak var ButtonFinish: UIButton!
    @IBOutlet weak var mapView: MAMapView!
    var block:((Double) -> Void)?
    var points = [CLLocationCoordinate2D]()
    var line:MAPolyline?
    var polygon:MAPolygon?
    var drawLine:Bool = false
    lazy var areaViewController:AreaViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("AreaViewController") as! AreaViewController
        vc.block = self.block
        vc.from = "GPS"
        return vc
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewConfigure()
        ButtonAgain.addObserver(self, forKeyPath: "hidden", options: .New, context: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.popupController.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "hidden"{
            UIView.animateWithDuration(0.5, animations: { [weak self] in
                if(change!["new"] as! Bool == false){
                    self?.ConstraintButtonFinishCenterY.constant = 78.5
                }else{
                   self?.ConstraintButtonFinishCenterY.constant = 0
                }
                self?.view.layoutIfNeeded()
            })
        }
    }
    
    deinit{
        ButtonAgain.removeObserver(self, forKeyPath: "hidden")
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSizeMake(320, 500)
    }

    @IBAction func ButtonMyLocationClicked(sender: AnyObject) {
        if let lastPoint = points.last{
            mapView.setZoomLevel(18, atPivot:mapView.convertCoordinate(lastPoint, toPointToView: mapView) , animated: true)
            mapView.setUserTrackingMode(.Follow, animated: false)
        }
    }
    @IBAction func ButtonFinishClicked(sender: UIButton) {
        switch sender.currentTitle {
        case "开始"?:
            if let prePolygon = polygon{
                mapView.removeOverlay(prePolygon)
            }
            points.removeAll(keepCapacity: false)
            drawLine = true
            sender.setTitle("停止", forState: .Normal)
            ButtonAgain.hidden = true
        case "停止"?:
            drawLine = false
            if let Line = line{
                polygon = MAPolygon(coordinates: &points, count: UInt(points.count))
                mapView.addOverlay(polygon)
                mapView.removeOverlay(Line)
            }
            sender.setTitle("确定", forState: .Normal)
            ButtonAgain.hidden = false
        case "确定"?:
            //开始计算面积
            areaViewController.area = calcArea()
            self.popupController.pushViewController(areaViewController, animated: true)
            break
        default:
            break
        }
    }
    
    
    func calcArea() -> Double {
        let Count = points.count
        if (Count>3) {
            var mtotalArea:Double = 0
        
        var LowX=0.0
        var LowY=0.0
        var MiddleX=0.0
        var MiddleY=0.0
        var HighX=0.0
        var HighY=0.0
        
        var AM = 0.0
        var BM = 0.0
        var CM = 0.0
        
        var AL = 0.0
        var BL = 0.0
        var CL = 0.0
        
        var AH = 0.0
        var BH = 0.0
        var CH = 0.0
        
        var CoefficientL = 0.0
        var CoefficientH = 0.0
        
        var ALtangent = 0.0
        var BLtangent = 0.0
        var CLtangent = 0.0
        
        var AHtangent = 0.0
        var BHtangent = 0.0
        var CHtangent = 0.0
        
        var ANormalLine = 0.0
        var BNormalLine = 0.0
        var CNormalLine = 0.0
        
        var OrientationValue = 0.0
        
        var AngleCos = 0.0
        
        var Sum1 = 0.0
        var Sum2 = 0.0
        var Count2 = 0
        var Count1 = 0
        
        
        var Sum = 0.0
        let Radius:Double = 6378000
        
        for i in 0..<Count{
        if(i==0){
            LowX = points[Count-1].latitude * M_PI / 180
            LowY = points[Count-1].longitude * M_PI / 180
            MiddleX = points[0].latitude * M_PI / 180
            MiddleY = points[0].longitude * M_PI / 180
            HighX = points[1].latitude * M_PI / 180
            HighY = points[1].longitude * M_PI / 180
        }else if(i==Count-1){
            LowX = points[Count-2].latitude * M_PI / 180
            LowY = points[Count-2].longitude * M_PI / 180
            MiddleX = points[Count-1].latitude * M_PI / 180
            MiddleY = points[Count-1].longitude * M_PI / 180
            HighX = points[0].latitude * M_PI / 180
            HighY = points[0].longitude * M_PI / 180
        }else{
            LowX = points[i-1].latitude * M_PI / 180
            LowY = points[i-1].longitude * M_PI / 180
            MiddleX = points[i].latitude * M_PI / 180
            MiddleY = points[i].longitude * M_PI / 180
            HighX = points[i+1].latitude * M_PI / 180
            HighY = points[i+1].longitude * M_PI / 180
        }
        AM = cos(MiddleY) * cos(MiddleX)
        BM = cos(MiddleY) * sin(MiddleX)
        CM = sin(MiddleY)
        AL = cos(LowY) * cos(LowX)
        BL = cos(LowY) * sin(LowX)
        CL = sin(LowY)
        AH = cos(HighY) * cos(HighX)
        BH = cos(HighY) * sin(HighX)
        CH = sin(HighY)
        
        
        CoefficientL = (AM*AM + BM*BM + CM*CM)/(AM*AL + BM*BL + CM*CL);
        CoefficientH = (AM*AM + BM*BM + CM*CM)/(AM*AH + BM*BH + CM*CH);
        
        ALtangent = CoefficientL * AL - AM;
        BLtangent = CoefficientL * BL - BM;
        CLtangent = CoefficientL * CL - CM;
        AHtangent = CoefficientH * AH - AM;
        BHtangent = CoefficientH * BH - BM;
        CHtangent = CoefficientH * CH - CM;
        
        let y = (sqrt(AHtangent * AHtangent + BHtangent * BHtangent + CHtangent * CHtangent) * sqrt(ALtangent * ALtangent + BLtangent * BLtangent + CLtangent * CLtangent))
        let x = (AHtangent * ALtangent + BHtangent * BLtangent + CHtangent * CLtangent)
        AngleCos = x/y
        
        
        AngleCos = acos(AngleCos)
        
        ANormalLine = BHtangent * CLtangent - CHtangent * BLtangent
        BNormalLine = 0 - (AHtangent * CLtangent - CHtangent * ALtangent)
        CNormalLine = AHtangent * BLtangent - BHtangent * ALtangent
        
            if(AM != 0){
                
            OrientationValue = ANormalLine/AM
                
        }else if(BM != 0){
                
            OrientationValue = BNormalLine/BM
                
        }else {
                
            OrientationValue = CNormalLine/CM
                
        }
        if(OrientationValue>0){
            
            Sum1 += AngleCos
            Count1 += 1
        
        }
        else{
            Sum2 += AngleCos
            Count2 += 1
        //Sum +=2*Math.PI-AngleCos;
        }
        
        }
        
        if(Sum1>Sum2){
            
            Sum = Sum1+(2*M_PI*Double(Count2)-Sum2)
            
        }
        else{
            
            Sum = (2*M_PI*Double(Count1)-Sum1)+Sum2
            
        }
        
        //平方米
        mtotalArea = (Sum-Double(Count-2)*M_PI)*Radius*Radius;
        
        return mtotalArea
        }
        return 0
    }
    
    @IBAction func ButtonAgainClicked(sender: AnyObject) {
        ButtonFinish.setTitle("开始", forState: .Normal)
        ButtonFinishClicked(ButtonFinish)
        
    }
    func mapViewConfigure(){
        MAMapServices.sharedServices().apiKey = GDKey
        mapView.delegate = self
        mapView.userTrackingMode = .Follow
        mapView.allowsBackgroundLocationUpdates = true
        let locPre = MAUserLocationRepresentation()
        locPre.fillColor = UIColor.MainColor()
        locPre.strokeColor = UIColor.whiteColor()
        locPre.lineWidth = 3
        mapView.updateUserLocationRepresentation(locPre)
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Denied && CLLocationManager.locationServicesEnabled()){
            mapView.showsUserLocation = true
        }
        mapView.setZoomLevel(18, animated: true)
    }
    
    
    
    func mapView(mapView: MAMapView!, didUpdateUserLocation userLocation: MAUserLocation!) {
        if(drawLine == true){
            points.append(userLocation.coordinate)
            if let preLine = line{
                mapView.removeOverlay(preLine)
            }
            line = MAPolyline(coordinates: &points, count: UInt(points.count))
            mapView.addOverlay(line)
        }
    }
    
    func mapView(mapView: MAMapView!, rendererForOverlay overlay: MAOverlay!) -> MAOverlayRenderer! {
        if let _ = overlay as? MAPolyline{
            let renderer = MAPolylineRenderer(overlay: overlay)
            renderer.strokeColor =  UIColor.DangerColor()
            renderer.lineWidth = 20
            return renderer
        }else{
            let renderer = MAPolygonRenderer(overlay: overlay)
            renderer.fillColor = UIColor.MainColor()
            return renderer
        }
    }
   
}
