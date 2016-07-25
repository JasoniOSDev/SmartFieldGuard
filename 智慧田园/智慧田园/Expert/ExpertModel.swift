//
//  ExpertModel.swift
//  智慧田园
//
//  Created by jason on 2016/7/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import RealmSwift
class ExpertMessage:Object {
    dynamic var Theme:ExpertTheme?
    dynamic var headPhoto:String = ""
    dynamic var name:String = ""
    dynamic var userID:String = ""
    dynamic var timeInterval = 0.0
    dynamic var replySn:Int = 0 //第几个回复
    var time:String{
        get{
            return NSTimeInterval(timeInterval).ForumDateDescription
        }
    }
    dynamic var content:String = ""

    func updateTheme(unRead:Bool = false){
        try! ModelManager.realm.write {
            self.Theme?.unRead = unRead
            self.Theme!.lastReply = max(self.Theme!.lastReply,timeInterval)
        }
    }
}

class ExpertTheme:Object{
    dynamic var classifyName:String = ""
    dynamic var classifyID:String = ""
    dynamic var ID:String = ""
    dynamic var name:String = ""
    dynamic var userID:String = ""
    dynamic var headPhoto:String = ""
    dynamic var content:String = ""
    dynamic var imagesString = ""
    dynamic var timeInterval = 0.0
    dynamic var lastReply = 0.0
    var time:String{
        get{
            return NSTimeInterval(timeInterval).ForumDateDescription
        }
    }
    
    var images:[String]!{
        get{
            var array = imagesString.componentsSeparatedByString("|")
            array.popLast()
            return array
        }
        set{
            imagesString = images.reduce("", combine: { (origin, now) -> String in
                return origin + now + "|"
            })
        }
    }
    dynamic var unRead:Bool = false//未阅读内容 false表示无，true表示有
    
    override static func ignoredProperties() -> [String] {
        return ["images"]
    }
    
    func setRead(){
        try! ModelManager.realm.write {
            self.unRead = false
        }
    }
    
}

extension NSData{
    class func dataFromExpertMessage(message:ExpertMessage) -> NSData{
        return NSData()
    }
    
    class func dataFromExpertTheme(theme:ExpertTheme) -> NSData{
        return NSData()
    }
}