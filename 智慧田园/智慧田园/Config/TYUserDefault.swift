//
//  TYUserDefault.swift
//  智慧田园
//
//  Created by jason on 16/5/26.
//  Copyright © 2016年 jason. All rights reserved.
//



import Foundation
let TelKey = "tel"
let UserIDKey = "userId"
let UsernameKey = "username"
let PassWordKey = "PassWordKey"
let CookieKey = "Set-Cookie"
let LastConnectTimeKey = "LastConnectTime"
let SessionInvalidTimeKey = "SessionInvalidTime"
let NeedUpdateSession = "NeedUpdateSession"
let HeadImageKey = "headImage"
let RoleKey = "role"
let UrlPrefixKey = "UrlPrefix"
let PushNewForumKey = "PushNewForum"
let RoleNormalMemeber = "NormalMember"
let RoleExpert = "Expert"
let NeedShowForumTipKey = "NeedShowForumTip"

struct Listener<T>:Hashable{
    let name:String
    typealias Action = T->Void
    let action:Action
    var hashValue: Int{
        return name.hashValue
    }
}
func ==<T>(left:Listener<T>,right:Listener<T>)->Bool{
    return left.name == right.name
}
class Listenable<T>{
    var value:T{
        didSet{
            setterAction(value)
            for x in listenerSet{
                x.action(value)
            }
        }
    }
    typealias SetterAction = T->Void
    var setterAction:SetterAction
    var listenerSet = Set<Listener<T>>()
    
    func bindListener(name:String,action:Listener<T>.Action){
        let listener = Listener(name: name, action: action)
        listenerSet.insert(listener)
    }
    
    func bindAndFireListener(name:String,action:Listener<T>.Action){
        bindListener(name, action: action)
        action(value)
    }
    
    func removeListenerWithName(name:String){
        for Listener in listenerSet{
            if Listener.name == name{
                listenerSet.remove(Listener)
                break
            }
        }
    }
    
    func removeAllListeners(){
        listenerSet.removeAll(keepCapacity: false)
    }
    
    init(_ v:T,setterAction action:SetterAction){
        value = v
        setterAction = action
    }
}

public class TYUserDefaults{
    static var defaults = NSUserDefaults(suiteName: "com.jason.TY")!
    
    static var needShowForumTip:Listenable<Bool> = {
        let need = defaults.boolForKey(NeedShowForumTipKey)
        return Listenable<Bool>(need){ need in
            defaults.setObject(need, forKey: NeedShowForumTipKey)
        }
    }()
    
    static var userID:Listenable<String?> = {
        let userID = defaults.stringForKey(UserIDKey)
        return Listenable<String?>(userID){ userID in
            defaults.setObject(userID, forKey: UserIDKey)
        }
    }()
    
    static var isLogined: Bool {
        let lastTime = TYUserDefaults.lastConnectTime.value
        let dis = TYUserDefaults.sessionInvalidTime.value + NSDate(timeIntervalSince1970: lastTime).timeIntervalSinceNow
        
        if  dis < 300 &&  dis > 0 {
            //当距离过期期限小于10分钟的时候，向服务器发个请求
            TYUserDefaults.needUpdateSession.value = true
        }
        if dis <= 0 {
            return false
        }else{
            return true
        }
    }
    
    static var needUpdateSession:Listenable<Bool> = {
        let needUpdateSession = defaults.boolForKey(NeedUpdateSession) ?? true
        return Listenable<Bool>(needUpdateSession){ needUpdateSession in
            defaults.setObject(needUpdateSession, forKey: NeedUpdateSession)
        }
    }()
    
    static var tel:Listenable<String?> = {
        let tel = defaults.stringForKey(TelKey)
        return Listenable<String?>(tel){ tel in
            defaults.setObject(tel, forKey: TelKey)
        }
    }()
    
    static var username:Listenable<String?> = {
        let username = defaults.stringForKey(UsernameKey)
        return Listenable<String?>(username){username in
            defaults.setObject(username, forKey: UsernameKey)
        }
    }()
    
    static var sessionInvalidTime:Listenable<NSTimeInterval> = {
        var time = defaults.doubleForKey(SessionInvalidTimeKey)
        if time == 0 {
            time = 86400
        }
        return Listenable<NSTimeInterval>(time){ time in
            defaults.setDouble(time, forKey: SessionInvalidTimeKey)
        }
    }()
    
    static var lastConnectTime:Listenable<NSTimeInterval> = {
        var time = defaults.doubleForKey(LastConnectTimeKey)
        return Listenable<NSTimeInterval>(time){ time in
            defaults.setDouble(time, forKey: LastConnectTimeKey)
        }
    }()
    
    static let cookieDefault = ";JSESSIONID=FC5E8F590ACF0AFDBF095F1222E83B4C"
    static var cookie:Listenable<String> = {
        let cookie = defaults.stringForKey(CookieKey) ?? ";JSESSIONID=FC5E8F590ACF0AFDBF095F1222E83B4C"
        
        return Listenable<String>(cookie){cookie in
            defaults.setObject(cookie, forKey: CookieKey)
            TYUserDefaults.lastConnectTime.value = NSDate().timeIntervalSince1970
        }
    }()
    
    static var passWord:Listenable<String?> = {
        let passWord = defaults.stringForKey(PassWordKey)
        
        return Listenable<String?>(passWord){passWord in
            defaults.setObject(passWord, forKey: PassWordKey)
        }
    }()
    
    static var headImage:Listenable<String> = {
        let headImage = defaults.stringForKey(HeadImageKey) ?? ""
        
        return Listenable<String>(headImage){ headImage in
            defaults.setObject(headImage, forKey: HeadImageKey)
        }
    }()
    
    static var role:Listenable<String> = {
        let role = defaults.stringForKey(RoleKey) ?? "NormalMember"
        
        return Listenable<String>(role){ role in
            defaults.setObject(role, forKey: RoleKey)
        }
    }()
    static var UrlPrefix:Listenable<String> = {
        let UPrefix = defaults.stringForKey(UrlPrefixKey) ?? ""
        
        return Listenable<String>(UPrefix){ UPrefix in
            defaults.setObject(UPrefix, forKey: UrlPrefixKey)
        }
    }()
    
    static var NewForum:Listenable<Bool> = {
        let NewForum = defaults.boolForKey(PushNewForumKey)
        return Listenable<Bool>(NewForum){
            NewForum in
            defaults.setObject(NewForum, forKey: PushNewForumKey)
        }
    }()
    
}
