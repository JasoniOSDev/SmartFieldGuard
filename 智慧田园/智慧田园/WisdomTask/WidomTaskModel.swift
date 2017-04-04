//
//  WidomTaskModel.swift
//  智慧田园
//
//  Created by jason on 16/5/28.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import RealmSwift

//农作物类
class CropsClass:Object{
    dynamic var id:String = ""
    dynamic var name:String = ""
    dynamic var subClass:CropsClass?
    dynamic var imageUrl = ""
}

class LocalCrops: Object {
    dynamic var id:String = ""
    dynamic var name:String = ""
    dynamic var cropsClassID = ""
    dynamic var url = ""
    dynamic var urlHome = ""
    dynamic var urlDetail = ""
}

class HistoryFertilize:Object{
    dynamic var operatorid = ""//取决于他是哪块田的哪块种植
    let history = List<Fertilize>()
    dynamic var time = 0.0
    
    class func createAHistory(history:[Fertilize],time:Double,crop:Crops){
        let object = HistoryFertilize()
        history.forEach { (x) in
            object.history.append(x)
        }
        object.time = time
        object.operatorid = crop.id
        ModelManager.add(object)
    }
}

class Fertilize:Object{
    dynamic var id = ""
    dynamic var name = ""
    dynamic var value = 0.0//施肥量
    //肥料
    override class func primaryKey() -> String{
        return "id"
    }
}

//作物类
class Crops: Object {
    dynamic var operatorid = ""//唯一确定这块田的这次种植
    dynamic var id:String = ""
    dynamic var name:String = ""
    dynamic var periodNO = ""
    dynamic var urlHome = ""
    dynamic var urlDetail = ""
    dynamic var growDays = 0
    dynamic var url = ""
    dynamic var startDate = NSDate()
    dynamic var starTime = 0.0
    dynamic var quickLook:String = ""
    dynamic var temperatureQuickLook:String = ""
    dynamic var sunQuickLook:String = ""
    dynamic var waterQuickLook:String = ""
    dynamic var soilQuickLook:String = ""
    dynamic var properties: NSData =  NSData()
    dynamic var cropsImage = NSData()
    let tasks = List<Task>()
    let FinishTask = List<Task>()
    var currentTime:Int{
        get{
            let today = NSDate()
            return Int(today.timeIntervalSinceDate(startDate)/86400) + 1
        }
    }
    var propertyDict:[String:AnyObject] {
        get{
            let option = NSJSONReadingOptions.AllowFragments
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(self.properties, options: option) as! [String:AnyObject]
                return json
            }catch{
                return [:]
            }
        }
    }
    var standerTime:Int{
        get{
            let date = NSDate(timeIntervalSince1970: starTime/1000)
            let dis = -date.timeIntervalSinceNow
            return Int(dis / 86400.0)
        }
    }
    
    override func valueForUndefinedKey(key: String) -> AnyObject? {
        return nil
    }
    override class func primaryKey() -> String{
        return "operatorid"
    }
    
}

//农田类
class Farmland: Object{
    dynamic var userID:String = ""
    dynamic var id:String = ""
    dynamic var deviceMac = ""
    dynamic var name:String = ""
    dynamic var mianji:Double = 0.0
    dynamic var longitude:Double = 0.0
    dynamic var latitude:Double = 0.0
    dynamic var positionStr = ""
    dynamic var crops:Crops?
    dynamic var properties: NSData =  NSData()
    dynamic var lastCheckFertilizeTime = 0.0
    dynamic var lastFertility = 0.0
    dynamic var lastFeritilizeTIme = 0.0
    dynamic var soilT = 0.0//土壤温度
    dynamic var soilW = 0.0//土壤湿度
    dynamic var airT = 0.0
    dynamic var airW = 0.0
    dynamic var co2 = 0.0
    dynamic var light = 0.0
    dynamic var status = ""
    dynamic var periodNo = ""
    let pastCrops = List<Crops>()
    let tasking = List<Tasking>()//该农田正在进行的任务
    let pastFertilities = List<Fertility>()
    
    var linshibili:Int{
        get{
            return Int(lastFertility)
        }
    }
    
    var soilLastTestTime:Int{
        get{
            let date = NSDate(timeIntervalSince1970: self.lastCheckFertilizeTime)
            let now = NSDate(timeIntervalSince1970:(NSDate().timeIntervalSince1970 + 28800))
            return Int(now.timeIntervalSinceDate(date)/86400)
        }
    }
    
    var lastFeritilizeTime:Int{
        get{
            let date = NSDate(timeIntervalSince1970: self.lastFeritilizeTIme)
            let now = NSDate(timeIntervalSince1970:(NSDate().timeIntervalSince1970 + 28800))
            return Int(now.timeIntervalSinceDate(date)/86400)
        }
    }
    
