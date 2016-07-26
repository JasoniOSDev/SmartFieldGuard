//
//  ForumModel.swift
//  智慧田园
//
//  Created by jason on 16/5/27.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation

struct Forum {
    var postNo:String
    var userId:String
    var username:String
    var headImage:String
    var type:String
    var parentArea:String
    var content:String
    var images:[String]
    var replyNum:Int
    var status:String
    var createDate:NSTimeInterval
    var UrlPrefix = ""
    init(dict:[String:AnyObject]){
        UrlPrefix = dict["UrlPrefix"] as! String
        postNo = dict["postNo"] as! String
        userId = dict["userId"] as! String
        username = dict["username"] as! String
        headImage =  UrlPrefix + (dict["headImage"] as! String)
        type = (dict["type"] as? String) ?? "type"
        parentArea = dict["parentArea"] as? String ?? "parentArea"
        content = dict["content"] as! String
        replyNum = dict["replyNum"] as! Int
        status = dict["status"] as! String
        createDate = dict["createDate"] as! NSTimeInterval
        images = [String]()
        if let imgsStr = dict["images"] as? String {
            let imgs = imgsStr.componentsSeparatedByString("|")
            imgs.forEach({ (x) in
                images.append(UrlPrefix + x)
            })
        }
        
    }
}

class Replay:NSObject{
    var postNo:String!
    var replySn:Int!
    var userId:String!
    var username:String!
    var headImage:String!
    var content:String!
    var agreeNum:Int!
    var replyDate:NSTimeInterval!
    var IfSupport:Bool!
    init(dict:[String:AnyObject]){
        super.init()
        postNo = dict["postNo"] as! String
        replySn = dict["replySn"] as! Int
        userId = dict["userId"] as! String
        username = dict["username"] as! String
        headImage = TYUserDefaults.UrlPrefix.value + ( dict["headImage"] as! String)
        content = dict["content"] as! String
        agreeNum = dict["agreeNum"] as! Int
        replyDate = dict["replyDate"] as! NSTimeInterval
        IfSupport = false
        if let agreeUserstr = dict["agreeUsers"] as? String {
            let agreeUsers = agreeUserstr.componentsSeparatedByString("|")
            agreeUsers.forEach({ (str) in
                if str == TYUserDefaults.userID.value {
                    IfSupport = true
                    return
                }
            })
        }
    }
}

//rivate String postNo;所属帖子编号
//
//private Integer replySn;回帖编号
//
//private String userId;回帖者ID
//
//private String username;回帖者用户名
//
//private String headImage;回帖者头像
//
//private String content;回帖内容
//
//private String images;回帖图片
//
//private Integer agreeNum;被点赞数
//
//private Date replyDate;回帖时间
//
//private String agreeUsers;点赞用户的编号



extension NSTimeInterval{
    var ForumDateDescription:String{
        get{
            let date = NSDate(timeIntervalSince1970: self/1000)
            let dis = -date.timeIntervalSinceNow
            if dis < 3600 {
                if dis / 60  <= 2 {
                    return "刚刚"
                }
                return String(format: "%.f分钟前", dis/60)
            }else{
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                return dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: self/1000))
            }
        }
    }
    var ReplyDateDescription:String{
        get{
            let date = NSDate(timeIntervalSince1970: self/1000)
             let dateFormatter = NSDateFormatter()
            let dis = -date.timeIntervalSinceNow
            if dis < 86400 {
                return self.ForumDateDescription
            }else{
                dateFormatter.dateFormat = "MM-dd"
            }
            return dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: self/1000))
        }
    }
}