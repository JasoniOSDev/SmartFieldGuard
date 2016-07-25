//
//  InstroduceHeaderView.swift
//  智慧田园
//
//  Created by jason on 16/5/23.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class InstroduceHeaderView: UIView {
    var tagView:UIView!
    var titleLabel:UILabel!
    var myTag:tagType!{
        didSet{
            tagView.backgroundColor = tagTypeDict[myTag.rawValue]
        }
    }
    var title:String!{
        didSet{
            titleLabel.text = title
        }
    }
    enum tagType:String{
        case Yellow = "Yellow"
        case Red = "Red"
        case Blue = "Blue"
        case Green = "Green"
    }
    private var tagTypeDict = ["Yellow":UIColor.WarnColor(),"Red":UIColor.DangerColor(),"Blue":UIColor.MainColor(),"Green":UIColor.SafeColor()]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        tagView = UIView()
        tagView.layer.cornerRadius = 2
        self.addSubview(tagView)
        tagView.snp_makeConstraints { (make) in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(10)
        }
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: NormalLanTingHeiFontName, size: 16)!
        titleLabel.textColor = UIColor.MainColor()
        self.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(tagView.snp_right).offset(10)
            make.centerY.equalTo(self)
        }
    }
    
    convenience init(type:tagType,title:String){
        self.init(frame: CGRectZero)
        myTag = type
        self.title = title
        titleLabel.text = title
        tagView.backgroundColor = tagTypeDict[myTag.rawValue]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


