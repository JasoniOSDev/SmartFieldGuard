//
//  AlertTimeChooseViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/25.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import STPopup
import JTCalendar
class AlertTimeChooseViewController: TYViewController {

    @IBOutlet weak var LabelSelectDate: UILabel!
    @IBOutlet weak var calenderMenuView: JTCalendarMenuView!
    @IBOutlet weak var calenderView: JTHorizontalCalendarView!
    var calenderManager:JTCalendarManager!
    var block:((NSDate) -> Void)?
    lazy var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "当前选择: yyyy年MM月dd日"
        return formatter
    }()
    var selectDate:NSDate!{
        didSet{
            if(LabelSelectDate != nil){
                LabelSelectDate.text = dateFormatter.stringFromDate(selectDate)
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        self.contentSizeInPopup = CGSize(width: ScreenWidth - 40, height: 280)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let finishBlock = block{
            finishBlock(selectDate)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calenderManagerConfigure()
        LabelSelectDate.text = dateFormatter.stringFromDate(selectDate)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "OK_White"), style: .Plain, target: self, action: #selector(self.close))
    }
    
    func close(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func calenderManagerConfigure(){
        self.calenderManager = JTCalendarManager()
        calenderManager.delegate = self
        calenderManager.menuView = self.calenderMenuView
        calenderManager.contentView = self.calenderView
        calenderManager.setDate(selectDate)
    }
    
    class func pushAlertInViewController(viewController:TYViewController,date:NSDate?, block:(NSDate) -> Void){
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("AlertTimeChooseViewController") as! AlertTimeChooseViewController
        vc.block = block
        vc.selectDate = date ?? NSDate()
        let popController = STPopupController(rootViewController: vc)
        popController.containerView.layer.cornerRadius = 4
        popController.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarNormalTitleFont(),NSForegroundColorAttributeName:UIColor.MidBlackColor()]
        popController.navigationBar.tintColor = UIColor.MidBlackColor()
        popController.navigationBar.subviews[0].alpha = 0
        popController.presentInViewController(viewController, completion: nil)
    }
}

extension AlertTimeChooseViewController:JTCalendarDelegate{
    
    func calendar(calendar: JTCalendarManager!, prepareMenuItemView menuItemView: UIView!, date: NSDate!) {
        func StringFromdateFormatterWithYearAndMonth(date:NSDate) -> String{
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy年MM月"
            return formatter.stringFromDate(date)
        }
        if let label = menuItemView as? UILabel{
            label.text = StringFromdateFormatterWithYearAndMonth(date)
        }
    }
    
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        if let dayView = dayView as? JTCalendarDayView{
            if calenderManager.dateHelper.date(NSDate(), isTheSameDayThan: dayView.date){
                dayView.circleView.hidden = true
                dayView.textLabel.textColor = UIColor.DangerColor()
            }else
                if !calenderManager.dateHelper.date(calenderView.date, isTheSameMonthThan: dayView.date) {
                    dayView.circleView.hidden = true
                    dayView.textLabel.textColor = UIColor.LowBlackColor()
                }else{
                    dayView.circleView.hidden = true
                    dayView.textLabel.textColor = UIColor.MidBlackColor()
            }
            if  calenderManager.dateHelper.date(selectDate, isTheSameDayThan: dayView.date){
                dayView.circleView.hidden = false
                dayView.circleView.backgroundColor = UIColor.MainColor()
                dayView.textLabel.textColor = UIColor.whiteColor()
            }
        }
    }
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        if let dayView = dayView as? JTCalendarDayView{
            selectDate = dayView.date
            dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
            UIView.transitionWithView(dayView, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn,  animations: { 
                dayView.circleView.transform = CGAffineTransformIdentity
                self.calenderManager.reload()
                }, completion: nil)
            if !self.calenderManager.dateHelper.date(calenderView.date, isTheSameMonthThan: dayView.date){
                if calenderView.date.compare(dayView.date) == .OrderedAscending{
                    calenderView.loadNextPageWithAnimation()
                }else{
                    calenderView.loadPreviousPageWithAnimation()
                }
            }
            
        }
    }

}
