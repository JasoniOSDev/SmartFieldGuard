//
//  InstroduceTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/23.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class InstroduceTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var LabelContent: UILabel!
    @IBOutlet weak var newContentView: UIView!
    var content:String!{
        didSet{
            LabelContent.text = content
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
