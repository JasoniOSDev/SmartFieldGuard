//
//  TYConfig.swift
//  智慧田园
//
//  Created by jason on 16/5/19.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

let LightLanTingHeiFontName = "FZLanTingHei-L-GBK-M"
let NormalLanTingHeiFontName = "FZLanTingHei-R-GBK"
let ScreenHeight = UIScreen.mainScreen().bounds.height
let ScreenWidth = UIScreen.mainScreen().bounds.width
let GDKey = "321955d2114ce16138d9a3df1fd8ea66"
extension UIColor{
    //用整数来创建一个颜色
    convenience init(R:CGFloat,G:CGFloat,B:CGFloat, alpha: CGFloat){
        self.init(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: alpha)
    }
    convenience init(RGB:Int,alpha:CGFloat){
        let r = CGFloat((RGB & 0xFF0000)>>16)
        let g = CGFloat((RGB & 0xFF00)>>8)
        let b =  CGFloat((RGB & 0xFF))
        self.init(R:r,G:g,B:b,alpha: alpha)
    }
    
    //---------三个级别的黑色字体---------
    //高级黑
    class func HightBlackColor() -> UIColor{
        return UIColor(RGB: 0x333333,alpha: 1)
    }
    //中级黑
    class func MidBlackColor() -> UIColor{
        return UIColor(RGB: 0x666666, alpha: 1)
    }
    //低级黑
    class func LowBlackColor() -> UIColor{
        return UIColor(RGB: 0x999999, alpha: 1)
    }
    //文本黑
    class func TxtBlackColor() -> UIColor{
        return UIColor(RGB: 0x4a4a4a, alpha: 1)
    }
    
    //---------导航栏的字体颜色---------
    class func NavigationBarTitleColor()->UIColor{
        //0x333333
        return UIColor.HightBlackColor()
    }
    
    
    //---------卡片详情页面---------
    //任务组标题颜色
    class func DetailCardTaskGroupTitleColor() -> UIColor{
        return UIColor.MainColor()
    }
    //任务标题颜色
    class func DetailCardTaskTitleColor() -> UIColor{
        return UIColor.LowBlackColor()
    }
    //任务字体颜色
    class func DetailCardTaskDetailColor()->UIColor{
        return UIColor(RGB: 0x999999, alpha: 1)
    }
    
    //---------设置页面---------
    //每项标题颜色
    class func SettingTitleColor()->UIColor{
        return DetailCardTaskDetailColor()
    }
    //每项内容的颜色
    class func SettingContentColor() -> UIColor{
        return UIColor.MainColor()
    }
    
    class func MainColor() -> UIColor{
        //蓝色
        return UIColor(RGB: 0x66CCFF,alpha: 1)
    }
    
    class func BackgroundColor() -> UIColor{
        //浅灰色背景
        return UIColor(RGB: 0xf2f2f2, alpha: 1)
    }
    
    //---------讨论区---------
    //-----讨论内容-----
    //内容字体
    class func DiscussionContentColor() -> UIColor{
        return TxtBlackColor()
    }
    //时间字体
    class func DiscussionColor() -> UIColor{
        return LowBlackColor()
    }
    //-----栏目-----
    //标题字体
    //选中
    class func DiscussionClassTitleChooseColor() -> UIColor{
        return MainColor()
    }
    //未选中
    class func DiscussionClassTitleUnChooseColor() -> UIColor{
        return MidBlackColor()
    }
    //-----发问题-----
    //内容颜色
    class func DiscussionPushOneContentColor() -> UIColor{
        return TxtBlackColor()
    }
    //-----问题详情------
    //用户名颜色
    class func DiscussReplyUserNameColor() -> UIColor{
        return MainColor()
    }
    //回复颜色
    class func DiscussReplyContentColor() -> UIColor{
        return MidBlackColor()
    }
    //选择为满意答案提示颜色
    class func DiscussReplyTipColor() -> UIColor{
        return MainColor()
    }
    //回复框内容颜色
    class func DiscussReplyRegionContentColor() -> UIColor{
        return HightBlackColor()
    }
    
    //---------专家咨询---------
    //个人消息颜色
    class func ExpertFirstColor() -> UIColor{
        return TxtBlackColor()
    }
    //专家消息颜色
    class func ExpertSecondColor() -> UIColor{
        return whiteColor()
    }
    
    //---------三种级别颜色---------
    //危险级别
    class func DangerColor() -> UIColor{
        return UIColor(RGB: 0xFF6666, alpha: 1)
    }
    //警告级别
    class func WarnColor() -> UIColor{
        return UIColor(RGB: 0xffcc33, alpha: 1)
    }
    //安全级别
    class func SafeColor() -> UIColor{
        return UIColor(RGB: 0x99cc33, alpha: 1)
    }
}

extension UIFont{
    
    //导航栏标题字体
    class func NavigationBarTitleFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 20)!
    }
    class func NavigationBarNormalTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 20)!
    }
    
    //---------主页---------
    //标题字体
    class func MainCardTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 18)!
    }
    //预计收成字体
    class func MainCardPreFinishFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 8)!
    }
    //未完成提示字体
    class func MainCardUnFinishFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 14)!
    }
    //指数字体
    class func MainCardDataFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 12)!
    }
    
    //---------卡片详情页面---------
    //标题字体
    class func DetailCardTitleFont()->UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 28)!
    }
    //未完成提示字体
    class func DetailCardUnFinishFont() -> UIFont{
        return MainCardUnFinishFont()
    }
    //播种日期字体
    class func DetailCardStartTimeFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 10)!
    }
    
    //-----指数-----
    //指数标题字体
    class func DetailCardDataTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 20)!
    }
    //指数的子标题
    class func DetailCardDataChildTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 16)!
    }
    //指数
    class func DetailCardDataFont() -> UIFont{
         return UIFont(name: NormalLanTingHeiFontName, size: 19)!
    }
    
    //-----任务-----
    //任务组标题字体
    class func DetailCardGroupTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 14)!
    }
    //任务标题字体
    class func DetailCardTaskTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 18)!
    }
    //任务内容字体
    class func DetailCardTaskDetailFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 14)!
    }
    
    //----------设置界面---------
    //设置项标题字体
    class func SettingTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 18)!
    }
    //内容字体
    class func SettingContentFont()->UIFont{
        return SettingTitleFont()
    }
    
    //---------讨论区---------
    //-----讨论内容-----
    //内容字体
    class func DiscussionContentFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 16)!
    }
    //时间字体
    class func DiscussionFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 8)!
    }
    //-----栏目-----
    //标题字体
    class func DiscussionClassTitleFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 16)!
    }
    
    //-----发问题-----
    //内容字体
    class func DiscussionPushOneContentFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 16)!
    }
    //-----问题详情------
    //用户名字体
    class func DiscussReplyUserNameFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 16)!
    }
    //回复颜色
    class func DiscussReplyContentFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 14)!
    }
    //选择为满意答案提示颜色
    class func DiscussReplyTipFont() -> UIFont{
        return UIFont(name: LightLanTingHeiFontName, size: 14)!
    }
    //回复框字体
    class func DiscussReplyRegionContentFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 16)!
    }
    
    //---------专家咨询---------
    //内容字体
    class func ExpertFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 16)!
    }
    //时间字体
    class func ExpertTimeFont() -> UIFont{
        return UIFont(name: NormalLanTingHeiFontName, size: 8)!
    }
}
