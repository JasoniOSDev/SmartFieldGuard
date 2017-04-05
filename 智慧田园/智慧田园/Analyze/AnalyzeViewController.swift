//
//  AnalyzeViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/29.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class AnalyzeViewController: TYViewController {

    @IBOutlet weak var StackViewButtons: UIStackView!
    @IBOutlet weak var ButtonGrowth: UIButton!
    @IBOutlet weak var ButtonFertilize: UIButton!
    @IBOutlet weak var ButtonAir: UIButton!
    @IBOutlet weak var ButtonSun: UIButton!
    @IBOutlet weak var ButtonSoil: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var scrollViewPageButton: UIScrollView!
    var crop:Crops!
    var field:Farmland!
    lazy var lastButton:UIButton = {
        return self.ButtonGrowth
    }()
    
    lazy var growthViewController:GrowthViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("GrowthViewController") as! GrowthViewController
        vc.crop = self.crop
        return vc
    }()
    
    lazy var airViewController:AirViewController = {
        let vc =  AirViewController()
        vc.crop = self.crop
        vc.field = self.field
        return vc
    }()
    
    lazy var soilViewController:SoilViewController = {
        let vc =  SoilViewController()
        vc.crop = self.crop
        vc.field = self.field
        return vc
    }()
    
    lazy var sunViewController:SunViewController = {
        let vc =  SunViewController()
        vc.crop = self.crop
        vc.field = self.field
        return vc
    }()
    
    lazy var fertilizeViewController:FertilizeViewController = {
        let story = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc = story.instantiateViewControllerWithIdentifier("FertilizeViewController") as! FertilizeViewController
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = UIColor.MidBlackColor()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.subviews[0].alpha = 1
    }
    
    private func prepareUI(){
        collectionViewConfigure()
        self.title = "分析"
    }
    
    private func collectionViewConfigure(){
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(self.view.frame.width, self.view.frame.height - 40)
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.pagingEnabled = true
        collectionView.collectionViewLayout = layout
        collectionView.registerClass(AnalyzeCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
    }

    func changeButtonSelected(sender:UIButton){
        lastButton.selected = false
        lastButton = sender
        lastButton.selected = true
        let BtnpositionX = lastButton.frame.origin.x + 60
        let centerX = ScreenWidth / 2
        var offSetx = BtnpositionX - centerX < 0 ? 0 : BtnpositionX - centerX
        if offSetx > scrollViewPageButton.contentSize.width - ScreenWidth{
            offSetx =  scrollViewPageButton.contentSize.width - ScreenWidth
        }
        UIView.animateWithDuration(0.5) { 
            self.scrollViewPageButton.contentOffset.x = offSetx
        }
    }
    
    @IBAction func PageButtonClicked(sender: UIButton) {
        changeButtonSelected(sender)
        collectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: sender.tag - 101,inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }
    
}

extension AnalyzeViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let offSetx = Int(scrollView.contentOffset.x/ScreenWidth)
        let btn = StackViewButtons.viewWithTag(offSetx + 101) as! UIButton
        changeButtonSelected(btn)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! AnalyzeCollectionViewCell
        cell.view?.removeFromSuperview()
        
        switch indexPath.row {
        case 0:
            cell.view = growthViewController.view
        case 1:
            cell.view = airViewController.view
        case 3:
            cell.view = soilViewController.view
        case 2:
            cell.view = sunViewController.view
        default:
            break
        }
        return cell
    }
}
