//
//  ExpertClient.swift
//  智慧田园
//
//  Created by jason on 2016/7/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
enum ExpertClientNotificationEnum:String{
    case FinishWrite = "FinishWrite" //写入完成
    case ConnectionBreak = "ConnecttionBreak" //连接断开
    case Connection = "ReConnection" //重新连接
}
class ExpertClient:NSObject,GCDAsyncSocketDelegate{
    static let shareClient = ExpertClient()
    private var socket:GCDAsyncSocket!
    private var interface:String = "139.129.5.192"
    private var port:UInt16 = 6007
    private var finalReceiveData = NSMutableData()
    let topics = ModelManager.getObjects(ExpertTheme)
    var connected:Bool{
        get{
            return socket.isConnected
        }
    }
    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
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
        dispatch_async(dispatch_get_main_queue()) {[weak self] in
            if let sSelf = self{
                sSelf.finalReceiveData.appendData(data)
                while(sSelf.finalReceiveData.length > 0){
                    var head:Int8 = 0
                    var length = 0
                    sSelf.finalReceiveData.getBytes(&head, range:  NSMakeRange(0, 1))
                    if head == 3{
                        sSelf.finalReceiveData.getBytes(&head, range:  NSMakeRange(1, 1))
                        length = length*256 + Int(head)
                        sSelf.finalReceiveData.getBytes(&head, range:  NSMakeRange(2, 1))
                        length = length*256 + Int(head)
                        sSelf.finalReceiveData.getBytes(&head, range:  NSMakeRange(3, 1))
                        length = length*256 + Int(head)
                        sSelf.finalReceiveData.getBytes(&head, range:  NSMakeRange(4, 1))
                        length = length*256 + Int(head)

                        if length <= sSelf.finalReceiveData.length - 5,let json = try? NSJSONSerialization.JSONObjectWithData(sSelf.finalReceiveData.subdataWithRange(NSMakeRange(5, length)), options: NSJSONReadingOptions.AllowFragments){
                            if let list = json["replyList"] as? NSArray{
                                for x in list{
                                    let object = x as! [String:AnyObject]
                                    let message = ExpertMessage()
                                    if let content = object["content"] as? String{
                                        message.content = content
                                    }
                                    message.headPhoto = TYUserDefaults.UrlPrefix.value + (object["headImage"] as! String)
                                    let topicID = object["postNo"] as! String
                                    message.replySn = object["replySn"] as! Int
                                    message.userID = object["userId"] as! String
                                    message.name = object["username"] as! String
                                    message.timeInterval = (object["replyDate"] as! [String:AnyObject])["time"] as! Double
                                    let topic = (sSelf.topics.filter("self.ID == %@",topicID).first)!
                                    message.Theme = topic
                                    message.updateTheme(true)
                                    ModelManager.add(message)
                                }
                            }
                            if (sSelf.finalReceiveData.length - 5 - length != 5){
                            sSelf.finalReceiveData = NSMutableData(data: sSelf.finalReceiveData.subdataWithRange(NSMakeRange(5+length, sSelf.finalReceiveData.length - 5 - length)))
                            }else{
                                sSelf.finalReceiveData = NSMutableData()
                            }
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
                                sSelf.socket.writeData(finalData, withTimeout: -1, tag: 111)
                            }
                        }else{
                            break
                        }
                    }else{
                        break
                    }
                }
                sSelf.socket.readDataWithTimeout(-1, tag: 0)
            }
        }
        
    }
    
    //已连接
    func socket(sock: GCDAsyncSocket!, didConnectToHost host: String!, port: UInt16) {
        NSNotificationCenter.defaultCenter().postNotificationName(ExpertClientNotificationEnum.Connection.rawValue, object: self, userInfo: nil)
        let json = ["mType":"NewConnect","sendUser":TYUserDefaults.userID.value!]
        var headArray:[UInt8] = [2]
        let content = try! NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions())
        var head = NSData(bytes: headArray, length: 1)
        var lengthArray:[UInt8] = []
        var contentLength = content.length
        for _ in 0...3{
            lengthArray.append(UInt8(contentLength%256))
            contentLength/=256
        }
        lengthArray = lengthArray.reverse()
        
        var length = NSData(bytes: lengthArray, length: 4)
        var finalData = NSMutableData()
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