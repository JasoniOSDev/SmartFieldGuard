//
//  MessagePhotoView.swift
//  MessagePhotoViewDemo
//
//  Created by jason on 2016/7/13.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class MessagePhotoView: UIImageView,NSCopying {
    
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let object = MessagePhotoView()
        object.image = self.image
        object.frame = self.frame
        object.tag = self.tag
        return object
    }

}
