//
//  TYAnalyze.swift
//  智慧田园
//
//  Created by jason on 16/5/30.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import PNChart
class TYAnalyze: UIView {
    enum Period:String{
        case Day = "Day"
        case Week = "Week"
        case Month = "Month"
        case Year = "Year"
    }
    enum Data:String{
        case airT = "airT"
        case airW = "airW"
        case co2 = "co2"
        case light = "light"
        case recordTime = "recordTime"
        case soilT = "soilT"
        case soilW = "soilW"
    }
    @IBOutlet weak var StackView: UIStackView!
    @IBOutlet weak var LabelTitle: UILabel!
    @IBOutlet weak var ButtonOne: UIButton!
    @IBOutlet weak var ButtonTwo: UIButton!
    @IBOutlet weak var ButtonThird: UIButton!
    @IBOutlet weak var ButtonFour: UIButton!
    @IBOutlet weak var ChartContentView: UIView!
    var lineChart:PNLineChart!
    var action:((index:Int) -> Void)!
    var todate = NSDate()
    var destDate = Period.Day//目标时间
    var destDates = [Period.Day,Period.Week,Period.Month,Period.Year]
    var dataType = Data.airT
    var lastSelectedButton:UIButton?
    weak var crop:Crops!
    weak var field:Farmland!
    override func awakeFromNib() {
        super.awakeFromNib()
        lineChartConfigure()
        freshDataFromNetWork()
    }
    
    func lineChartConfigure(){
        
        lineChart = PNLineChart(frame: CGRectMake(0, 0, ChartContentView.frame.width, ChartContentView.frame.height) )
        self.ChartContentView.addSubview(lineChart)
        self.lineChart.showCoordinateAxis = true
        lineChart.yLabelFormat = "%.1f"
        lineChart.backgroundColor = UIColor.clearColor()
        ChartContentView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func ButtonPageClicked(sender: UIButton) {
        if let lastBtn = lastSelectedButton{
            lastBtn.selected = false
        }
        lastSelectedButton = sender
        lastSelectedButton?.selected = true
        destDate = destDates[sender.tag - 101]
        freshDataFromNetWork()
    }
    
    func setButtonTitle(title:String,index:Int){
        let btn = StackView.viewWithTag(index + 100) as! UIButton
        btn.setTitle(title, forState: .Normal)
    }
    
    func setButtonTitles(titles:[String]){
        for i in 0..<titles.count{
            setButtonTitle(titles[i],index: i+1)
        }
    }
    
    func setTitle(title:String){
        self.LabelTitle.text = title
    }
    
    func freshDataFromNetWork(){
        var XLabels = [String]()
        var Yvalues = [CGFloat]()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd"
        if self.destDate == .Day{
            dateFormatter.dateFormat = "hh点"
        }
        NetWorkManager.updateSession {
            TYRequest(ContentType.fieldAnalyze, parameters: ["fieldNo":self.field.id,"cropNo":self.crop.id,"timeScope":self.destDate.rawValue,"number":1]).TYresponseJSON(completionHandler: { (response) in
                if response.result.isSuccess{
                    if let json = response.result.value as? [String:AnyObject]{
                        if let msg = json["message"] as? String where msg == "success"{
                           if let dataArry = json["fieldDatas"] as? NSArray{
                            for x in dataArry{
                                    if let object = x as? [String:AnyObject]{
                                        let recordDate = NSDate(timeIntervalSince1970: (object["recordTime"] as! Double)/1000)
                                        XLabels.append(dateFormatter.stringFromDate(recordDate))
                                        Yvalues.append(object[self.dataType.rawValue] as! CGFloat)
                                    }
                                }
                            self.lineChart.xLabels = XLabels
                            let dataY = PNLineChartData()
                            dataY.color = UIColor.MainColor()
                            dataY.itemCount = UInt(Yvalues.count)
                            dataY.getData = {
                                index in
                                let value = Yvalues[Int(index)]
                                return PNLineChartDataItem(y: value)
                            }
                            self.lineChart.chartData = [dataY]
                            
                            self.lineChart.strokeChart()
            
                            
                            }
                        }
                    }
                }
                
            })
        }
       
    }
    
}
