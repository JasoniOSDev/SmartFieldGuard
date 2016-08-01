//
//  ExpertModel.swift
//  智慧田园
//
//  Created by jason on 2016/7/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import RealmSwift
//回复Model
class ExpertMessage:Object {
    //对应的话题，用于收到回复后修改话题的相关属性
    dynamic var Theme:ExpertTheme?
    //回复人的头像、昵称、ID、时间、回复的顺序
    dynamic var headPhoto:String = ""
    dynamic var name:String = ""
    dynamic var userID:String = ""
    dynamic var timeInterval = 0.0
    dynamic var replySn:Int = 0 //第几个回复
    var time:String{
        get{
            return NSTimeInterval(timeInterval).ReplyDateDescription
        }
    }
    dynamic var content:String = ""
    //当收到一条新的回复时，需要更新对应话题的相关值
    func updateTheme(unRead:Bool = false){
        try! ModelManager.realm.write {
            if unRead == true{
                self.Theme?.unRead = unRead
            }
            self.Theme!.lastReply = max(self.Theme!.lastReply,timeInterval)
        }
    }
}

//话题Model
class ExpertTheme:Object{
    //话题所属的类别名称、类别ID、话题的ID
    dynamic var classifyName:String = ""
    dynamic var classifyID:String = ""
    dynamic var ID:String = ""
    //发出人的昵称、ID、头像
    dynamic var name:String = ""
    dynamic var userID:String = ""
    dynamic var headPhoto:String = ""
    //话题的内容、图片链接、话题的发出时间、最新回复时间
    dynamic var content:String = ""
    dynamic var imagesString = ""
    dynamic var timeInterval = 0.0
    dynamic var lastReply = 0.0
    func setRead(){
        try! ModelManager.realm.write {
            self.unRead = false
        }
    }

    var time:String{
        get{
            return NSTimeInterval(timeInterval).ReplyDateDescription
        }
    }
    
    var images:[String]!{
        get{
            var array = imagesString.componentsSeparatedByString("|")
            array.popLast()
            return array
        }
        set{
            imagesString = newValue.reduce("", combine: { (origin, now) -> String in
                return origin + now + "|"
            })
        }
    }
    dynamic var unRead:Bool = false//未阅读内容 false表示无，true表示有
    
    override static func ignoredProperties() -> [String] {
        return ["images"]
    }
    
    
}