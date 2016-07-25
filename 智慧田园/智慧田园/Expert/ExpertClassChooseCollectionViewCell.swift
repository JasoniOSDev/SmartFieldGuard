//
//  ExpertClassChooseCollectionViewCell.swift
//  智慧田园
//
//  Created by Jason on 16/7/24.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class ExpertClassChooseCollectionViewCell: UICollectionViewCell {

    var NewContentView: UIView!
    var LabelTitle: UILabel!
    var title:String!{
        didSet{
            LabelTitle.text = title
            LabelTitle.sizeToFit()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NewContentView = UIView()
        self.addSubview(NewContentView)
        NewContentView.snp_makeConstraints { (make) in
            make.left.top.equalTo(self).offset(5)
            make.bottom.equalTo(self).offset(-5)
        }
        NewContentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        NewContentView.layer.borderWidth = 1
        NewContentView.layer.cornerRadius = 4
        LabelTitle = UILabel()
        LabelTitle.textAlignment = .Center
        LabelTitle.textColor = UIColor.blackColor()
        NewContentView.addSubview(LabelTitle)
        LabelTitle.snp_makeConstraints { (make) in
            make.center.equalTo(NewContentView)
            make.left.equalTo(NewContentView).offset(5)
            make.right.equalTo(NewContentView).offset(-5)
        }
        NewContentView.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        LabelTitle.setContentCompressionResistancePriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        NewContentView.layer.borderColor = UIColor.lightGrayColor().CGColor
        NewContentView.layer.borderWidth = 1
        NewContentView.layer.cornerRadius = 2
    }
    
    func Select(select:Bool){
        if select {
            NewContentView.layer.borderColor = UIColor.MainColor().CGColor
            LabelTitle.textColor = UIColor.MainColor()
        }else{
            NewContentView.layer.borderColor = UIColor.lightGrayColor().CGColor
            LabelTitle.textColor = UIColor.blackColor()
        }
    }
    

}
