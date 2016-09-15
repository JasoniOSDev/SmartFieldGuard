//
//  ExpertClassChooseController.swift
//  智慧田园
//
//  Created by Jason on 16/7/22.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class ExpertClassChooseController: TYViewController,UITableViewDataSource,UITableViewDelegate {

    var selectBlock:((cropsID:String,cropsName:String,own:Bool)->Void)!
    var tableView = UITableView()
    var cropClasses = [CropsClass]()
    var crops = [Int:[LocalCrops]]()
    var selected = [Int:Bool]()
    var mySelf = ["自己","所有"]
    var tableHeadView = [ExpertClassChooseTableHeadView]()
    var cellHeight = [Int:CGFloat]()
    var cellWidth = [Int:[Int:CGFloat]]()
    var cropsID = ""
    var cropsName = ""
    var preSelect = 0
    var mySelfSelect = "自己"
    lazy var tableViewCell:ExpertClassChooseTableViewCell = {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(ExpertClassChooseTableViewCell.reuseIdentifier) as! ExpertClassChooseTableViewCell
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        cell.frame.size.width = self.view.frame.width
        return cell
    }()
    lazy var collectionCell:ExpertClassChooseCollectionViewCell = {
        return ExpertClassChooseCollectionViewCell(frame: CGRectMake(0, 0, 400, 40))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        LoadCropsClass()
    }
    
    private func prepareUI(){
        self.title = "分类选择"
        tableViewConfigure()
        navigationItemConfigure()
    }
    
    private func tableHeadViewConfigure(){
        let view = ExpertClassChooseTableHeadView()
        view.setTitle("查看内容")
        view.tag = 0
        view.restorationIdentifier = "ExpertClassChooseTableHeadView"
        view.clickAction = {
            [weak self] index in
            self?.tableViewdidSelectHeadAtIndex(index)
        }
        tableHeadView.append(view)
        for x in cropClasses.enumerate(){
            let view = ExpertClassChooseTableHeadView()
            view.setTitle(x.element.name)
            view.tag = x.index + 1
            view.restorationIdentifier = "ExpertClassChooseTableHeadView"
            view.clickAction = {
                [weak self] index in
                self?.tableViewdidSelectHeadAtIndex(index)
            }
            tableHeadView.append(view)
        }
    }
    
    private func tableViewConfigure(){
        tableView.registerReusableCell(ExpertClassChooseTableViewCell)
        tableView.clearOtherLine()
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(self.view)
        }
    }
    
    private func LoadCropsClass(){
        NetWorkManager.GetCropsClass {  cropsClassList in
            self.cropClasses = cropsClassList
            self.tableHeadViewConfigure()
            self.tableView.reloadData()
        }
    }
    
    private func LoadCropsListForIndex(index:Int){
        if crops[index] == nil {
            NetWorkManager.GetCropsList(self.cropClasses[index].id, callback: {  cropsList in
                    self.crops[index] = cropsList
                    self.tableView.reloadSections(NSIndexSet(index: index+1), withRowAnimation: .Automatic)
            })
        }else{
            self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
        }
    }

    private func navigationItemConfigure(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .Plain, target: self, action: #selector(self.closeCurrtenViewNoCompletion))
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .Plain, target: self, action: #selector(self.selectAction))
    }
    
    func selectAction(){
        self.closeCurrentView {
            self.selectBlock(cropsID: self.cropsID,cropsName: self.cropsName,own:self.mySelfSelect == "自己")
        }
    }

}
//tableView'delegate dataSourece
extension ExpertClassChooseController{
    
    private func tableViewdidSelectHeadAtIndex(index:Int){
        if let result = selected[index]{
            selected[index] = !result
        }else{
            selected[index] = true
        }
        self.tableView.reloadSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
    }
    
    private func cellHeightForIndex(index:Int) -> CGFloat{
        if index > 0 && (crops[index-1] == nil || crops[index-1]!.count == 0){
            return 0
        }
        if cellHeight[index] == nil {
            tableViewCell.index = index
            tableViewCell.layoutIfNeeded()
            tableViewCell.collectionView.reloadData()
            cellHeight[index] = tableViewCell.collectionView.contentSize.height + 20
        }
        return cellHeight[index]!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return cropClasses.count + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let result = selected[section] where result == true{
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as ExpertClassChooseTableViewCell
        cell.selectionStyle = .None
        cell.index = indexPath.section
        cell.collectionView.delegate = self
        cell.collectionView.dataSource = self
        cell.collectionView.reloadData()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cellHeightForIndex(indexPath.section)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableHeadView[section]
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
     }
    
}

extension ExpertClassChooseController:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    private func cellWidthForIndexAndSection(section:Int,index:Int)->CGFloat{
        if cellWidth[section] == nil{
            cellWidth[section] = [Int:CGFloat]()
        }
        if section != 0 {
            if cellWidth[section]![index] == nil{
                collectionCell.title = crops[section - 1]![index].name
                collectionCell.layoutIfNeeded()
                cellWidth[section]![index] = collectionCell.LabelTitle.frame.width + 20
            }
        }else{
            if cellWidth[section]![index] == nil{
                collectionCell.title = mySelf[index]
                collectionCell.layoutIfNeeded()
                cellWidth[section]![index] = collectionCell.LabelTitle.frame.width + 20
            }
        }
        return cellWidth[section]![index]!
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return mySelf.count
        }
        
        if let result = selected[collectionView.tag] where result == true {
            if crops[collectionView.tag - 1] == nil{
                LoadCropsListForIndex(collectionView.tag - 1)
                return 0
            }
            return crops[collectionView.tag - 1] == nil ? 0 : (crops[collectionView.tag - 1]?.count)!
        }
        
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ExpertClassChooseCollectionViewCell
        if collectionView.tag == 0 {
            cell.title = mySelf[indexPath.row]
        }else{
            cell.title = crops[collectionView.tag - 1]![indexPath.row].name
        }
        if cell.title == mySelfSelect || cell.title == cropsName{
            cell.Select(true)
        }else{
            cell.Select(false)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSizeMake(cellWidthForIndexAndSection(collectionView.tag,index:indexPath.row),40)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.tag != 0 {
            let selectCrops = crops[collectionView.tag - 1]!
            if cropsID == selectCrops[indexPath.row].id{
                cropsID = ""
                cropsName = ""
                tableView.reloadSections(NSIndexSet(index: self.preSelect), withRowAnimation: .Automatic)
                return
            }
            cropsID = selectCrops[indexPath.row].id
            cropsName = selectCrops[indexPath.row].name
            tableView.reloadSections(NSIndexSet(index: self.preSelect), withRowAnimation: .Automatic)
            tableView.reloadSections(NSIndexSet(index: collectionView.tag), withRowAnimation: .Automatic)
            self.preSelect = collectionView.tag
        }else{
            mySelfSelect = mySelf[indexPath.row]
            tableView.reloadSections(NSIndexSet(index:0), withRowAnimation: .Automatic)
        }
    }
    
    
    
}
