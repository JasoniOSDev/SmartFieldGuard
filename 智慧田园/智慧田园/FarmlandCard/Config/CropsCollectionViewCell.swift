//
//  CropsCollectionViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/25.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class CropsCollectionViewCell: UICollectionViewCell,Reusable {

    @IBOutlet weak var imgView: UIImageView!
    var imgName:String!{
        didSet{
            imgView.sd_setImageWithURL(NSURL(string: imgName))
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()

    }

}
