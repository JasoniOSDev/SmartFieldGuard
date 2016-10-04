//
//  ExpertPresentCollectionViewCell.swift
//  智慧田园
//
//  Created by jason on 2016/9/23.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class ExpertPresentCollectionViewCell: UICollectionViewCell,Reusable {

    @IBOutlet weak var ViewBack: UIView!
    @IBOutlet weak var LabelNum: UILabel!
    var money:Int{
        set{
            LabelNum.text = "\(newValue)"
        }
        get{
            return Int(LabelNum.text!)!
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        ViewBack.layer.cornerRadius = 4
        ViewBack.layer.borderColor = UIColor.DangerColor().CGColor
        ViewBack.layer.borderWidth = 2
    }
    

}
