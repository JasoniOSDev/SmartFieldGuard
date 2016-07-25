//
//  ExpertClassChooseTableHeadView.swift
//  智慧田园
//
//  Created by Jason on 16/7/24.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class ExpertClassChooseTableHeadView: UIView {

    private var titleLabel = UILabel()
    var clickAction:((Int)->Void)!
    override func didMoveToWindow() {
        super.didMoveToWindow()
        userInteractionEnabled = true
        self.addSubview(titleLabel)
        titleLabel.textColor = UIColor.MidBlackColor()
        titleLabel.font = UIFont(name: LightLanTingHeiFontName, size: 18)!
        titleLabel.textAlignment = .Left
        self.titleLabel.snp_makeConstraints(closure: { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(15)
        })
        let view = UIView()
        self.addSubview(view)
        view.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(0.6)
        }
        view.backgroundColor = UIColor.lightGrayColor()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.clicked)))
    }
    
    func setTitle(title:String){
        titleLabel.text = title
    }

    func clicked(){
        clickAction(self.tag)
    }
}
