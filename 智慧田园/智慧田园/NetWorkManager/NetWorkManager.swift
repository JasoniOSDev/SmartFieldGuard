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
    var actions = [String:[NetWorkAction]]()
    var locActions = [String:[locNetWorkAction]]()
    var actionsKey = [String:Set<ActionKey>]()
    private override init(){
        super.init()

    }
    typealias NetWorkAction = ()->Void
    typealias locNetWorkAction = ()->Void
    
    enum ActionKey:String{
        case UpdateAdvice = "UpdateAdvice"
        case NeedUpdateSession = "NeedUpdateSession"
    }
    enum observerKey:String{
        case UpdateSession = "UpdateSession"
        case Logined = "Logined"
    }
    
    private func ActionForKey(key:observerKey){
        if let Actions = actions[key.rawValue]{
            for x in  Actions{
                x()
            }
        }
        if let Actions = locActions[key.rawValue]{
            for x in Actions{
                x()
            }
        }
    }
    
    let UpdateAdvice:NetWorkAction = {
        //更新存在数据库的设备信息
    }
    
    let NeedUpdateSession:NetWorkAction = {
        if let username = TYUserDefaults.userID.value,let pwd = TYUserDefaults.passWord.value{
            let parameters:[String:AnyObject] = ["username":username,"password":pwd]
            TYRequest(.Login, parameters: parameters)
        }
    }
    
    class func login(parameters:[String:AnyObject],action:(json:[String:AnyObject])->Void){
        TYRequest(.Login, parameters: parameters).TYresponseJSON(completionHandler: {  response in
            if(response.result.isSuccess){
                print("----------LOGIN------------")
                print(response)
                print("----------LOGIN------------")
                if let json = response.result.value as? [String:AnyObject]{
                    let message = json["message"] as! String
                    if(message == "success"){
                        TYUserDefaults.UrlPrefix.value = json["staticUrlPrefix"] as! String
                        let userInfo = json["userInfo"] as! [String:AnyObject]
                        TYUserDefaults.userID.value = userInfo[UserIDKey] as? String
                        TYUserDefaults.headImage.value = TYUserDefaults.UrlPrefix.value + (userInfo[HeadImageKey] as! String)
                        TYUserDefaults.role.value = userInfo[RoleKey] as! String
                        TYUserDefaults.tel.value = userInfo[TelKey] as? String
                        TYUserDefaults.username.value = userInfo[UsernameKey] as? String
                        TYUserDefaults.passWord.value = parameters["password"] as? String
                        ExpertClient.shareClient.connect()
                    }else{
                        TYUserDefaults.cookie.value = TYUserDefaults.cookieDefault
                        TYUserDefaults.lastConnectTime.value = 0
                        TYUserDefaults.userID.value = nil
                    }
                    action(json: json)
                }
            }else{
                print(response)
            }
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
    
    class func updateFarmland(action:((Bool)->Void)?=nil){
        updateSession{
            TYRequest(ContentType.updateFarmland, parameters: nil).TYresponseJSON(completionHandler: { (response) in
                print(response)
                var tag = false
                if response.result.isSuccess{
                    if let json = response.result.value as? [String:AnyObject]{
                        if let msg = json["message"] as? String where msg == "success"{
                            if let fields = json["fields"] as? NSArray{
                                let myFields = ModelManager.getObjects(Farmland).filter("self.userID = %@",TYUserDefaults.userID.value!)
                                var finish = fields.count
                                fields.forEach({ (x) in
                                    if let object = x as? [String:AnyObject]{
                                        let field = Farmland()
                                        field.id = object["fieldNo"] as! String
                                        field.name = object["fieldName"] as! String
                                        field.latitude = object["latitude"] as? Double ?? 0.0
                                        field.longitude = object["longitude"] as? Double ?? 0.0
                                        field.status = object["status"] as! String
                                        field.userID = object["userId"] as! String
                                        field.mianji = object["fieldArea"] as? Double ?? 0
                                        if myFields.filter("self.id == %@",field.id).first == nil{
                                            tag = true
                                            if let cropNo = object["cropNo"] as? String{
                                                //如果crop在上一步被赋值，则将crop相关的任务数据，参数一并下载下来，存储本地
                                                getCrops(cropNo, action: { (crop) in
                                                    field.crops = crop
                                                    crop.starTime = (object["startTime"] as! Double)/1000
                                                    crop.startDate = NSDate(timeIntervalSince1970: crop.starTime)
                                                    ModelManager.add(field)
                                                    finish -= 1
                                                    if finish == 0{
                                                        if let finishAction = action{
                                                            finishAction(tag)
                                                        }
                                                    }
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
                                })
                            }
                        }
                    }
                }
                if let finishBlock = action{
                    finishBlock(false)
                }
            })
        }
    }
    
    class func PushNewExpertTopic(topic:ExpertTheme,images:[UIImage],callback:((Bool)->Void)? = nil){
        NetWorkManager.updateSession({
            Alamofire.upload(.POST, ContentType.PulishNewForum.url, multipartFormData: {
                data in
                    var i = 0
                    for image in images{
                        if let imageData = UIImageJPEGRepresentation(image, 0.95) {
                            data.appendBodyPart(data: imageData, name: "file", fileName: "images.jpg", mimeType: "image/jpg")
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
                                    topic.ID = NSUUID().UUIDString
                                    topic.timeInterval = (NSDate().timeIntervalSince1970 + 28800)*1000
                                    ModelManager.add(topic)
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
                                message.updateTheme(true)
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
        let cropsList = ModelManager.getObjects(LocalCrops).filter("self.cropsClassID = %@", no)
        if cropsList.count > 0 {
            var crops = [LocalCrops]()
            for x in cropsList{
                crops.append(x)
            }
            callback(crops)
            return
        }
        NetWorkManager.updateSession{
            TYRequest(ContentType.CropsList, parameters: ["cropTypeNo":no]).TYresponseJSON(completionHandler: { (response) in
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
                for x in crops{
                    ModelManager.add(x)
                }
                callback(crops)
            })
        }
    }
}