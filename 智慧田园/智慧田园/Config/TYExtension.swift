//
//  TYExtension.swift
//  智慧田园
//
//  Created by jason on 16/5/20.
//  Copyright © 2016年 jason. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices
import SystemConfiguration
import MBProgressHUD
extension UIDevice{
     var SSID:String?{
        get{
            if let interfaces:NSArray = CNCopySupportedInterfaces() {
                if let interfaceName:CFString = interfaces[0] as! CFString {
                    if let dict:NSDictionary = CNCopyCurrentNetworkInfo(interfaceName){
                        return dict.objectForKey("SSID") as! String
                    }
                    return nil
                }
                
                return nil
            }
            return nil
        }
    }
}

extension String{
    
    func imageLowQualityURL() -> String{
        var parts = self.componentsSeparatedByString(".")
        let len = parts.count
        parts[len - 2] += "_mini"
        return parts.reduce("", combine: { (pre, now) -> String in
            return pre + (pre == "" ? "" : ".") + now
        })
    }
}

extension MBProgressHUD{
    
    class func show(text:String,icon:String,  view:UIView?){
        var toView = view
        if toView == nil{
            toView = UIApplication.sharedApplication().windows.last!
        }
        let hud = MBProgressHUD.showHUDAddedTo(toView, animated: true)
        hud.labelText = text
        hud.customView = UIImageView(image: UIImage(named: "MBProgressHUD.bundle/\(icon)"))
        hud.mode = .CustomView
        hud.removeFromSuperViewOnHide = true
        hud.hide(true, afterDelay: 0.7)
    }
    
    class func showSuccess(success:String, toView:UIView?){
        self.show(success, icon: "success.png", view: toView)
    }
    
    class func showError(error:String, toView:UIView?){
        self.show(error, icon: "error.png", view: toView)
    }
    
    class func showMessage(msg:String?,view:UIView?) -> MBProgressHUD{
        var toView = view
        if toView == nil{
            toView = UIApplication.sharedApplication().windows.last!
        }
        let hud = MBProgressHUD.showHUDAddedTo(toView, animated: true)
        hud.removeFromSuperViewOnHide = true
        hud.dimBackground = false
        if let MSG = msg {
            hud.labelText = MSG
        }
        return hud
    }
}

protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension Reusable {
    static var reuseIdentifier: String { return String(Self) }
    static var nib: UINib? { return UINib(nibName: String(Self), bundle: NSBundle.mainBundle())}
}

extension UIView{
    func startLoading(Msg:String?){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        var hud:MBProgressHUD! = self.subviews.filter({$0.tag == 999}).last as? MBProgressHUD
        if(hud == nil){
            hud = MBProgressHUD.showHUDAddedTo(self, animated: true)
            hud.removeFromSuperViewOnHide = false
            hud.activityIndicatorColor = UIColor.LowBlackColor()
            hud.opacity = 0
            hud.tag = 999
            if let text = Msg{
                hud.detailsLabelText = text
                hud.detailsLabelColor = UIColor.LowBlackColor()
                hud.detailsLabelFont = UIFont(name: LightLanTingHeiFontName, size: 12)!
            }
        }
        hud.hidden = false
    }
    
    func endLoading(){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let hud:MBProgressHUD! = self.subviews.filter({$0.tag == 999}).last as? MBProgressHUD
        if let hud = hud{
            hud.hidden = true
        }
    }
}
extension UIImage{

    func resizeToSize(size: CGSize, withTransform transform: CGAffineTransform, drawTransposed: Bool, interpolationQuality: CGInterpolationQuality) -> UIImage? {
        
        let newRect = CGRectIntegral(CGRect(origin: CGPointZero, size: size))
        let transposedRect = CGRect(origin: CGPointZero, size: CGSize(width: size.height, height: size.width))
        
        let bitmapContext = CGBitmapContextCreate(nil, Int(newRect.width), Int(newRect.height), CGImageGetBitsPerComponent(CGImage!), 0, CGImageGetColorSpace(CGImage!)!, CGImageGetBitmapInfo(CGImage!).rawValue)
        
        CGContextConcatCTM(bitmapContext!, transform)
        
        CGContextSetInterpolationQuality(bitmapContext!, interpolationQuality)
        
        CGContextDrawImage(bitmapContext!, drawTransposed ? transposedRect : newRect, CGImage!)
        
        if let newCGImage = CGBitmapContextCreateImage(bitmapContext!) {
            let newImage = UIImage(CGImage: newCGImage)
            return newImage
        }
        
        return nil
    }

    func transformForOrientationWithSize(size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity
        
        switch imageOrientation {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            
        default:
            break
        }
        
        switch imageOrientation {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, size.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, size.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            
        default:
            break
        }
        
        return transform
    }

    
    func resizeToSize(size: CGSize, withInterpolationQuality interpolationQuality: CGInterpolationQuality) -> UIImage? {
        
        let drawTransposed: Bool
        
        switch imageOrientation {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        
        return resizeToSize(size, withTransform: transformForOrientationWithSize(size), drawTransposed: drawTransposed, interpolationQuality: interpolationQuality)
    }
    
}

extension UITableView {
    
    func clearOtherLine(){
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        self.tableFooterView = view
    }
    
    func registerReusableCell<T: UITableViewCell where T: Reusable>(_: T.Type) {
        if let nib = T.nib {
            self.registerNib(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.registerClass(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func registerReusableCellInClass<T: UITableViewCell where T: Reusable>(_: T.Type) {
        
        self.registerClass(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    
    func dequeueReusableCell<T: UITableViewCell where T: Reusable>(indexPath indexPath: NSIndexPath) -> T {
        return self.dequeueReusableCellWithIdentifier(T.reuseIdentifier, forIndexPath: indexPath) as! T
    }
    
    func registerReusableHeaderFooterView<T: UITableViewHeaderFooterView where T: Reusable>(_: T.Type) {
        if let nib = T.nib {
            self.registerNib(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        } else {
            self.registerClass(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView where T: Reusable>() -> T? {
        return self.dequeueReusableHeaderFooterViewWithIdentifier(T.reuseIdentifier) as! T?
    }
}

extension UICollectionView{
    func registerReusableCell<T: UICollectionViewCell where T: Reusable>(_: T.Type) {
        if let nib = T.nib {
            self.registerNib(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            self.registerClass(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
}

extension CALayer{
    
    func makeCornerRadius(radius:CGFloat){
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.CGPath
        mask = maskLayer
    }
}
extension UIImage{
    
    func kt_drawRectWithRoundedCorner(radius radius: CGFloat, _ sizetoFit: CGSize) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: sizetoFit)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.mainScreen().scale)
        CGContextAddPath(UIGraphicsGetCurrentContext()!,
                         UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.AllCorners,
                            cornerRadii: CGSize(width: radius, height: radius)).CGPath)
        CGContextClip(UIGraphicsGetCurrentContext()!)
        
        self.drawInRect(rect)
        CGContextDrawPath(UIGraphicsGetCurrentContext()!, .FillStroke)
        let output = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return output!
    }
    
}

extension UIImageView {
    func kt_addCorner(radius radius: CGFloat) {
        self.image = self.image?.kt_drawRectWithRoundedCorner(radius: radius, self.bounds.size)
    }
}


