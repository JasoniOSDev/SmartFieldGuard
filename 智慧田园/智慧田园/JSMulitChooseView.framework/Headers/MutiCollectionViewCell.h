//
//  MutiCollectionViewCell.h
//  MutiTableView
//
//  Created by Jason on 16/7/21.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutiCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *NewContentView;
@property (nonatomic,strong) UIColor* selectedColor;
-(void)setTitle:(NSString*)title
       selected:(_Bool)selected;

-(void)Selected:(BOOL)selected;
@end
