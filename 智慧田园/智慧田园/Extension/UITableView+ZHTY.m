//
//  UITableView+ZHTY.m
//  智慧田园
//
//  Created by jason on 2016/9/4.
//  Copyright © 2016年 jason. All rights reserved.
//

#import "UITableView+ZHTY.h"
#import "objc/runtime.h"
@implementation NSObject (ZHTY)

+ (void)exchangeInstanceMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getInstanceMethod(self, method1), class_getInstanceMethod(self, method2));
}
    
+ (void)exchangeClassMethod1:(SEL)method1 method2:(SEL)method2
{
    method_exchangeImplementations(class_getClassMethod(self, method1), class_getClassMethod(self, method2));
}

@end

@implementation UIImage (Screenshot)

+ (UIImage *)screenshot
{
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            CGContextSaveGState(context);
            
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            
            CGContextConcatCTM(context, [window transform]);
            
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            [[window layer] renderInContext:context];
            
            CGContextRestoreGState(context);
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end

@implementation UITableView (ZHTY)

+ (void)load{
    [self exchangeInstanceMethod1:@selector(touchesBegan:withEvent:) method2:@selector(ZHTYTouchesBegan:withEvent:)];
}

- (void)ZHTYTouchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self ZHTYTouchesBegan:touches withEvent:event];
    [self.nextResponder touchesBegan:touches withEvent:event];
}

@end

@implementation UIScrollView (ZHTY)

+ (void)load{
    [self exchangeInstanceMethod1:@selector(touchesBegan:withEvent:) method2:@selector(ZHTYTouchesBegan:withEvent:)];
    [self exchangeInstanceMethod1:@selector(touchesMoved:withEvent:) method2:@selector(ZHTYTouchesMoved:withEvent:)];
    [self exchangeInstanceMethod1:@selector(touchesEnded:withEvent:) method2:@selector(ZHTYTouchesEnded:withEvent:)];
}

- (void)ZHTYTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
    
}
-(void)ZHTYTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}

- (void)ZHTYTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}

@end

@implementation NSData (ZHTY)

-(int)intValue{
    Byte byteArray[4];
    [self getBytes:byteArray length:4];
    int newLen = 0;
    for (int i = 0;i<4;i++){
        newLen = newLen*256 + byteArray[i];
    }
    return  newLen;
}
@end
