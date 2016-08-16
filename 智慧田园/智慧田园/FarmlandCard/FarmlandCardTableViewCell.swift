//
//  FarmlandCardTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class FarmlandCardTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var ImgView: UIImageView!
    @IBOutlet weak var LabelTitle: UILabel!
    @IBOutlet weak var StackViewTask: UIStackView!
    @IBOutlet weak var LabelDataAir_T: UILabel!
    @IBOutlet weak var LabelDataAir_W: UILabel!
    @IBOutlet weak var LabelDataSoil_T: UILabel!
    @IBOutlet weak var LabelDataSoil_W: UILabel!
    @IBOutlet weak var LabelDataSun: UILabel!
    @IBOutlet weak var LabelDataCO2: UILabel!
    @IBOutlet weak var ConstraintLabelTitleCenterX: NSLayoutConstraint!
    @IBOutlet weak var ConstraintLabelTitleLeft: NSLayoutConstraint!
    var farmLand:Farmland!{
        didSet{
            LabelTitle.text = farmLand.name
            if let url = farmLand.crops?.urlHome{
                self.ImgView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named:"Home_CropsUnSet"))
            }
            if farmLand.crops == nil {
                StackViewTask.hidden = true
                ConstraintLabelTitleCenterX.active = true
                ConstraintLabelTitleLeft.active = false
            }else{
                ConstraintLabelTitleCenterX.active = false
                ConstraintLabelTitleLeft.active = true
            }
            farmLand.fillDataInViewAction = fillAction
            farmLand.updateEnvironmentData(nil)
        }
    }
//    (air_t:Double,air_w:Double,soil_t:Double,soil_w:Double,co2:Double,light:Double) -> Void
    var fillAction: Farmland.fillAction!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.BackgroundColor()
        self.contentView.frame.size = CGSizeMake(ScreenWidth - 10, 120)
        contentView.layer.shadowColor = UIColor.LowBlackColor().CGColor
        contentView.layer.shadowOffset = CGSizeMake(1, 1.5)
        contentView.layer.shadowRadius = 2
        contentView.layer.shadowOpacity = 1
        fillAction  = {
            [weak self] air_t,air_w,soil_t,soil_w,co2,light in
            if let sSelf = self {
                sSelf.LabelDataAir_T.text = String(format: "%.f℃",air_t)
                sSelf.LabelDataAir_W.text = String(format: "%.f%%", air_w)
                sSelf.LabelDataSoil_T.text = String(format: "%.f℃", soil_t)
                sSelf.LabelDataSoil_W.text = String(format: "%.f%%", soil_w)
                sSelf.LabelDataCO2.text = String(format: "%.fppm", co2)
                sSelf.LabelDataSun.text = String(format: "%.fLUX", light)
                //更新颜色及对应的图标
                sSelf.updateModuleState()
            }
        }
    }
    
    //采取遍历的方式去更新每一个模块的颜色
    func updateModuleState(){
      //待实现
    }
    
}
