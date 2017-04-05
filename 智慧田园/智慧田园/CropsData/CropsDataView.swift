//
//  DataView.swift
//  智慧田园
//
//  Created by jason on 2016/9/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class CropsDataView: UIView {
    enum CropsDataType:String{
        case Sun = "CropsData_Sun"
        case Water = "CropsData_Water"
        case Fer = "CropsData_Fertilizer"
        case Temp = "CropsData_Temp"
        case None = ""
    }
    enum Position{
        case Left
        case Right
        case Top
        case Bottom
    }
    enum Theme{
        case BlackTranslucent
    }
    
    enum Arrow:String{
        case High = "CropsData_Arrow_High"
        case Low = "CropsData_Arrow_Low"
        case Normal = ""
    }
    var Font:UIFont = UIFont(name: "FZCuYuan-M03", size: 14)!
    var theme: Theme = .BlackTranslucent
    var contentPosition:Position = .Top{
        didSet{
            self.layoutIfNeeded()
        }
    }
    var dataType: CropsDataType = .None{
        didSet{
            imageView.image = UIImage(named: dataType.rawValue)
        }
    }
    var arrowType: Arrow = .Normal{
        didSet{
            arrowView.image = UIImage(named: arrowType.rawValue)
        }
    }
    lazy var imageView:UIImageView = {
        let view = UIImageView(image: UIImage(named: self.dataType.rawValue))
        return view
    }()
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        return label;
    }()
    lazy var arrowView:UIImageView = {
        let view = UIImageView()
        return view
    }()
    var title:String = "" {
        didSet{
            titleLabel.font = Font
            titleLabel.text = title
            titleLabel.sizeToFit()
        }
    }
    var anchor:CGPoint{
        get{
            switch contentPosition {
            case .Left:
                return CGPointMake(tmpWidth - 5, tmpHeight / 2)
            case .Right:
                return CGPointMake(5, tmpHeight / 2)
            case .Top:
                return CGPointMake(tmpWidth / 2, tmpHeight - 3)
            case .Bottom:
                return CGPointMake(tmpWidth / 2, 3)
            }
        }
    }
    var tmpHeight:CGFloat = 25
    var tmpWidth:CGFloat = 0.0
    
    convenience init (dataType:CropsDataType,contentPosition:Position){
        self.init()
        self.dataType = dataType
        self.contentPosition = contentPosition
    }
    
    func SetConstraint() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.arrowView)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 4//默认圆角为4
        titleLabel.sizeToFit()
        imageView.sizeToFit()
        arrowView.sizeToFit()
        tmpWidth = imageView.frame.width + titleLabel.frame.width + 21 + (arrowType == .Normal ? 0 : 15)
        var startX:CGFloat = 0.0
        switch contentPosition {
        case .Left:
            startX = 5
        case .Right:
            startX = 10
        case .Top,.Bottom:
            startX = 7.5
        }
        if self.dataType != .None{
            imageView.snp_makeConstraints { (make) in
                make.left.equalTo(self).offset(startX)
                make.centerY.equalTo(self)
            }
        }
        
        titleLabel.snp_makeConstraints { (make) in
            if self.dataType == .None{
                make.centerX.equalTo(self)
            }else{
                make.left.equalTo(imageView.snp_right).offset(3)
            }
            make.centerY.equalTo(self)
        }
        
        if self.arrowType != .Normal{
            arrowView.snp_makeConstraints(closure: { (make) in
                make.left.equalTo(titleLabel.snp_right).offset(3)
                make.centerY.equalTo(self)
            })
        }
        
        switch theme {
        case .BlackTranslucent:
            self.backgroundColor = UIColor(RGB: 0x4A4A4A, alpha: 0.25)
            self.titleLabel.textColor = UIColor.whiteColor()
        }
        self.snp_makeConstraints { (make) in
            make.height.equalTo(tmpHeight)
            make.width.equalTo(tmpWidth)
        }
    }

}
