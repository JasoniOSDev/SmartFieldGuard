//
//  CropClassTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/25.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class CropClassTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var imgView: UIImageView!
    var imgURL:String!{
        didSet{
            imgView.sd_setImageWithURL(NSURL(string: imgURL))
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    
}
