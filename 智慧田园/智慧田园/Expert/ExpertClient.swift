//
//  ExpertClient.swift
//  智慧田园
//
//  Created by jason on 2016/7/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import AVFoundation
enum ExpertClientNotificationEnum:String{
    case FinishWrite = "FinishWrite" //写入完成
    case ConnectionBreak = "ConnecttionBreak" //连接断开
    case Connection = "ReConnection" //重新连接
}
class ExpertClient:NSObject,GCDAsyncSocketDelegate{
    static let shareClient = ExpertClient()
    private var socket:GCDAsyncSocket!
    private var interface:String = "139.129.5.192"
//    private var interface:String = "192.168.31.112"
    private var port:UInt16 = 6007
    private var finalReceiveData = NSMutableData()
    let topics = ModelManager.getObjects(ExpertTheme)
    var backgroundTaskID:UIBackgroundTaskIdentifier!
    var connected:Bool{
        get{
            return socket.isConnected
        }
    }
    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
        backgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ [weak self] in
            self?.backgroundTaskID = UIBackgroundTaskInvalid
        })
    }
    
    func connect(){
        if TYUserDefaults.userID.value != nil && socket.isDisconnected{
            try! socket.connectToHost(interface, onPort: port)
        }
    }
    
    func disConnect(){
        socket.disconnect()
    }
    
    //代理
    //写入消息成功，发送通知
    func socket(sock: GCDAsyncSocket!, didWriteDataWithTag tag: Int) {
        NSNotificationCenter.defaultCenter().postNotificationName(ExpertClientNotificationEnum.FinishWrite.rawValue, object: self, userInfo: ["tag":tag])//tag标示是哪个完成了发送，虽然可能用不到
    }
    
    //接受到的只有message，theme本地创建的时候即保存
    func socket(sock: GCDAsyncSocket!, didReadData data: NSData!, withTag tag: Int) {
        dispatch_async(dispatch_get_main_queue()) {
            self.finalReceiveData.appendData(data)
            while(self.finalReceiveData.length > 0 && self.finalReceiveData.length > 4 ){
                var head:Int8 = 0
                self.finalReceiveData.getBytes(&head, range:  NSMakeRange(0, 1))
                if head == 3{
                    let length:Int = Int(self.finalReceiveData.subdataWithRange(NSMakeRange(1, 4)).intValue())
                    if length <= self.finalReceiveData.length - 5,let json = try? NSJSONSerialization.JSONObjectWithData(self.finalReceiveData.subdataWithRange(NSMakeRange(5, length)), options: NSJSONReadingOptions.AllowFragments){
                        if let type = json["type"] as? String{
                            switch type{
                                case "NewExpertAsk":
                                    if let key = json["key"] as? Int{
                                        let json = ["mType":"GetInform","sendUser":TYUserDefaults.userID.value!,"informKey":key]
                                        let headArray:[UInt8] = [2]
                                        let content = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
                                        let head = NSData(bytes: headArray, length: 1)
                                        var lengthArray:[UInt8] = []
                                        var contentLength = content.length
                                        for _ in 0...3{
                                            lengthArray.append(UInt8(contentLength%256))
                                            contentLength/=256
                                        }
                                        lengthArray = lengthArray.reverse()
                                        let length = NSData(bytes: lengthArray, length: 4)
                                        let finalData = NSMutableData()
                                        finalData.appendData(head)
                                        finalData.appendData(length)
                                        finalData.appendData(content)
                                        self.socket.writeData(finalData, withTimeout: -1, tag: 111)
                                }
                                    if let list = json["posts"] as? NSArray{
                                        for x in list {
                                            if let object = x as? [String:AnyObject]{
                                                let topic = ExpertTheme()
                                                if let content = object["content"] as? String{
                                                    topic.content = content
                                                }else{
                                                    topic.content = ""
                                                }
                                                topic.classifyID = object["parentArea"] as! String
                                                topic.timeInterval = object["createDate"] as! Double
                                                topic.ID = object["postNo"] as! String
                                                topic.headPhoto = TYUserDefaults.UrlPrefix.value + (object["headImage"] as! String)
                                                topic.lastReply = object["lastReplyDate"] as! Double
                                                topic.name = object["username"] as! String
                                                topic.userID = object["userId"] as! String
                                                topic.status = 2
                                                if let images = object["images"] as? [String]{
                                                    topic.images = images.map(){TYUserDefaults.UrlPrefix.value + $0}
                                                }
                                                dispatch_async(dispatch_get_main_queue(), {
                                                    ModelManager.add(topic)
                                                })
                                            }
                                        }
                                }
                                case "NewFieldData":
                                    if let fieldData = json["fieldData"] as? [String:AnyObject]{
                                        Farmland.setEnvironMent(fieldData)
                                }
                            default:
                                if let key = json["key"] as? Int{
                                    let json = ["mType":"GetInform","sendUser":TYUserDefaults.userID.value!,"informKey":key]
                                    let headArray:[UInt8] = [2]
                                    let content = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
                                    let head = NSData(bytes: headArray, length: 1)
                                    var lengthArray:[UInt8] = []
                                    var contentLength = content.length
                                    for _ in 0...3{
                                        lengthArray.append(UInt8(contentLength%256))
                                        contentLength/=256
                                    }
                                    lengthArray = lengthArray.reverse()
                                    let length = NSData(bytes: lengthArray, length: 4)
                                    let finalData = NSMutableData()
                                    finalData.appendData(head)
                                    finalData.appendData(length)
                                    finalData.appendData(content)
                                    self.socket.writeData(finalData, withTimeout: -1, tag: 111)
                                }
                                if let list = json["replyList"] as? NSArray{
                                    for x in list {
                                        if let object = x as? [String:AnyObject]{
                                            let message = ExpertMessage()
                                            if let content = object["content"] as? String{
                                                message.content = content
                                            }
                                            message.headPhoto = TYUserDefaults.UrlPrefix.value + (object["headImage"] as! String)
                                            let topicID = object["postNo"] as! String
                                            message.replySn = object["replySn"] as! Int
                                            message.userID = object["userId"] as! String
                                            message.name = object["username"] as! String
                                            message.timeInterval = object["replyDate"] as! Double
                                            if let topic = (self.topics.filter("self.ID == %@",topicID).first){
                                                message.Theme = topic
                                                message.updateTheme(true)
                                                ModelManager.add(message)
                                                let body = message.content
                                                var title = "您参与的咨询有了新的回复"
                                                if topic.userID == TYUserDefaults.userID.value{
                                                    title = "专家\"\(message.name)\"的回复了您的咨询"
                                                }
                                                self.scheduleNotification(title, body: body)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (self.finalReceiveData.length - length != 5){
                        self.finalReceiveData = NSMutableData(data: self.finalReceiveData.subdataWithRange(NSMakeRange(5+length, self.finalReceiveData.length - 5 - length)))
                        }else{
                            self.finalReceiveData = NSMutableData()
                        }
                    }else{
                        break
                    }
                }else{
                    break
                }
            }
            self.socket.readDataWithTimeout(-1, tag: 0)
        }
        
    }
    
    private func scheduleNotification(title:String,body:String){
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//        if UIApplication.sharedApplication().applicationState != .Active {
//            UIApplication.scheduleNotification(0, body: body, title: title)
//        }
    }
    
    //已连接
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        NSNotificationCenter.defaultCenter().postNotificationName(ExpertClientNotificationEnum.Connection.rawValue, object: self, userInfo: nil)
        let json = ["mType":"NewConnect","sendUser":TYUserDefaults.userID.value!]
        let headArray:[UInt8] = [2]
        let content = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
        let head = NSData(bytes: headArray, length: 1)
        var lengthArray:[UInt8] = []
        var contentLength = content.length
        for _ in 0...3{
            lengthArray.append(UInt8(contentLength%256))
            contentLength/=256
        }
        lengthArray = lengthArray.reverse()
        
        let length = NSData(bytes: lengthArray, length: 4)
        let finalData = NSMutableData()
        finalData.appendData(head)
        finalData.appendData(length)
        finalData.appendData(content)
        socket.writeData(finalData, withTimeout: -1, tag: 111)
        socket.readDataWithTimeout(-1, tag: 0)
    }
    //断开连接
    func socketDidDisconnect(sock: GCDAsyncSocket!, withError err: NSError!) {
        NSNotificationCenter.defaultCenter().postNotificationName(ExpertClientNotificationEnum.ConnectionBreak.rawValue, object: self, userInfo: nil)
        connect()
        
    }
    
}
