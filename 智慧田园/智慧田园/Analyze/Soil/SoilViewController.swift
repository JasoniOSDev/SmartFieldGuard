//
//  SoilViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/30.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import PNChart
class SoilViewController: TYViewController {

    var AnalyzeViewT:TYAnalyze!//展示温度
    var AnalyzeViewW:TYAnalyze!//展示湿度
    var crop:Crops!
    var field:Farmland!
    override func viewDidLoad() {
        super.viewDidLoad()
        analyzeViewConfigure()
    }
    
    func analyzeViewConfigure(){
        AnalyzeViewT = NSBundle.mainBundle().loadNibNamed("TYAnalyze", owner: nil, options: nil)![0] as! TYAnalyze
        AnalyzeViewT.setTitle("温度(℃)")
        self.view.addSubview(AnalyzeViewT)
        AnalyzeViewT.snp_makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(30)
            make.height.equalTo(300)
        }
        AnalyzeViewT.dataType = .soilT
        AnalyzeViewT.crop = crop
        AnalyzeViewT.field = field
            AnalyzeViewW = NSBundle.mainBundle().loadNibNamed("TYAnalyze", owner: nil, options: nil)![0] as! TYAnalyze
        AnalyzeViewW.setTitle("湿度(%)")
        self.view.addSubview(AnalyzeViewW)
        AnalyzeViewW.snp_makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(AnalyzeViewT.snp_bottom)
            make.height.equalTo(300)
        }
         AnalyzeViewW.dataType = .soilW
        AnalyzeViewW.crop = crop
        AnalyzeViewW.field = field
        
    }


}
