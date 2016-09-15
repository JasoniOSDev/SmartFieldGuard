//
//  UIApplication+PushNotification.swift
//  智慧田园
//
//  Created by jason on 2016/9/14.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation

extension UIApplication{
    //快速注册一个通知的方法
    class func scheduleNotification(delay:Double,body:String,title:String,lockBody:String? = nil){
        let localNoti = UILocalNotification()
        localNoti.fireDate = NSDate(timeIntervalSinceNow: delay)
        localNoti.alertBody = body
        localNoti.alertTitle = title
        localNoti.alertAction = lockBody
        localNoti.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNoti)
    }
}
