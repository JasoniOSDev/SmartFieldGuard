//
//  ExpertClassChooseTableViewCell.swift
//  智慧田园
//
//  Created by Jason on 16/7/24.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class ExpertClassChooseTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var collectionView: UICollectionView!
    var index:Int!{
        didSet{
            collectionView.tag = index
            
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.registerClass(ExpertClassChooseCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = UIColor.clearColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
