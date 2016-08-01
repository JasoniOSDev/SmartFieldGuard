//
//  AirViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/30.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import PNChart
class AirViewController: TYViewController {

    var AnalyzeViewT:TYAnalyze!//展示温度
    var AnalyzeViewW:TYAnalyze!//展示湿度
    var AnalyzeViewCO2:TYAnalyze!//展示二氧化碳
    weak var crop:Crops!
    weak var field:Farmland!
    var scrollView:UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        analyzeViewConfigure()
    }
    
    func analyzeViewConfigure(){
        
        scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.frame = self.view.bounds
        self.view.addSubview(scrollView)
        AnalyzeViewT = NSBundle.mainBundle().loadNibNamed("TYAnalyze", owner: nil, options: nil)[0] as! TYAnalyze
        AnalyzeViewT.setTitle("温度(℃)")
        scrollView.addSubview(AnalyzeViewT)
        AnalyzeViewT.frame = CGRectMake(0, 30, ScreenWidth, 300)
        AnalyzeViewT.dataType = .airT
        AnalyzeViewT.crop = crop
        AnalyzeViewT.field = self.field
        
        AnalyzeViewW = NSBundle.mainBundle().loadNibNamed("TYAnalyze", owner: nil, options: nil)[0] as! TYAnalyze
        AnalyzeViewW.setTitle("湿度(%)")
        scrollView.addSubview(AnalyzeViewW)
        AnalyzeViewW.frame = CGRectMake(0,AnalyzeViewT.frame.maxY, ScreenWidth, 300)
        AnalyzeViewW.dataType = .airW
        AnalyzeViewW.crop = crop
        AnalyzeViewW.field = self.field
        
        AnalyzeViewCO2 = NSBundle.mainBundle().loadNibNamed("TYAnalyze", owner: nil, options: nil)[0] as! TYAnalyze
        AnalyzeViewCO2.setTitle("CO2浓度(ppm)")
        scrollView.addSubview(AnalyzeViewCO2)
        AnalyzeViewCO2.frame = CGRectMake(0,AnalyzeViewW.frame.maxY, ScreenWidth, 300)
        AnalyzeViewCO2.dataType = .co2
        AnalyzeViewCO2.crop = crop
        AnalyzeViewCO2.field = self.field
        
        AnalyzeViewCO2.layoutIfNeeded()
        scrollView.contentSize.height = AnalyzeViewCO2.frame.maxY + 100
        scrollView.contentSize.width = ScreenWidth
        
    }


}
