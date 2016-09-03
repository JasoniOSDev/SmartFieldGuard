//
//  TYCache.swift
//  智慧田园
//
//  Created by jason on 2016/9/2.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import YYCache
import SDWebImage
class TYCache: YYCache {
    static let CropsImageCache = TYCache(name:"CropsImages") //用来存储作物图片
    
    class func CropsImageGetByCropsID(id:String) -> UIImage?{
        let data = CropsImageCache!.objectForKey(id) as? NSData
        if data == nil {
            return nil
        }
        return UIImage.sd_imageWithData(data!)
    }
    
//    class func CropsImageSetByCropsID(id:String,image:UIImage)
}

extension SDWebImageManager{
    
    //用于获取存在SDWebImage缓存中的图片
}