//
//  NetWorkURL.swift
//  智慧田园
//
//  Created by jason on 16/5/26.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import Alamofire
let mainURL:String = "http://139.129.5.192/SZTY/"
public enum ContentType:String{
    
    var url:String{
        get{
            return mainURL + self.rawValue + TYUserDefaults.cookie.value
        }
    }
    case Logout = "user/logout"
    case Login = "user/login"
    case Register = "user/register"
    case PulishNewForum = "post/publish"
    case Forum = "post/list"
    case updateSession = "user/judgeLogin"
    case Reply = "post/replyList"
    case PushAReply = "post/reply"
    case ReplySupport = "post/agree"
    case ForumChooseAgreedAnswer = "post/solve"
    case CropsClassName = "crop/types"
    case CropsList = "crop/list"
    case Crop = "task/download"
    case updateFarmland = "field/list"
    case fieldSet = "field/set"
    case fieldData = "field/data"
    case fieldAnalyze = "field/analyze"
}
//Set-Cookie
public func TYRequest(Type:ContentType,parameters:[String : AnyObject]?) -> Request{
    return Alamofire.request(.POST, Type.url, parameters: parameters, encoding: .URL)
}

extension Request{
    public func TYResponse<T: ResponseSerializerType>(
        queue queue: dispatch_queue_t? = nil,
              responseSerializer: T,
              completionHandler:  Response<T.SerializedObject, T.ErrorObject> -> Void)
        -> Self{
        delegate.queue.addOperationWithBlock {
            let result = responseSerializer.serializeResponse(
                self.request,
                self.response,
                self.delegate.data,
                self.delegate.error
            )
            
            let requestCompletedTime = self.endTime ?? CFAbsoluteTimeGetCurrent()
            let initialResponseTime = self.delegate.initialResponseTime ?? requestCompletedTime
            
            let timeline = Timeline(
                requestStartTime: self.startTime ?? CFAbsoluteTimeGetCurrent(),
                initialResponseTime: initialResponseTime,
                requestCompletedTime: requestCompletedTime,
                serializationCompletedTime: CFAbsoluteTimeGetCurrent()
            )
            
            let response = Response<T.SerializedObject, T.ErrorObject>(
                request: self.request,
                response: self.response,
                data: self.delegate.data,
                result: result,
                timeline: timeline
            )
            if let Response = response.response{
                if let sessions = (Response.URL?.absoluteString)?.lowercaseString.componentsSeparatedByString(";jsessionid="){
                    if sessions.count >= 2{
                        let realSession = sessions[1].componentsSeparatedByString("?")[0]
                        TYUserDefaults.cookie.value = ";jsessionid=" + realSession
                        print(realSession)
                        print(response)
                    }
                }
            }
            dispatch_async(queue ?? dispatch_get_main_queue()) { completionHandler(response) }
        } 
        
        return self
    }
    
    public func TYSResponse<T: ResponseSerializerType>(
        queue queue: dispatch_queue_t? = nil,
              responseSerializer: T,
              completionHandler:  Response<T.SerializedObject, T.ErrorObject> -> Void)
        -> Self{
            dispatch_sync(Manager.sharedInstance.queue) {
                self.delegate.queue.addOperationWithBlock {
                    let result = responseSerializer.serializeResponse(
                        self.request,
                        self.response,
                        self.delegate.data,
                        self.delegate.error
                    )
                    
                    let requestCompletedTime = self.endTime ?? CFAbsoluteTimeGetCurrent()
                    let initialResponseTime = self.delegate.initialResponseTime ?? requestCompletedTime
                    
                    let timeline = Timeline(
                        requestStartTime: self.startTime ?? CFAbsoluteTimeGetCurrent(),
                        initialResponseTime: initialResponseTime,
                        requestCompletedTime: requestCompletedTime,
                        serializationCompletedTime: CFAbsoluteTimeGetCurrent()
                    )
                    
                    let response = Response<T.SerializedObject, T.ErrorObject>(
                        request: self.request,
                        response: self.response,
                        data: self.delegate.data,
                        result: result,
                        timeline: timeline
                    )
                    if let Response = response.response{
                        if let sessions = (Response.URL?.absoluteString)?.lowercaseString.componentsSeparatedByString(";jsessionid="){
                            if sessions.count >= 2{
                                let realSession = sessions[1].componentsSeparatedByString("?")[0]
                                TYUserDefaults.cookie.value = ";jsessionid=" + realSession
                            }
                        }
                    }
                    dispatch_async(queue ?? dispatch_get_main_queue()) { completionHandler(response) }
                }
            }
            
            return self
    }

    
    public func TYresponseJSON(
        options options: NSJSONReadingOptions = .AllowFragments,
                completionHandler: Response<AnyObject, NSError> -> Void)
        -> Self{
        return TYResponse(
            responseSerializer: Request.JSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
    
    func TYResponseJSON(options options: NSJSONReadingOptions = .AllowFragments,Block:(JSON:[String:AnyObject])->Void) -> Self{
        return TYResponse(responseSerializer: Request.JSONResponseSerializer(options: options),completionHandler: { (response) in
            print("---------response-------------")
            print(response)
            print("---------response-------------")
            if response.result.isSuccess {
                if let json = response.result.value as? [String:AnyObject]{
                    Block(JSON:json)
                }
            }else{
                Block(JSON:["msg":"failure"])
            }
        })
    }

}
