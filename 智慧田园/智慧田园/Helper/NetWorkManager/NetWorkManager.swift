//
//  NetWorkManager.swift
//  智慧田园
//
//  Created by jason on 16/5/27.
//  Copyright © 2016年 jason. All rights reserved.
//

//import Foundation
////用来监测一些值的改变，从而触发对应的注册闭包和操作
import Alamofire
public class NetWorkManager:NSObject{
    static let shareManager = NetWorkManager()
    
    class func login(parameters:[String:AnyObject],action:(json:[String:AnyObject])->Void){
        TYRequest(.Login, parameters: parameters).TYResponseJSON { (json) in
            let message = json["message"] as! String
            if(message == "success"){
                TYUserDefaults.UrlPrefix.value = json["staticUrlPrefix"] as! String
                let userInfo = json["userInfo"] as! [String:AnyObject]
                TYUserDefaults.headImage.value = TYUserDefaults.UrlPrefix.value + (userInfo[HeadImageKey] as! String)
                TYUserDefaults.role.value = userInfo[RoleKey] as! String
                TYUserDefaults.tel.value = userInfo[TelKey] as? String
                TYUserDefaults.username.value = userInfo[UsernameKey] as? String
                TYUserDefaults.passWord.value = parameters["password"] as? String
                TYUserDefaults.lastConnectTime.value = NSDate().timeIntervalSince1970
                TYUserDefaults.userID.value = userInfo[UserIDKey] as? String
                ExpertClient.shareClient.connect()
            }else{
                TYUserDefaults.cookie.value = TYUserDefaults.cookieDefault
                TYUserDefaults.lastConnectTime.value = 0
                TYUserDefaults.userID.value = nil
            }
            action(json: json)
        }
    }
    
    
    class func uploadUserPhoto(realImage:UIImage,lowQualityImage:UIImage,block:((Bool)->Void)){
        NetWorkManager.updateSession({
            Alamofire.upload(.POST, ContentType.userUplod.url, multipartFormData: { (data) in
                if let realData =
                    UIImagePNGRepresentation(realImage),let lowQuealityData = UIImagePNGRepresentation(lowQualityImage){
                    data.appendBodyPart(data: realData, name: "file", fileName: "images.png", mimeType: "image/png")
                    data.appendBodyPart(data: lowQuealityData, name: "file", fileName: "images.png", mimeType: "image/png")
                }else{
                    block(false)
                    return
                }
                let fileTypeData = "UserHead".dataUsingEncoding(NSUTF8StringEncoding)
                data.appendBodyPart(data: fileTypeData!, name: "fileType")
                }, encodingCompletion: {  (result) in
                    switch result{
                    case .Success(let request,  _,  _):
                        request.TYResponseJSON(Block: { (JSON) in
                            if let msg = JSON["message"] as? String where msg == "success"{
                                block(true)
                            }else{
                                block(false)
                            }
                        })
                    case .Failure(_):
                        block(false)
                        break
                    }
            })
        })
    }
    //message:unlogin
    class func updateSession(action:(()->Void)? = nil) {
        Alamofire.request(.POST, ContentType.updateSession.url).TYresponseJSON { (response) in
            if response.result.isSuccess{
                if  let json = response.result.value as? [String:AnyObject]{
                    if let logined = json["message"] as? String where logined == "unlogin" {
                        if let phone = TYUserDefaults.tel.value,let password = TYUserDefaults.passWord.value {
                            NetWorkManager.login(["username":phone,"password":password], action: { (_) in
                                if let action = action{
                                    action()
                                }
                            })
                        }
                    }else{
                        if let action = action{
                            action()
                        }
                    }
                }
            }
        }
    }
    
