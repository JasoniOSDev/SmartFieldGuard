//
//  TaskTableViewCell.swift
//  智慧田园
//
//  Created by jason on 16/5/21.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import MBProgressHUD
class TaskTableViewCell: UITableViewCell,Reusable {

    @IBOutlet weak var LabelTaskName: UILabel!
    @IBOutlet weak var LabelStyle: UILabel!
    @IBOutlet weak var LabelPeriod: UILabel!
    @IBOutlet weak var ViewFinishTime: UIView!
    @IBOutlet weak var LabelFinishTime: UILabel!
    @IBOutlet weak var ViewTag: UIView!
    @IBOutlet weak var ImgViewTag: UIImageView!
    var taskStatus:TaskStatus = .Finished
    var taskStyle:TaskStyle = .Temporary
    var task:Tasking!{
        didSet{
            if task.taskType == "Everyday"{
                taskStyle = .Normal
                LabelStyle.text = "类型:  " + "日常任务"
            }else{
                taskStyle = .Temporary
                LabelStyle.text = "类型:  " + "临时任务"
            }
            if task.periodNo != ""{
                LabelPeriod.hidden = false
                LabelPeriod.text = "阶段:  " + (task.crop?.propertyDict[task.periodNo] as! String)
            }else{
                LabelPeriod.hidden = true
            }
            LabelTaskName.text = "任务:  " + task.name
            switch taskStatus {
            case .Finished:
                ViewTag.backgroundColor = UIColor.MainColor()
                LabelFinishTime.hidden = false
                ViewFinishTime.hidden = false
                LabelFinishTime.text = task.getFinishTimeStr()
            //设置完成时间
            case .Doing:
                ViewTag.backgroundColor = UIColor.WarnColor()
                LabelFinishTime.hidden = true
                ViewFinishTime.hidden = true
            }
            ImgViewTag.image = UIImage(named: "Task" + self.taskStatus.rawValue + self.taskStyle.rawValue)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
