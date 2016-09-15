//
//  AppDelegate.swift
//  智慧田园
//
//  Created by jason on 16/5/19.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
         UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        WisdomTask.updateTask()
        ExpertClient.shareClient.connect()
        let setting = UIUserNotificationSettings(forTypes: [.Alert,.Badge,.Sound], categories: nil)
        application.registerUserNotificationSettings(setting)
        return true
    }

}