    class func getCrops(no:String,action:(Crops)->Void){
        updateSession{
            TYRequest(ContentType.Crop, parameters: ["cropNo":no]).TYresponseJSON(completionHandler: { (response) in
                print(response)
                if response.result.isSuccess {
                    if let json = response.result.value as? [String:AnyObject]{
                        if let message = json["message"] as? String where message == "success"{
                            if let cropPlan = json["cropPlan"] as? [String:AnyObject]{
                                let crop = Crops()
                                //创建农作物,并关联到农田
                                if let cropInfo = cropPlan["cropInfo"] as? [String:AnyObject]{
                                    crop.id = cropInfo["cropNo"] as! String
                                    crop.name = cropInfo["cropName"] as! String
                                    let str = (cropInfo["imageUrl"] as! String).componentsSeparatedByString("|")
                                    crop.url = TYUserDefaults.UrlPrefix.value + str[2]
                                    crop.urlHome = TYUserDefaults.UrlPrefix.value + str[0]
                                    crop.urlDetail = TYUserDefaults.UrlPrefix.value + str[1]
                                    if let cropVariableList = cropInfo["cropVariableList"] as? [String:AnyObject]{
                                        let options = NSJSONWritingOptions()
                                        let data = try! NSJSONSerialization.dataWithJSONObject(cropVariableList, options: options)
                                        crop.properties = data
                                    }
                                    crop.growDays = cropInfo["growDays"] as! Int
                                    //设置简介----
                                    if let intro = cropInfo["intro"] as? String{
                                        crop.quickLook = intro
                                    }
                                    if let light = cropInfo["light"] as? String{
                                        crop.sunQuickLook = light
                                    }
                                    if let soil = cropInfo["soil"] as? String{
                                        crop.soilQuickLook = soil
                                    }
                                    if let temperature = cropInfo["temperature"] as? String{
                                        crop.temperatureQuickLook = temperature
                                    }
                                    if let water = cropInfo["water"] as? String{
                                        crop.waterQuickLook = water
                                    }
                                    //读取任务
                                    if let taskList = cropPlan["cropTaskList"] as? NSArray{
                                        taskList.forEach({ (x) in
                                            if let object = x as? [String:AnyObject]{
                                                let task = Task()
                                                task.crops = crop
                                                if let taskNo = object["taskNo"] as? String{
                                                    task.id = taskNo
                                                }
                                                if let name = object["taskName"] as? String{
                                                    task.name = name
                                                }
                                                if let lastTaskNo = object["lastTask"] as? String{
                                                    task.lastTaskid = lastTaskNo
                                                }
                                                if  let periodNo = object["periodNo"] as? String{
                                                    task.periodNO = periodNo
                                                }
                                                if let taskFormula = object["taskFormula"] as? String{
                                                    task.operation = taskFormula
                                                }
                                                if let attention = object["attention"] as? String{
                                                    task.note = attention
                                                }
                                                if let taskType = object["taskType"] as? String{
                                                    task.taskType = taskType
                                                }
                                                if let startTime = object["start"] as? Int{
                                                    task.startTime = startTime
                                                }
                                                if let useDays = object["useDays"] as? Int{
                                                    task.needTime = useDays
                                                }
                                                if let triggerList = object["taskTriggerList"] as? NSArray{
                                                    triggerList.forEach({ (x) in
                                                        if let yy = x as? [String:AnyObject]{
                                                            let condition = TaskFireCondition()
                                                            if let triggerFormula = yy["triggerFormula"] as? String{
                                                                condition.property = triggerFormula
                                                            }
                                                            if let triggerThan = yy["triggerThan"] as? String{
                                                                condition.method = triggerThan
                                                            }
                                                            if let triggerValue = yy["triggerValue"] as? String{
                                                                condition.value = triggerValue
                                                            }
                                                            task.fireCondition.append(condition)
                                                        }
                                                    })
                                                }
                                                crop.tasks.append(task)
                                            }
                                        })
                                    }
                                }
                                action(crop)
                            }
                        }
                    }
                }
            })
        }
    }
    class func getPastTaskList(fieldNo:String,block:()->Void){
        if let _ = ModelManager.getObjects(Tasking).filter("self.fieldID = %@",fieldNo).first {
            block()
        }else{
            updateSession {
                TYRequest(ContentType.pastTaskList, parameters: ["fieldNo":fieldNo]).TYResponseJSON(Block: { (JSON) in
                    if let field = ModelManager.getObjects(Farmland).filter("self.id = %@",fieldNo).first{
                        if let cropsList = JSON["taskRecords"] as? NSArray where cropsList.count > 0 {
                            if let list = cropsList[0]["fieldRecords"] as? NSArray{
                                for x in list {
                                    if let object = x as? [String:AnyObject]{
                                        let tasking = Tasking()
                                        tasking.note = object["attention"] as? String ?? "无"
                                        tasking.fieldID = fieldNo
                                        tasking.finishTime = (object["finishTime"] as! Double)/1000
                                        tasking.name = object["taskName"] as! String
                                        tasking.periodNo = object["periodNo"] as! String
                                        tasking.operation = object["taskFormula"] as! String
                                        tasking.crop = field.crops
                                        tasking.realTaskNo = object["taskNo"] as! String
                                        tasking.taskType = object["taskType"] as! String
                                        tasking.status = true
                                        try! ModelManager.realm.write({
                                            field.tasking.append(tasking)
                                        })
                                    }
                                }
                            }
                        }
                        block()
                    }
                })
            }
        }
    }
    
