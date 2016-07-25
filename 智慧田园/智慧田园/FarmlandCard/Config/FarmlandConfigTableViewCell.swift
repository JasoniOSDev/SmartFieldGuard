//
//  FarmlandConfigTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/21.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class FarmlandConfigTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var LabelTitle: UILabel!
    @IBOutlet weak var TextFieldDetail: UITextField!
    
    var title:String!{
        didSet{
            LabelTitle.text = title
        }
    }
    var detail:String!{
        didSet{
            TextFieldDetail.text = detail
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
