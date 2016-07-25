//
//  FertilizeViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/30.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import PNChart
class FertilizeViewController: TYViewController {

    @IBOutlet weak var CharContentView: UIView!
    @IBOutlet weak var ButtonOne: UIButton!
    var todate = NSDate()
    var destDate = NSDate()//目标时间
    var destDates = [NSDate]()
    var pieChart:PNPieChart?
    var lastBtn:UIButton?
    var todayDate = NSDate()
    var destdate = NSTimeInterval()
    var destdates = [NSTimeInterval]()
    var colors = [UIColor.MainColor(),UIColor.DangerColor(),UIColor.WarnColor()]
    override func viewDidLoad() {
        super.viewDidLoad()
        PageButtonClicked(ButtonOne)
    }
    @IBAction func PageButtonClicked(sender: UIButton) {
        if let btn = lastBtn{
            btn.selected = false
        }
        lastBtn = sender
        lastBtn?.selected = true
        freshDataFromNetWork()
    }
    var dict = ["尿素":123,"普钙":323,"硫酸钾":532]
    var dict2 = ["尿素":135,"普钙":328,"硫酸钾":195]
    var dict3 = ["尿素":321,"普钙":223,"硫酸钾":232]
    var dict4 = ["尿素":2334,"普钙":4421,"硫酸钾":312]
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        pieChart?.strokeChart()
    }
    func freshDataFromNetWork(){
        if let _ = pieChart{
            pieChart!.removeFromSuperview()
        }
        
//        let datas = ModelManager.getObjects(HistoryFertilize).filter("self.time <= %@ and self.time >= %@", todayDate.timeIntervalSince1970,destdate)
//        var dict = [String:Double]()
//        datas.forEach { (x) in
//            x.history.forEach({ (y) in
//                if dict[y.name] == nil{
//                    dict[y.name] = y.value
//                }else{
//                    dict[y.name] = dict[y.name]! + y.value
//                }
//            })
//        }
        
        var dataItems = [PNPieChartDataItem]()
        
        var i = 0
        var dis = 0
        if ModelManager.realm.objects(Tasking).filter("self.status = true and self.name = '临时加肥'").count > 0{
            dis = 233
        }
        switch lastBtn!.tag {
        case 101:
            dict.forEach { (x) in
                dataItems.append(PNPieChartDataItem(value: CGFloat(x.1 +  dis), color: self.colors[i%3] , description: x.0))
                i += 1
            }
        case 102:
            dict2.forEach { (x) in
                dataItems.append(PNPieChartDataItem(value: CGFloat(x.1 + dis), color: self.colors[i%3], description: x.0))
                i += 1
            }
        case 103:
            dict3.forEach { (x) in
                dataItems.append(PNPieChartDataItem(value: CGFloat(x.1 + dis), color: self.colors[i%3], description: x.0))
                i += 1
            }
        case 104:
            dict4.forEach { (x) in
                dataItems.append(PNPieChartDataItem(value: CGFloat(x.1 + dis), color: self.colors[i%3], description: x.0))
                i += 1
            }
        default:
            break
        }
        
        self.pieChart = PNPieChart(frame: CGRectMake(0, 0, CharContentView.frame.width, CharContentView.frame.height), items: dataItems)
        self.view.addSubview(pieChart!)
        pieChart!.snp_makeConstraints(closure: { (make) in
            make.height.width.equalTo(self.CharContentView)
            make.center.equalTo(self.CharContentView)
        })
        self.pieChart?.backgroundColor = UIColor.clearColor()
        self.pieChart?.descriptionTextColor = UIColor.whiteColor()
        self.pieChart?.descriptionTextFont = UIFont(name: NormalLanTingHeiFontName, size: 14)
        self.pieChart?.showAbsoluteValues = false
        self.pieChart?.strokeChart()
    }



}
