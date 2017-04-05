//
//  BaseNavigationViewController.swift
//  智慧田园
//
//  Created by jason on 16/5/19.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit

class TYNavigationViewController: UINavigationController {
    
    lazy var newNavigationPopGesture:UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer()
        gesture.addTarget(self, action: #selector(TYNavigationViewController.handlePopGesture(_:)))
        return gesture
    }()
    
    lazy var newNavigationTransition:TYNavigationTransition = {
        return TYNavigationTransition()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName:UIFont.NavigationBarTitleFont(),NSForegroundColorAttributeName:UIColor.NavigationBarTitleColor()]
        self.navigationBar.tintColor = UIColor.MidBlackColor()
        self.view.addGestureRecognizer(self.newNavigationPopGesture)
        self.interactivePopGestureRecognizer?.delegate = nil
        self.delegate = self.newNavigationTransition
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        guard let topVC = self.topViewController else { return .Default  }
        return topVC.preferredStatusBarStyle()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        guard let topVC = self.topViewController else { return false }
        return topVC.prefersStatusBarHidden()
    }
    
    func handlePopGesture(gesture:UIPanGestureRecognizer){
        var progress = gesture.translationInView(gesture.view).x / self.view.width
        progress = min(progress, 1)
        switch gesture.state {
        case .Began:
            if self.childViewControllers.count > 1 {
                self.popViewControllerAnimated(true)
            }
        case .Changed:
            self.newNavigationTransition.drivenInteractiveManager.updateInteractiveTransition(progress)
        case .Ended,.Cancelled:
            if progress > 0.5{
                self.newNavigationTransition.drivenInteractiveManager.finishInteractiveTransition()
            }else {
                self.newNavigationTransition.drivenInteractiveManager.cancelInteractiveTransition()
            }
        default:
            break
        }
    }
}

class TYNavigationTransition:NSObject,UINavigationControllerDelegate{
    var drivenInteractiveManager:UIPercentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
    lazy var animationPopTransition:UIViewControllerAnimatedTransitioning = {
        return TYNavigationPopTransition()
    }()
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.drivenInteractiveManager
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if (operation == .Pop){
            return self.animationPopTransition
        }
        return nil
    }
}

class TYNavigationPopTransition: NSObject,UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.35
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
              let toView = transitionContext.viewForKey(UITransitionContextToViewKey) else {
            return
        }
        let contaierView = transitionContext.containerView()
        let duration = self .transitionDuration(transitionContext)
        contaierView.insertSubview(toView, belowSubview: fromView)
        toView.transform = CGAffineTransformMakeScale(0.98, 0.98)
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut, animations: {
            toView.transform = CGAffineTransformIdentity
            fromView.transform = CGAffineTransformMakeTranslation(fromView.width, 0)
            }) { finish in
                let cancel = transitionContext.transitionWasCancelled()
                transitionContext.completeTransition(!cancel)
                if cancel {
                    toView.removeFromSuperview()
                }else{
                    fromView.removeFromSuperview()
                }
                toView.transform = CGAffineTransformIdentity
                fromView.transform = CGAffineTransformIdentity
        }
    }
}
