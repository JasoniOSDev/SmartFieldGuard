//
//  SunViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/30.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import PNChart
class SunViewController: TYViewController {

    var AnalyzeViewT:TYAnalyze!//展示强度
    var crop:Crops!
    var field:Farmland!
    override func viewDidLoad() {
        super.viewDidLoad()
        analyzeViewConfigure()
    }
    
    func analyzeViewConfigure(){
        AnalyzeViewT = NSBundle.mainBundle().loadNibNamed("TYAnalyze", owner: nil, options: nil)![0] as! TYAnalyze
        AnalyzeViewT.setTitle("光照强度(LUX)")
        self.view.addSubview(AnalyzeViewT)
        AnalyzeViewT.snp_makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(30)
            make.height.equalTo(300)
        }
        AnalyzeViewT.dataType = .light
        AnalyzeViewT.crop = self.crop
        AnalyzeViewT.field = field
        
    }

}
