//
//  AnalyzeCollectionViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/30.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class AnalyzeCollectionViewCell: UICollectionViewCell {

    weak var view: UIView?{
        didSet{
            self.contentView.addSubview(view!)
            view!.frame = CGRectMake(0, 0, frame.width, frame.height)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