       typealias fillAction = (air_t:Double,air_w:Double,soil_t:Double,soil_w:Double,co2:Double,light:Double) -> Void
    var fillDataInViewAction:fillAction?
    var propertyDict:[String:Double] {
        get{
            let option = NSJSONReadingOptions.AllowFragments
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(self.properties, options: option) as! [String:Double]
                return json
            }catch{
                return [:]
            }
        }
    }
    
    func updateFertility(value:Double){
        try!ModelManager.realm.write{
            let object = Fertility()
            self.lastCheckFertilizeTime = NSDate().timeIntervalSince1970 + 28800
            self.lastFertility = value
            object.id = NSUUID().UUIDString
            object.time = lastCheckFertilizeTime
            object.value = value
            self.pastFertilities.append(object)
        }
    }
    
    var startTimeStr:String{
        get{
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日"
            if let date = crops?.startDate{
                return dateFormatter.stringFromDate(date)
            }
            return "未设置"
        }
    }
    
    override class func ignoredProperties() -> [String]{
        return ["fillDataInViewAction","fillAction"]
    }
    
    override func valueForUndefinedKey(key: String) -> AnyObject? {
        return nil
    }
    
    func updateTasking(block:(()->Void)? = nil){
        
        try! ModelManager.realm.write{
            for x in self.tasking{
                if x.status == false {
                    ModelManager.realm.delete(x)
                }
            }
        }
        if let crop = self.crops{
            let taskings = self.tasking
            
            let queue = NSOperationQueue()
            queue.suspended = true
            queue.addOperationWithBlock({
                if let Block = block {
                    Block()
                }
            })
            var signal = crop.tasks.count
            for task in crop.tasks{
                signal -= 1
                //从这个作物的任务表里面遍历出符合触发条件的任务
                switch task.taskType {
                //判断任务的类型
                case "Everyday":
                    //判断一下是否符合时间节点以及在做过的任务当中有没有做过
                    if task.startTime <= crop.currentTime && self.tasking.filter("self.realTaskNo == %@",task.id).count == 0{
                        //判断前驱任务
                        if task.lastTaskid != "0" {
                            let x = self.tasking.filter("self.realTaskNo = %@ ",task.lastTaskid).first
                            if x == nil {
                                continue
                            }
                            if x?.status != true{
                                continue
                            }
                        }
                        //前面都通过了
                        //说明该任务可做。则生成正在执行的任务
                        signal += 1
                        Tasking.CreateTasking(self, task: task, block: { (tasking) in
                            //内层已经处于一个事务当中
                            taskings.append(tasking)
                            signal -= 1
                            if signal == 0 {
                                queue.suspended = false
                            }
                        })
                    }
                default:
                    //临时任务
                    if task.startTime <= crop.currentTime && self.tasking.filter("self.realTaskNo == %@ and self.status == false",task.id).count == 0{
                        //判断触发条件
                        var finishCount = task.fireCondition.count
                        if finishCount != 0 {
                            
                            for x in task.fireCondition{
                                TaskCondition.Check(x, field: self, resultBlock: { (result) in
                                    if result == true{
                                        finishCount -= 1
                                        if finishCount == 0{
                                            signal += 1
                                            Tasking.CreateTasking(self, task: task, block: { (tasking) in
                                                //内层已经处于一个事务当中
                                                taskings.append(tasking)
                                                signal -= 1
                                                if signal == 0 {
                                                    queue.suspended = false
                                                }
                                            })
                                        }
                                    }
                                })
                            }
                            
                        }else{
                            //前面都通过了
                            //说明该任务可做。则生成正在执行的任务
                            signal += 1
                            Tasking.CreateTasking(self, task: task, block: { (tasking) in
                                //内层已经处于一个事务当中
                                taskings.append(tasking)
                                signal -= 1
                                if signal == 0 {
                                    queue.suspended = false
                                }
                            })
                        }
                    }
                    
                }
            }
            if signal == 0 {
                queue.suspended = false
            }
        }
    }
    
    func updateEnvironmentData(block:((Farmland)->Void)?){
        //从网络请求farmLand的数据
        //更新本地数据库数据
        //执行对应的闭包操作
        NetWorkManager.updateSession{
            TYRequest(ContentType.fieldData, parameters: ["fieldNo":self.id]).TYresponseJSON { (response) in
                if let json = response.result.value as? [String:AnyObject]{
                    if let fieldData = json["fieldData"] as? [String:AnyObject]{
                        self.setEnvironmentData(fieldData)
                        if let finishBlock = block {
                            finishBlock(self)
                        }
                    }
                }
            }
        }
    }
    
    func setEnvironmentData(json:[String:AnyObject]){
        try! ModelManager.realm.write({
            self.airT = json["airT"] as! Double
            self.airW = json["airW"] as! Double
            self.co2 = json["co2"] as! Double
            self.light = json["light"] as! Double
            self.soilT = json["soilT"] as! Double
            self.soilW = json["soilW"] as! Double
        })
        fillDataInView()
    }
    
    func fillDataInView(){
        if let action = self.fillDataInViewAction{
            action(air_t: self.airT,air_w: self.airW,soil_t: self.soilT,soil_w: self.soilW,co2: self.co2,light: self.light)
        }
    }
    
    //检查一下该农田的任务，更新正在进行的任务,并在更新完成之后执行回调
    func dispatchTask(block:()->Void){
        
    }
    
    func getValueFrom(name:String,action:(Double)->Void){
        if let value = self.valueForKey(name) as? Double {
            action(value)
        }else{
            if let crop = self.crops{
                if let value = crop.valueForKey(name) as? Double{
                    action(value)
                }else{
                    action((crop.propertyDict[name] as! NSString).doubleValue)
                }
            }
        }
    }
    
    class func getFieldByDeviceMac(deviceMac:String) -> Farmland{
        let fields = ModelManager.getObjects(Farmland)
        return fields.filter("self.deviceMac = %@", deviceMac).first!
    }
    
    class func setEnvironMent(json:[String:AnyObject]){
        if let deviceMac = json["deviceMac"] as? String{
            let field = getFieldByDeviceMac(deviceMac)
            field.setEnvironmentData(json)
        }
    }
    
}

