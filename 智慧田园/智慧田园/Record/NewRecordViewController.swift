//
//  NewRecordViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/24.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import JTCalendar
import RealmSwift
class NewRecordViewController: TYViewController {
    
    @IBOutlet weak var ButtonSure: UIButton!
    @IBOutlet weak var CalendarViewContent: UIView!
    @IBOutlet weak var calendarContentView: JTHorizontalCalendarView!
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var ConstraintCalenderTop: NSLayoutConstraint!
    @IBOutlet weak var ButtonStart: UIButton!
    @IBOutlet weak var ButtonEnd: UIButton!
    @IBOutlet weak var tableView: UITableView!
    let calendarManager = JTCalendarManager()
    var Tasks = [Tasking]()
    var visibleTask = [Tasking]()
    var buttonTag = 0
    var calendarHidden = false
    lazy var taskDetailViewController:TaskDetailViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("TaskDetailViewController") as! TaskDetailViewController
        return vc
    }()
    lazy var dateFormatter:NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    var StartSelectDate:NSDate = NSDate(){
        didSet{
            ButtonStart.setTitle(dateFormatter.stringFromDate(StartSelectDate), forState: .Normal)
        }
    }
    var EndSelectDate:NSDate = NSDate(){
        didSet{
            ButtonEnd.setTitle(dateFormatter.stringFromDate(EndSelectDate), forState: .Normal)
        }
    }
    var currentSelectDate:NSDate{
        get{
            if(buttonTag == 110){
                return StartSelectDate
            }else{
                return EndSelectDate
            }
        }
        set{
            if(buttonTag == 110){
                StartSelectDate = newValue
            }else{
                EndSelectDate = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calenderManagerConfigure()
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.MidBlackColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.subviews[0].alpha = 1
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    private func calenderManagerConfigure(){
        calendarManager.delegate = self
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        calendarManager.setDate(NSDate())
    }
    
    private func prepareUI(){
        CloseCalenderView(0)
        tableViewConfigure()
        self.title = "作物履历"
        ButtonStart.setTitleColor(UIColor.DangerColor(), forState: .Selected)
        ButtonEnd.setTitleColor(UIColor.DangerColor(), forState: .Selected)
        self.StartSelectDate = NSDate()
        self.EndSelectDate = self.StartSelectDate
        ButtonCalenderSureClicked(ButtonSure)
    }
    
    private func tableViewConfigure(){
        tableView.registerReusableCell(TaskTableViewCell)
        tableView.clearOtherLine()
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.separatorStyle = .SingleLine
    }
    
    private func CloseCalenderView(timeInterval:Double){
        if self.calendarHidden == false{
            self.calendarHidden = true
            dispatch_async(dispatch_get_main_queue()) {
                UIView.animateWithDuration(timeInterval) {
                    self.ConstraintCalenderTop.constant = -self.CalendarViewContent.frame.height
                    self.view.layoutIfNeeded()
                }
           }
        }
    }
    
    private func OpenCalenderView(timeInterval:Double){
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(timeInterval, animations: {
                if(self.calendarHidden == true){
                    self.calendarHidden = false
                    self.ConstraintCalenderTop.constant = 0
                    self.view.layoutIfNeeded()
                }
            })
        
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                NSThread.sleepForTimeInterval(timeInterval)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.calendarManager.setDate(self.currentSelectDate ?? NSDate())
                    })
                })
        }
    }
    
    private func checkChooseDayOK(date:NSDate) -> Bool{
        if(buttonTag == 110){
            return EndSelectDate.timeIntervalSinceDate(date) >= 0
        }else{
            return date.timeIntervalSinceDate(StartSelectDate) >= 0
        }
    }
    
    @IBAction func ButtonGotoToDay(sender: AnyObject) {
        calendarManager.setDate(NSDate())
    }
    
    @IBAction func ButtonCalenderSureClicked(sender: AnyObject) {
        ButtonEnd.selected = false
        ButtonStart.selected = false
        CloseCalenderView(0.5)
        let startTimeInterval = (StartSelectDate.timeIntervalSince1970 + 28800) - (StartSelectDate.timeIntervalSince1970 + 28800)%86400
        let endTimeInterval = (EndSelectDate.timeIntervalSince1970 + 28800) - (EndSelectDate.timeIntervalSince1970 + 28800)%86400 + 86400
         visibleTask = Tasks.filter{
            $0.finishTime > startTimeInterval && $0.finishTime < endTimeInterval
        }
        self.tableView.reloadData()
    }
    
    @IBAction func ButtonCloseClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ButtonChooseTimeClicked(sender: AnyObject) {
        if(sender.tag == 110){
            ButtonStart.selected = true
            ButtonEnd.selected = false
            buttonTag = 110
        }else{
            buttonTag = 120
            ButtonStart.selected = false
            ButtonEnd.selected = true
        }
        if(calendarHidden == false){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { 
                    self.CloseCalenderView(0.25)
                    NSThread.sleepForTimeInterval(0.25)
                    self.OpenCalenderView(0.25)
                })
        }else{
            OpenCalenderView(0.5)
        }
    }
    
}

extension NewRecordViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleTask.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TaskTableViewCell
        cell.task = self.visibleTask[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        taskDetailViewController.tasking = Tasks[indexPath.row]
        taskDetailViewController.PushViewControllerInViewController(self)
    }
    
}

extension NewRecordViewController:JTCalendarDelegate{
    
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
            if calendarManager.dateHelper.date(NSDate(), isTheSameDayThan: dayView.date){
                dayView.circleView.hidden = true
                dayView.textLabel.textColor = UIColor.DangerColor()
            }else
                if !calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayView.date) {
                    dayView.circleView.hidden = true
                    dayView.textLabel.textColor = UIColor.LowBlackColor()
            }else{
                dayView.circleView.hidden = true
                dayView.textLabel.textColor = UIColor.MidBlackColor()
            }
            if  calendarManager.dateHelper.date(currentSelectDate, isTheSameDayThan: dayView.date){
                dayView.circleView.hidden = false
                dayView.circleView.backgroundColor = UIColor.MainColor()
                dayView.textLabel.textColor = UIColor.whiteColor()
            }
        }
    }
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        if let dayView = dayView as? JTCalendarDayView{
            guard checkChooseDayOK(dayView.date) == true else {return}
            currentSelectDate = dayView.date
            dayView.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
            UIView.transitionWithView(dayView, duration: 0.3, options: UIViewAnimationOptions.CurveEaseIn,  animations: {
                dayView.circleView.transform = CGAffineTransformIdentity
                self.calendarManager.reload()
                }, completion: nil)
            if !self.calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayView.date){
                if calendarContentView.date.compare(dayView.date) == .OrderedAscending{
                    calendarContentView.loadNextPageWithAnimation()
                }else{
                    calendarContentView.loadPreviousPageWithAnimation()
                }
            }

        }
    }
}
