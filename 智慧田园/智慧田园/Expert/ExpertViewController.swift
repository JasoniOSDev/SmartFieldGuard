//
//  ExpertViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import RealmSwift
import MBProgressHUD
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
    var cellHeight = [String:CGFloat]()
    var cropsID = ""
    var cropsName = ""
    var own:Bool = true//查看的内容，true表示自己，false表示所有
    lazy var experClassChooseViewController:ExpertClassChooseController = {
        let vc = ExpertClassChooseController()
        vc.selectBlock = {
           [weak self] id,name,own in
            self?.cropsID = id
            self?.cropsName = name
            self?.own = own
            self?.LoadData()
            self?.checkNewTopic()
            if name == ""{
                self?.title = "专家咨询区"
            }else{
                self?.title = "专家咨询区(\(name))"
            }
        }
        return vc
    }()
    var upLoading = false
    lazy var newFormViewController:PushNewForumViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("PushNewForumViewController") as! PushNewForumViewController
        vc.style = .Expert
        vc.finishBlock = {
            [weak self] tg in
            if let sSelf = self where tg{
                sSelf.uploadingTagView.hidden = false
                sSelf.uploadingTagView.startAnimating()
                sSelf.upLoading = true
            }
        }
        vc.completeBlock = {
            [weak self] tag in
            if let sSelf = self {
                sSelf.upLoading = false
                sSelf.uploadingTagView.hidden = true
                sSelf.uploadingTagView.stopAnimating()
                if tag {
                    MBProgressHUD.showSuccess("发送成功", toView: nil)
                }else{
                    sSelf.pushNewForumViewController(false)
                    MBProgressHUD.showError("发送失败", toView: nil)
                }
            }
        }
        return vc
    }()
    lazy var uploadingTagView:UIImageView = {
        let imageView = UIImageView(frame: CGRectMake(ScreenWidth - 40, 10, 20, 27))
        let array = [UIImage(named: "Expert_UpLoading_1")!,UIImage(named: "Expert_UpLoading_2")!,UIImage(named: "Expert_UpLoading_3")!,UIImage(named: "Expert_UpLoading_4")!]
        imageView.animationImages = array
        imageView.animationDuration = 0.5
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        TYUserDefaults.userID.bindAndFireListener("ExpertViewController") { _ in
            //用来粗略处理切换账号的情况
            if TYUserDefaults.userID.value != nil{
                self.LoadData()
                self.checkNewTopic()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.addSubview(uploadingTagView)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        setMenuHidden(true)
        uploadingTagView.removeFromSuperview()
        uploadingTagView.stopAnimating()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ExpertAndMeViewController{
            vc.theme = self.ExpertThemes![selectIndex]
        }
    }

    private func LoadData(){
        //用于获取当前账号对应的话题数据
        self.ExpertThemes = ModelManager.getObjects(ExpertTheme).sorted("lastReply", ascending: false)
        if self.cropsID != ""{
            self.ExpertThemes = self.ExpertThemes?.filter("self.classifyID = %@", self.cropsID)
        }
        if own == true || TYUserDefaults.role.value == RoleNormalMemeber{
            self.ExpertThemes = self.ExpertThemes?.filter("self.userID = %@", TYUserDefaults.userID.value!)
        }

        self.token = self.ExpertThemes?.addNotificationBlock({
            [weak self] change in
            switch change{
            case .Initial(_):self?.tableView.reloadData()
            case .Update(_, deletions: let deletions, insertions: let news, modifications: let modify):
                self?.cellHeight.removeAll()
                if modify.count > 0 {
                    //有数据发生改变
                    self?.tableView.reloadRowsAtIndexPaths(modify.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
                }
                if news.count > 0 {
                    //有新的数据增加
                    self?.tableView.insertRowsAtIndexPaths(news.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .Automatic)
                }
                if deletions.count > 0{
                    //有数据被删除
                    self?.tableView.deleteRowsAtIndexPaths(deletions.map{NSIndexPath(forRow: $0, inSection: 0)}, withRowAnimation: .None)
                }
            case .Error(_):break
            }
        })
        self.tableView.reloadData()
    }
    
    private func checkNewTopic(){
        //检查是否有新增的话题，在别的手机上发送的
        NetWorkManager.CheckNewExperTopic(own, type: "", callback: { 
            self.ExpertThemes?.forEach({ (x) in
                NetWorkManager.updateTopicReply(x)
            })
        })
    }
    
    private func prepareUI(){
        tableViewConfigure()
        if cropsName != ""{
            self.title = "专家咨询区(\(cropsName))"
        }else{
            self.title = "专家咨询区"
        }
        //self.view.addSubview(fpsLabel)
    }
    
    private func tableViewConfigure(){
        tableView.registerReusableCell(AskExpertTableViewCell)
        tableView.separatorStyle = .None
        tableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView.contentOffset = CGPointMake(0, -10)
        tableView.backgroundColor = UIColor.BackgroundColor()
        tableView.registerReusableCell(AskExpertTableViewCell)
        tableView.clearOtherLine()
    }
    
    private func  cellHeightForIndex(index:Int) -> CGFloat{
        let cell = self.tableView.dequeueReusableCellWithIdentifier(AskExpertTableViewCell.reuseIdentifier) as! AskExpertTableViewCell
        let id = ExpertThemes![index].ID
        if self.cellHeight[id] == nil {
            cell.theme = self.ExpertThemes![index]
            cell.layoutIfNeeded()
            self.cellHeight[id] = cell.newContentView.frame.height + 5
        }
        return cellHeight[id]!
    }
    
    private func setMenuHidden(hidden:Bool){
        guard ButtonMenu.selected == hidden else {return}
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
    
    private func pushNewForumViewController(clear:Bool){
        if upLoading {
            MBProgressHUD.showError("上次内容正在发送，请稍后再发送", toView: nil)
            return
        }
        if cropsID == ""{
            MBProgressHUD.showError("请选择分类后再继续", toView: nil)
            return
        }
        if clear == true{
            newFormViewController.clearContent()
        }
        newFormViewController.cropsID = cropsID
        newFormViewController.cropsName = cropsName
        self.presentViewController(TYNavigationViewController(rootViewController: self.newFormViewController), animated: true, completion: nil)
    }
    
    class func PushExpertViewController(){
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("ExpertViewController") as! ExpertViewController
        vc.own = false
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(TYNavigationViewController(rootViewController: vc), animated: true, completion: nil)
    }

    @IBAction func ButtonAddClicked() {
        pushNewForumViewController(true)
    }
    
    @IBAction func LeftButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func ButtonMenuClicked(sender: AnyObject) {
        setMenuHidden(ButtonMenu.selected)
    }
    
    @IBAction func ButtonClassClicked(sender: AnyObject) {
        experClassChooseViewController.cropsID = cropsID
        experClassChooseViewController.cropsName = cropsName
        experClassChooseViewController.mySelfSelect = own ? "自己":"所有"
        self.presentViewController(TYNavigationViewController(rootViewController: experClassChooseViewController), animated: true,completion: nil)
    }
    
    deinit {
        TYUserDefaults.userID.removeListenerWithName("ExpertViewController")
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
        cell.theme = self.ExpertThemes![indexPath.row]
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
        setMenuHidden(true)
        var y = scrollView.panGestureRecognizer.velocityInView(self.view).y
        y = y < 0 ? -y : y
        if y < 20 {
            ButtonMenu.alpha = 1
            ButtonMenu.userInteractionEnabled = true
        }else{
            ButtonMenu.alpha = 0.25
            ButtonMenu.userInteractionEnabled = false
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        ButtonMenu.alpha = 1
        ButtonMenu.userInteractionEnabled = true
    }
}
