//
//  WisdomTask.swift
//  智慧田园
//
//  Created by jason on 16/5/28.
//  Copyright © 2016年 jason. All rights reserved.
//

import Foundation
import RealmSwift
class WisdomTask{
//    var str2 = "您的作物是杂交水稻，您的农田为#亩，需要#KG种子处理&&~B-NONGTIAN-AREA,@ADD/ B-NONGTIAN-AREA|B-NONGXUOWU-MEIMUZHONGZI"
    class func updateTask(){
        let farmlands = ModelManager.getObjects(Farmland)
        farmlands.forEach { (object) in
            object.updateTasking()
        }
    }

    class func convertToRealStr(Str:String,field:Farmland,finishAction:(str:String) -> Void){
        
        var Contents = Str.componentsSeparatedByString("&&")
        if Contents.count < 2{
            finishAction(str: Contents[0])
            return
        }
        var one = Contents[0].componentsSeparatedByString("#")
        var second = Contents[1].componentsSeparatedByString("|")
        var newStr = ""
        var finish = second.count
        let queue = NSOperationQueue()
        var values = [Int:Double]()
        queue.suspended = true
        
        queue.addOperationWithBlock { 
            for i in 0..<second.count{
                newStr += one[i] + String(format: "%.2f", values[i]!)
            }
            newStr += one.last!
            finishAction(str: newStr)
        }
        
        for i in 0..<second.count{
            let part = second[i]
            let index = i
            if part.characters.first != "@" {
                WTProperty.convertToValue(part,field: field, FinishAction: { (value) in
                    values[index] = value
                    finish -= 1
                    if finish == 0{
                        queue.suspended = false
                    }
                    
                })
            }else{
                //函数处理
                WTFunction.convertToValue(part.stringByReplacingOccurrencesOfString("@", withString: ""), field: field, FinishAction: { (value) in
                    values[index] = value
                    finish -= 1
                    queue.suspended = !((finish) == 0)
                })
            }
        }
    }
}


//~!Water(nan>bei
//属性格式~获得方式(E:表示从本地数据库获取,N:表示从网络获取)-属性名
class WTProperty:NSObject{
    
    enum ConditionStr:String{
        case Region = "zajiao"
    }
    
    class func actionConditionRegion(block:(name:String)->Void)->Void{
        
    }
    
    class func convertToValue(propertyStr:String,field:Farmland,FinishAction:(Double) -> Void){
        //处理尾部限制条件
            let parts = propertyStr.componentsSeparatedByString("(")
            var myCondition = ""
            if parts.count == 2{
                let condictions = parts[1].componentsSeparatedByString("|")
                condictions.forEach({ (condition) in
                    switch condition{
                    case ConditionStr.Region.rawValue:
                        actionConditionRegion({ (name) in
                            myCondition += name
                        })
                    default:break
                    }
                })
            }
        //处理前驱阶段问题
        var destStr = ""
        if parts[0].hasPrefix("!") == false{
            destStr = parts[0]+myCondition
        }else{
            destStr = field.periodNo + parts[0].stringByReplacingOccurrencesOfString("!", withString: "") + myCondition
            
        }
            //取数据
       field.getValueFrom(destStr) {FinishAction($0)}
    }
}
//@ADD/B-NONGTIAN-AREA|B-NONGXUOWU-MEIMUZHONGZI
class WTFunction:NSObject{
    
    enum Function:String{
        case QiCheng = "qc"
        case YuanCheng = "yc"
        case Feiniaosu = "feiniaosu"
        case Feigai = "feigai"
        case Feiliusuanjia = "feiliusuanjia"
    }
    
    class func convertToValue(FuncStr:String,field:Farmland,FinishAction:(Double) -> Void){

            
        let parts = FuncStr.componentsSeparatedByString("/")
        let propertyStrs = parts[1]
        let properties = propertyStrs.componentsSeparatedByString("%")
        var values = [Int:Double]()
        let queue = NSOperationQueue()
        queue.suspended = true
        
        //选择方法
        switch parts[0] {
        case Function.QiCheng.rawValue:
            queue.addOperationWithBlock({ 
                FinishAction(QiCheng(values))
            })
        case Function.YuanCheng.rawValue:
            queue.addOperationWithBlock({ 
                FinishAction(YuanCheng(values))
            })
        case Function.Feigai.rawValue:
            queue.addOperationWithBlock({ 
                FinishAction(Feigai(values))
            })
        case Function.Feiniaosu.rawValue:
            queue.addOperationWithBlock({ 
                FinishAction(Feiniaosu(values))
            })
        case Function.Feiliusuanjia.rawValue:
            queue.addOperationWithBlock({ 
                FinishAction(Feiliusuanjia(values))
            })
        default:
            break
        }
        
        var finish = properties.count
        for i in 0..<properties.count{
            let propertyStr = properties[i]
            let index = i
            WTProperty.convertToValue(propertyStr,field: field, FinishAction: { (value) in
                values[index] = value
                finish -= 1
                queue.suspended = !((finish) == 0)
            })
        }
    }
    
    class func Feiniaosu(values:[Int:Double]) -> Double{
        return values[0]! * 0.025 * (60 - values[1]!)
    }
    
    class func Feigai(values:[Int:Double]) -> Double{
        return values[0]! * 0.005 * (60 - values[1]!)
    }
    
    class func Feiliusuanjia(values:[Int:Double]) -> Double{
        return values[0]! * 0.015 * (60 - values[1]!)
    }
    
    class func QiCheng(values:[Int:Double]) -> Double{
        
        return values[0]! * values[1]!
    }
    
    class func YuanCheng(values:[Int:Double]) -> Double{
        
        return values[0]! * values[1]! * values[2]!
    }
    
}

class TaskCondition:NSObject{
    //为了判断某一个触发条件是否符合
    
    enum conditionFunc:String{
        case Less = "<"
        case more = ">"
        case equal = "="
        case lessEqual = "<="
        case moreEqual = ">="
    }
    
    class func Check(condition:TaskFireCondition,field:Farmland,resultBlock:(Bool)->Void){
        WTProperty.convertToValue(condition.property, field: field) { (property) in
            let value = (condition.value as NSString).doubleValue
            switch condition.method {
            case conditionFunc.Less.rawValue:
                resultBlock(property < value)
            case conditionFunc.lessEqual.rawValue:
                resultBlock(property <= value)
            case conditionFunc.more.rawValue:
                resultBlock(property > value)
            case conditionFunc.moreEqual.rawValue:
                resultBlock(property >= value)
            case conditionFunc.equal.rawValue:
                resultBlock(property == value)
            default:
                break
            }
        }
    }
}