class Fertility:Object{
    dynamic var id = ""
    dynamic var time = 0.0
    dynamic var value = 0.0
}

//任务类
class Task: Object{
    dynamic var id:String = ""
    dynamic var crops:Crops?
    dynamic var name:String = ""
    dynamic var operation = ""
    dynamic var note:String = ""
    dynamic var lastTaskid = ""
    dynamic var type = ""
    dynamic var taskType = ""
    dynamic var startTime = 0//开始时间
    dynamic var needTime = 0
    dynamic var period = ""//属于哪个时期
    dynamic var periodNO = ""
    let fireCondition = List<TaskFireCondition>()

}
//正在进行的任务，主要是保存翻译完成的任务
class Tasking:Object{
    dynamic var fieldID = ""
    dynamic var id = ""
    dynamic var name = ""
    dynamic var operation = ""//解析完成后的内容
    dynamic var note = ""
    dynamic var realTask:Task?
    dynamic var realTaskNo = ""
    dynamic var finishTime:Double = 0
    dynamic var taskType = ""
    dynamic var status = false//是否已经完成
    dynamic var crop: Crops?
    dynamic var periodNo = ""
    static var dateFormatter: NSDateFormatter{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd   HH:mm"
        return dateFormatter
    }
    static var idCount = 0
    func getFinishTimeStr() -> String{
        return Tasking.dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: finishTime))
    }
    
    func taskCompete(){
       try! ModelManager.realm.write {
            self.status = true
            finishTime = NSDate().timeIntervalSince1970
        let operation = realTask?.operation.componentsSeparatedByString("&&").count > 1 ? self.operation : ""
        NetWorkManager.pushAFinishedTask(fieldID, cropNo: (crop?.id)!, taskNo:(realTask?.id)!, operation: operation)
            if self.name == "临时加肥"{
                let fields = ModelManager.getObjects(Farmland)
                    for field in fields{
                    if field.tasking.filter("self.id == %@",self.id).count > 0{
                        field.lastFeritilizeTIme = NSDate().timeIntervalSince1970
                    }
                }
                
            }
        }
    }
    
    override class func ignoredProperties() -> [String]{
        return ["dateFormatter"]
    }
    
    class func CreateTasking(field:Farmland,task:Task,block:(Tasking)->Void){
        WisdomTask.convertToRealStr(task.operation, field: field,finishAction:  { (str) in
            dispatch_async(dispatch_get_main_queue(), {
                try! ModelManager.realm.write({
                    field.crops?.periodNO = task.periodNO
                    let tasking = Tasking()
                    tasking.id = NSUUID().UUIDString
                    tasking.name = task.name
                    tasking.note = task.note
                    tasking.operation = str
                    tasking.taskType = task.taskType
                    tasking.crop = task.crops
                    tasking.periodNo = task.periodNO
                    tasking.fieldID = field.id
                    tasking.realTask = task
                    tasking.realTaskNo = task.id
                    block(tasking)
                })
            })
        })
    }
}

//触发条件类
class TaskFireCondition:Object{
    dynamic var property = ""//根据变量的公式
    dynamic var method = ""//比对的方法，比大小还是
    dynamic var value = ""//对比的值
}

class ModelManager{
    static var realm: Realm{
        var real:Realm?
        let config = Realm.Configuration(
            schemaVersion: 23,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
        })
        Realm.Configuration.defaultConfiguration = config
        real = try! Realm()
//        print(config.fileURL)
        return real!
    }
    
    class func add(object: Object, update: Bool = false) {
        try!realm.write {
            realm.add(object)
        }
    }
    
    class func getObjects<T : RealmSwift.Object>(type: T.Type) -> RealmSwift.Results<T>{
        return realm.objects(type)
    }
    
    class func removeAll(){
        try!realm.write {
            realm.deleteAll()
        }
    }
}