    class func pushAFinishedTask(fieldNo:String,cropNo:String,taskNo:String,operation:String){
        
        updateSession{
            TYRequest(ContentType.taskFinished, parameters: ["fieldNo":fieldNo,"cropNo":cropNo,"taskNo":taskNo,"variables":operation]).TYResponseJSON(Block: { (JSON) in
                if let msg = JSON["message"] as? String where msg == "success"{
                    print("提交成功")
                }
            })
        }
    }
    
    class func updateFarmland(action:((Bool)->Void)?=nil){
        updateSession{
            TYRequest(ContentType.updateFarmland, parameters: nil).TYresponseJSON(completionHandler: { (response) in
                var tag = false
                if response.result.isSuccess{
                    if let json = response.result.value as? [String:AnyObject]{
                        if let msg = json["message"] as? String where msg == "success"{
                            if let fields = json["fields"] as? NSArray{
                                let myFields = ModelManager.getObjects(Farmland).filter("self.userID = %@",TYUserDefaults.userID.value!)
                                var finish = fields.count
                                for x in fields{
                                    if let object = x as? [String:AnyObject]{
                                        let field = Farmland()
                                        field.deviceMac = object["deviceMac"] as! String
                                        field.id = object["fieldNo"] as! String
                                        field.name = (object["fieldName"] as? String) ?? "未设置"
                                        field.latitude = object["latitude"] as? Double ?? 0.0
                                        field.longitude = object["longitude"] as? Double ?? 0.0
                                        field.status = object["status"] as! String
                                        field.userID = object["userId"] as! String
                                        field.mianji = object["fieldArea"] as? Double ?? 0
                                        if myFields.filter("self.id == %@",field.id).first == nil{
                                            tag = true
                                            if let cropNo = object["cropNo"] as? String{
                                                //如果crop在上一步被赋值，则将crop相关的任务数据，参数一并下载下来，存储本地
                                                //下载任务履历
                                                getCrops(cropNo, action: { (crop) in
                                                    field.crops = crop
                                                    crop.starTime = (object["startTime"] as! Double)/1000
                                                    crop.startDate = NSDate(timeIntervalSince1970: crop.starTime)
                                                    ModelManager.add(field)
                                                    getPastTaskList(field.id, block: {
                                                        finish -= 1
                                                        if finish == 0{
                                                            if let finishAction = action{
                                                                finishAction(tag)
                                                            }
                                                        }
                                                    })
                                                })
                                                
                                            }else{
                                                //否则的话直接存储就可以了
                                                ModelManager.add(field)
                                                finish -= 1
                                                if finish == 0{
                                                    if let finishAction = action{
                                                        finishAction(tag)
                                                    }
                                                }
                                            }
                                        }else{
                                            //说明农田已经存在了。检查一下是否存在农作物，如果存在农作物的话，判断是否一样，如果不一样则替换
                                            if let crop = field.crops,let oldField = myFields.filter("self.id != %@",field.id).first,let oldCrop = myFields.filter("self.id != %@",field.id).first!.crops where oldCrop.id != crop.id{
                                                tag = true
                                                //农作物不一样，则替换当前农作物
                                                //先向服务器请求农作物数据，补充crop
                                                
                                               try! ModelManager.realm.write({
                                                    //将读到的农作物更新到农田当中
                                                    oldField.crops = crop
                                                finish -= 1
                                                if finish == 0{
                                                    if let finishAction = action{
                                                        finishAction(tag)
                                                    }
                                                }
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }else{
                    if let finishBlock = action{
                        finishBlock(false)
                    }
                }
            })
        }
    }
    
    class func PushNewForum(content:String,images:[UIImage],cropsID:String,block:(Bool)->Void){
        NetWorkManager.updateSession({
            Alamofire.upload(.POST, ContentType.PulishNewForum.url, multipartFormData: { data in
                var i = 0
                for image in images{
                    if let imageData = UIImageJPEGRepresentation(image, 0.95),let lowQualityImageData = UIImageJPEGRepresentation(image.resizeToSize(CGSizeMake(160, image.size.height / ( image.size.width / 160)), withInterpolationQuality: CGInterpolationQuality.High)!,1) {
                        data.appendBodyPart(data: imageData, name: "file", fileName: "images.jpg", mimeType: "image/jpg")
                        data.appendBodyPart(data: lowQualityImageData, name: "file", fileName: "images.jpg", mimeType: "image/jpg")
                        i += 1
                    }
                }
                let contentData = content.dataUsingEncoding(NSUTF8StringEncoding)
                data.appendBodyPart(data: contentData!, name: "content")
                data.appendBodyPart(data: cropsID.dataUsingEncoding(NSUTF8StringEncoding)!, name: "parentArea")
                data.appendBodyPart(data: "Discuss".dataUsingEncoding(NSUTF8StringEncoding)!, name: "type")
                }, encodingCompletion: { (result) in
                    switch result{
                    case .Success(let request,  _,  _):
                        request.TYresponseJSON(completionHandler: { (response) in
                            TYUserDefaults.NewForum.value = true
                        })
                        block(true)
                    case .Failure(_):
                        block(false)
                        break
                    }
            })
        })
    }
    
    class func PushNewExpertTopic(topic:ExpertTheme,images:[UIImage],callback:((Bool)->Void)? = nil){
        NetWorkManager.updateSession({
            Alamofire.upload(.POST, ContentType.PulishNewForum.url, multipartFormData: {
                data in
                    var i = 0
                    for image in images{
                        if let imageData = UIImageJPEGRepresentation(image, 0.95),let lowQualityImageData = UIImageJPEGRepresentation(image.resizeToSize(CGSizeMake(160, image.size.height / ( image.size.width / 160)), withInterpolationQuality: CGInterpolationQuality.High)!,1) {
                            data.appendBodyPart(data: imageData, name: "file", fileName: "images.jpg", mimeType: "image/jpg")
                            data.appendBodyPart(data: lowQualityImageData, name: "file", fileName: "images.jpg", mimeType: "image/jpg")
                            i += 1
                        }
                    }
                let contentData = topic.content.dataUsingEncoding(NSUTF8StringEncoding)
                let plantid = topic.classifyID.dataUsingEncoding(NSUTF8StringEncoding)
                let type = "Expert".dataUsingEncoding(NSUTF8StringEncoding)
                data.appendBodyPart(data: contentData!, name: "content")
                data.appendBodyPart(data: plantid!, name: "parentArea")
                data.appendBodyPart(data: type!, name: "type")
                }, encodingCompletion: { (result) in
                    switch result{
                    case .Success(let request,  _,  _):
                        request.TYResponseJSON(Block: { (JSON) in
                            dispatch_async(dispatch_get_main_queue(), {
                                if let message = JSON["message"] as? String where message == "success"{
                                    let info = (JSON["postInfo"] as! String).componentsSeparatedByString("|")
                                    topic.ID = info[0]
                                    let time = Double(info[1])
                                    topic.timeInterval = time!
                                    topic.lastReply = time!
                                    var images = [String]()
                                    for x in 2..<info.count{
                                        images.append(TYUserDefaults.UrlPrefix.value + info[x])
                                    }
                                    if images.count > 0 {
                                        topic.images = images
                                    }
                                    ModelManager.add(topic)
                                    if let block = callback{
                                        block(true)
                                    }
                                }else{
                                    if let block = callback{
                                        block(false)
                                    }
                                }
                            })
                        })
                    case .Failure(_):
                        if let block = callback{
                            block(false)
                        }
                    }
            })
        })
    }
    
    class func PushNewExpertReplay(message:ExpertMessage,postID:String,callback:((Bool)->Void)? = nil){
        NetWorkManager.updateSession({
                TYRequest(.PushAReply, parameters: ["content":message.content,"postNo":postID]).TYresponseJSON(completionHandler: { (response) in
                    if response.result.isSuccess{
                        if let json = response.result.value as? [String:AnyObject]{
                            if let msg = json["message"] as? String where msg == "success"{
                                dispatch_async(dispatch_get_main_queue(), {
                                    var replyInfo = (json["replyInfo"] as! String).componentsSeparatedByString("|")
                                    let sn = Int(replyInfo[1])!
                                    let time = Double(replyInfo[2])!
                                    message.replySn = sn
                                    message.timeInterval = time
                                    ModelManager.add(message)
                                    message.updateTheme()
                                    if let block = callback{
                                        block(true)
                                    }
                                })
                            }else{
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let block = callback{
                                        block(false)
                                    }
                                })
                            }
                        }
                    }
                })
            })
    }
    
    //下载专家区的帖子，更新本地
    //First来标识是第一次下载数据
    class func LoadExperTopic(first:Bool = false,own:Bool?=true,type:String = "",callback:(()->Void)? = nil){
        let dict = NSMutableDictionary(dictionary: ["type":"Expert","pageIndex":1,"pageCount":65535,"parentArea":type])
        if own == true && TYUserDefaults.role.value != RoleExpert{
            dict.setObject(TYUserDefaults.userID.value!, forKey: "userId")
        }
        NetWorkManager.updateSession { 
            TYRequest(.Forum, parameters: dict as! [String:AnyObject]).TYResponseJSON { (JSON) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    let localTheme = ModelManager.getObjects(ExpertTheme)
                    if let msg = JSON["message"] as? String where msg == "success"{
                        print(JSON)
                        if let array = (JSON["postList"] as! [String:AnyObject])["list"] as? NSArray{
                            for x in array{
                                let object = x as! [String:AnyObject]
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
                                if let images = object["images"] as? String{
                                    topic.images = images.componentsSeparatedByString("|").map(){return TYUserDefaults.UrlPrefix.value + $0}
                                }
                                if !localTheme.contains({$0.ID == topic.ID}){
                                    dispatch_async(dispatch_get_main_queue(), {
                                        ModelManager.add(topic)
                                    })
                                }
                            }
                        }
                        if let block = callback{
                            block()
                        }
                    }
                })
            }
        }
    }
    
    class func CheckNewExperTopic(own:Bool?=true,type:String = "",callback:(()->Void)? = nil){
        guard let lastestTime = ModelManager.getObjects(ExpertTheme).sorted("timeInterval", ascending: true).last?.timeInterval else{return}
        let dict = NSMutableDictionary(dictionary: ["type":"Expert","pageIndex":1,"pageCount":65535,"parentArea":type])
        if own == true && TYUserDefaults.role.value != RoleExpert{
            dict.setObject(TYUserDefaults.userID.value!, forKey: "userId")
        }
        dict.setObject(lastestTime, forKey: "lastDate")
        NetWorkManager.updateSession {
            TYRequest(.Forum, parameters: dict as! [String:AnyObject]).TYResponseJSON { (JSON) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                    let localTheme = ModelManager.getObjects(ExpertTheme)
                    if let msg = JSON["message"] as? String where msg == "success"{
                        if let postList = JSON["postList"] as? [String:AnyObject]{
                            if let array = postList["list"] as? NSArray{
                                for x in array{
                                    let object = x as! [String:AnyObject]
                                    let topic = ExpertTheme()
                                    if let content = object["content"] as? String{
                                        topic.content = content
                                    }else{
                                        topic.content = ""
                                    }
                                    topic.timeInterval = object["createDate"] as! Double
                                    topic.ID = object["postNo"] as! String
                                    topic.headPhoto = TYUserDefaults.UrlPrefix.value + (object["headImage"] as! String)
                                    topic.lastReply = object["lastReplyDate"] as! Double
                                    topic.name = object["username"] as! String
                                    topic.userID = object["userId"] as! String
                                    if let images = object["images"] as? [String]{
                                        topic.images = images.map(){TYUserDefaults.UrlPrefix.value + $0}
                                    }
                                    if !localTheme.contains({$0.ID == topic.ID}){
                                        dispatch_async(dispatch_get_main_queue(), {
                                            ModelManager.add(topic)
                                        })
                                    }
                                }
                            }
                        }
                        if let block = callback{
                            dispatch_async(dispatch_get_main_queue(), { 
                                block()
                            })
                        }
                    }
                })
            }
        }
    }
    
    class func updateTopicReply(topic:ExpertTheme){
        let latestSn = ModelManager.getObjects(ExpertMessage).filter("self.Theme.ID = %@", topic.ID).sorted("replySn", ascending: true).last?.replySn ?? 0
        NetWorkManager.updateSession({
            TYRequest(.Reply, parameters: ["pageIndex":1,"pageCount":65535,"postNo":topic.ID,"type":"Expert","lastReplySn":latestSn]).TYResponseJSON(Block: { (JSON) in
                if let replyList = JSON["replyList"] as? [String:AnyObject]{
                    if let list = replyList["list"] as? NSArray{
                        list.forEach({ (x) in
                            let object = x as! [String:AnyObject]
                            let message = ExpertMessage()
                            if let content = object["content"] as? String{
                                message.content = content
                            }
                            message.headPhoto = TYUserDefaults.UrlPrefix.value + (object["headImage"] as! String)
                            message.replySn = object["replySn"] as! Int
                            message.userID = object["userId"] as! String
                            message.name = object["username"] as! String
                            message.timeInterval = object["replyDate"]  as! Double
                            message.Theme = topic
                            dispatch_async(dispatch_get_main_queue(), {
                                ModelManager.add(message)
                            })
                        })
                    }
                }
            })
        })
    }
    
    class func GetCropsClass(callback:([CropsClass]->Void)){
        let cropsClassList = ModelManager.getObjects(CropsClass)
        if cropsClassList.count > 0 {
            var cropsClass = [CropsClass]()
            for x in cropsClassList{
                cropsClass.append(x)
                GetCropsList(x.id, callback: { (_) in
                    
                })
            }
            callback(cropsClass)
            return
        }
        NetWorkManager.updateSession{
                TYRequest(ContentType.CropsClassName, parameters: ["cropTypeNo":"000"]).TYresponseJSON(completionHandler: { (response) in
                    var cropsClass = [CropsClass]()
                    if response.result.isSuccess {
                        if let json = response.result.value as? [String : AnyObject]{
                            if let msg = json["message"] as? String where msg == "success"{
                                if let cropTypes = json["cropTypes"] as? NSArray{
                                    for x in cropTypes{
                                        if let object = x as? [String : AnyObject]{
                                            let cropClass = CropsClass()
                                            cropClass.id = object["cropTypeNo"] as! String
                                            cropClass.name = object["cropTypeName"] as! String
                                            cropClass.imageUrl = TYUserDefaults.UrlPrefix.value + (object["imageUrl"] as! String)
                                            cropsClass.append(cropClass)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    for x in cropsClass{
                        ModelManager.add(x)
                        GetCropsList(x.id, callback: { (_) in
                            
                        })
                    }
                    callback(cropsClass)
                })
        }
    }
    
    //仅仅用于专家页面选择分类
    class func GetCropsList(no:String,callback:([LocalCrops]->Void)){
        //检查是否已经在本地数据库已缓存，如有则直接返回
        let cropsList = ModelManager.getObjects(LocalCrops).filter("self.cropsClassID = %@", no)
        if cropsList.count > 0 {
            var crops = [LocalCrops]()
            for x in cropsList{
                crops.append(x)
            }
            callback(crops)
            return
        }
        //如果没有，则向网络发送请求
        NetWorkManager.updateSession{
            TYRequest(ContentType.CropsList, parameters: ["cropTypeNo":no]).TYresponseJSON(completionHandler: { (response) in
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    //异步处理数据
                    var crops = [LocalCrops]()
                    if response.result.isSuccess {
                        if let json = response.result.value as? [String:AnyObject]{
                            if let msg = json["message"] as? String where msg == "success"{
                                if let cropList = json["cropList"] as? NSArray{
                                    cropList.forEach({ (x) in
                                        if let object = x as? [String:AnyObject] {
                                            let crop = LocalCrops()
                                            crop.name = object["cropName"] as! String
                                            crop.id = object["cropNo"] as! String
                                            let urls = (object["imageUrl"] as! String).componentsSeparatedByString("|").map(){TYUserDefaults.UrlPrefix.value + $0}
                                            if urls.count == 3{
                                                crop.urlHome = urls[0]
                                                crop.urlDetail = urls[1]
                                                crop.url = urls[2]
                                            }else{
                                                crop.url = urls[0]
                                            }
                                            crops.append(crop)
                                        }
                                    })
                                }
                            }
                        }
                    }
//                    当所有数据请求完成之后，主线程回调
                    dispatch_async(dispatch_get_main_queue(), {
                        //将处理完的数据用数据库缓存
                        for x in crops{
                            ModelManager.add(x)
                        }
                        callback(crops)
                    })
                })
            })
        }
    }
}
