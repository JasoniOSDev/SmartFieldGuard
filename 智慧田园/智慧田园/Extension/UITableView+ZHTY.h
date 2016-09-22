//
//  UITableView+ZHTY.h
//  智慧田园
//
//  Created by jason on 2016/9/4.
//  Copyright © 2016年 jason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh/MJRefresh.h>
@interface UITableView (ZHTY)

@end

@interface UIImage (Screenshot)

+ (UIImage *)screenshot;

@end

@interface NSData (ZHTY)

-(int)intValue;

@end

@interface UIImage (BinaryCode)

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size;

@end
