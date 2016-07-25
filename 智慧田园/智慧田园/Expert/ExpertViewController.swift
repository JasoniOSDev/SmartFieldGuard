//
//  ExpertViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import RealmSwift
class ExpertViewController: TYViewController {

    @IBOutlet weak var ConstraintButtonAddBottom: NSLayoutConstraint!
    @IBOutlet weak var ConstraintButtonClassRight: NSLayoutConstraint!
    @IBOutlet weak var ButtonAdd: UIButton!
    @IBOutlet weak var ButtonClass: UIButton!
    @IBOutlet weak var ButtonMenu: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var ExpertThemes:Results<ExpertTheme>?
    var selectIndex = -1
    var token: NotificationToken!
    var cellHeight = [Int:CGFloat]()
    var cropsID:String?{
        didSet{
            self.cropsIDs = [cropsID!]
        }
    }
    var cropsName:String?{
        didSet{
            self.cropsNames = [cropsName!]
        }
    }
    var cropsIDs = [String]()
    var cropsNames = [String]()
    var check:Bool!//查看的内容，true表示自己，false表示所有
    lazy var experViewController:ExpertClassChooseController = {
        let vc = ExpertClassChooseController()
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        prepareUI()
        TYUserDefaults.userID.bindAndFireListener("ExpertViewController") { [weak self] _ in
            //用来粗略处理切换账号的情况
            self?.LoadData()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        setMenuHidden(true)
    }

    private func LoadData(){
        switch TYUserDefaults.role.value {
        case RoleNormalMemeber:
            self.ExpertThemes = ModelManager.getObjects(ExpertTheme).filter("self.userID = %@", TYUserDefaults.userID.value!).sorted("timeInterval", ascending: true)
            self.token = self.ExpertThemes!.addNotificationBlock({[weak self] change in
                switch change{
                case .Initial(_):self?.tableView.reloadData()
                case .Update(_, deletions: _, insertions: let news, modifications: let modify): 
                    if modify.count > 0 {
                    self?.tableView.reloadRowsAtIndexPaths(modify.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
                    }
                    if news.count > 0 {
                self?.tableView.insertRowsAtIndexPaths(news.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
                    }
                self?.cellHeight.removeAll()
                case .Error(_):break
                }
                })
        case RoleExpert:
            self.ExpertThemes = ModelManager.getObjects(ExpertTheme).sorted("timeInterval", ascending: true)
            self.token = self.ExpertThemes!.addNotificationBlock({[weak self] change in
                switch change{
                case .Initial(_):self?.tableView.reloadData()
                case .Update(_, deletions: _, insertions: let news, modifications: let modify): break
                self?.tableView.reloadRowsAtIndexPaths(modify.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
                self?.tableView.insertRowsAtIndexPaths(news.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
                self?.cellHeight.removeAll()
                case .Error(_):break
                }
                })
        default:
            break
        }
        self.tableView.reloadData()
        
    }
    
    func prepareUI(){
        tableViewConfigure()
        self.title = "专家咨询区"
    }
    
    func tableViewConfigure(){
        tableView.registerReusableCell(AskExpertTableViewCell)
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView.contentOffset = CGPointMake(0, -10)
        tableView.backgroundColor = UIColor.BackgroundColor()
        tableView.registerReusableCell(AskExpertTableViewCell)
        tableView.clearOtherLine()
    }
    
    private func cellHeightForIndex(index:Int) -> CGFloat{
        let cell = self.tableView.dequeueReusableCellWithIdentifier(AskExpertTableViewCell.reuseIdentifier) as! AskExpertTableViewCell
        if self.cellHeight[index] == nil {
            cell.theme = self.ExpertThemes![index]
            cell.layoutIfNeeded()
            self.cellHeight[index] = cell.newContentView.frame.height + 5
        }
        return cellHeight[index]!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? TYNavigationViewController{
            if let vc2 = vc.visibleViewController as? PushNewForumViewController{
                vc2.cropsID = self.cropsIDs.first
                vc2.cropsName = self.cropsNames.first
                vc2.style = .Expert
            }
        }
        if let vc = segue.destinationViewController as? ExpertAndMeViewController{
            vc.theme = self.ExpertThemes![selectIndex]
        }
    }
    
    @IBAction func LeftButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ButtonMenuClicked(sender: AnyObject) {
        setMenuHidden(ButtonMenu.selected)
    }
    
    private func setMenuHidden(hidden:Bool){
        let constant:CGFloat = ButtonMenu.selected == false ? 50:-50
        if hidden == false{
            ButtonAdd.hidden = hidden
            ButtonClass.hidden = hidden
        }
        UIView.animateWithDuration(0.3, animations: {
            self.ConstraintButtonAddBottom.constant = constant
            self.ConstraintButtonClassRight.constant = constant
            self.ButtonMenu.selected = !hidden
            self.view.layoutIfNeeded()
        }) { (_) in
            self.ButtonAdd.hidden = hidden
            self.ButtonClass.hidden = hidden
        }
    }
    
    @IBAction func ButtonClassClicked(sender: AnyObject) {
        self.presentViewController(TYNavigationViewController(rootViewController: experViewController), animated: true,completion: nil)
    }
    
    class func PushExpertViewController(){
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("ExpertViewController") as! ExpertViewController
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(TYNavigationViewController(rootViewController: vc), animated: true, completion: nil)
    }

}

extension ExpertViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ExpertThemes == nil ? 0 : self.ExpertThemes!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AskExpertTableViewCell
        cell.theme = self .ExpertThemes![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeightForIndex(indexPath.row)
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectIndex = indexPath.row
        self.performSegueWithIdentifier("showDetail", sender: nil)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if ButtonMenu.selected == true{
            setMenuHidden(true)
        }
    }
}
