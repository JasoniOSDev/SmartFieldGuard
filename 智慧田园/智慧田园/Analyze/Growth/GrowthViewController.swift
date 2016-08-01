//
//  GrowthViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/30.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import PNChart
class GrowthViewController: TYViewController {
    
    @IBOutlet weak var StackViewLabel: UIStackView!
    @IBOutlet weak var LabelCount: UILabel!
    @IBOutlet weak var LabelSum: UILabel!
    var CirChart: PNCircleChart!
    var CirChart2:PNCircleChart!
    var crop:Crops!
    override func viewDidLoad() {
        super.viewDidLoad()
        CirChartConfigure()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        CirChart.strokeChart()
    }

    func CirChartConfigure(){
        CirChart2 = PNCircleChart(frame: CGRectMake(0, 0, ScreenWidth - 80, ScreenWidth - 80), total: NSNumber(integer: 1), current: NSNumber(integer:1), clockwise: false)
        CirChart2.countingLabel.hidden = true
        CirChart2.strokeColor = UIColor.LowBlackColor()
        CirChart2.backgroundColor = UIColor.clearColor()
        CirChart2.center = StackViewLabel.center
        CirChart2.center.y -= 20
        CirChart2.lineWidth = NSNumber(integer: 20)
        CirChart2.displayAnimated = false
        CirChart2.strokeChart()
        
        self.view.addSubview(CirChart2)
        
        CirChart = PNCircleChart(frame: CGRectMake(0, 0, ScreenWidth - 80, ScreenWidth - 80), total: NSNumber(integer: 100), current: NSNumber(integer:90), clockwise: false)
        CirChart.countingLabel.hidden = true
        CirChart.current = NSNumber(integer: crop.currentTime)
        CirChart.total = NSNumber(integer: crop.growDays)
        CirChart.strokeColor = UIColor.MainColor()
        CirChart.backgroundColor = UIColor.clearColor()
        CirChart.center = StackViewLabel.center
        CirChart.center.y -= 20
        CirChart.lineWidth = NSNumber(integer: 20)

        self.view.addSubview(CirChart)
        
        LabelSum.text = "/\(crop.growDays)天"
        LabelCount.text = "\(crop.currentTime)"
    }

}
