//
//  TYRefreshNavHeader.swift
//  智慧田园
//
//  Created by jason on 2016/9/14.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

enum RefreshState{
    case End
    case Refreshing
    case Pulling
}

enum PresentStyle{
    case Position
    case Alpha
}

struct TYRefreshNavConfig{
    var viewHeight:CGFloat = 80
    var refreshPosition:CGFloat = 20//刷新点
    var willRefreshPosition:CGFloat = 10//即将刷新点
    var titleDict:[RefreshState:String] = [.End:"下拉刷新数据",.Refreshing:"正在刷新数据",.Pulling:"松开以即可刷新"]
    var presentStyle:PresentStyle = .Alpha
    func getStateTitle(state:RefreshState) -> String{
        return titleDict[state]!
    }
    
}

class TYRefreshNavView: UIView {
    
    var state:RefreshState = RefreshState.End{
        willSet{
            titleLabel.text = config.getStateTitle(newValue)
            loadingView.sizeToFit()
            titleLabel.sizeToFit()
            titleLabel.center = CGPointMake(self.frame.width / 2 + loadingView.frame.width / 2 + 2.5, self.frame.height / 2)
            loadingView.center = CGPointMake(titleLabel.frame.origin.x - loadingView.frame.width / 2 - 5, titleLabel.center.y)
            switch newValue {
            case .End:
                loadingView.hidden = true
            case .Pulling :
                loadingView.hidden = false
            case .Refreshing:
                loadingView.hidden = false
                loadingView.startAnimating()
                executeBlock()
            }
            
        }
    }
    var config:TYRefreshNavConfig = TYRefreshNavConfig()
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.text = self.config.getStateTitle(.End)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.systemFontOfSize(14)
        return label
    }()
    lazy var loadingView:UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityView.hidesWhenStopped = true
        return activityView
    }()
    var executeBlock:(()->Void)!
    
    func changePosition(change:CGFloat,end:Bool = false){
        guard self.state != .Refreshing else {return}
        if self.state == .Pulling && end {
            self.beginRefreshing()
            return
        }
        if config.presentStyle == .Position{
            self.frame.origin.y = change > config.refreshPosition ? config.refreshPosition:change
        }else{
            let percent = change / config.refreshPosition
            self.alpha = percent > 1 ? 1 : percent
        }
        
        if(change >= config.refreshPosition && self.state == .End){
            self.state = .Pulling
        }else{
            if(self.state == .Pulling && change < config.willRefreshPosition){
                self.state = .End
            }
        }
    }
    
    func beginRefreshing() {
        self.state = .Refreshing
        if config.presentStyle == .Position {
            self.frame.origin.y = 20
        }else{
            UIView.animateWithDuration(0.4, animations: { 
                self.alpha = 1
            })
        }
    }
    
    func endRefreshing() {
        self.state = .End
        if config.presentStyle == .Position {
            self.frame.origin.y = -54
        }else{
            UIView.animateWithDuration(0.4, animations: {
                self.alpha = 0
            })
        }
    }
    
    
    class func createWithExecuteBlock(block:()->Void) -> TYRefreshNavView{
        let view = TYRefreshNavView()
        view.backgroundColor = UIColor.clearColor()
        view.executeBlock = block
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(titleLabel)
        self.addSubview(loadingView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let view = superview{
            let width = view.frame.width
            self.frame = CGRectMake(0, -config.viewHeight, width, config.viewHeight)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if config.presentStyle == .Position{
            self.frame.origin = CGPointMake(0, -config.viewHeight)
        }else{
            self.frame.origin = CGPointMake(0,0)
        }
    }
}
