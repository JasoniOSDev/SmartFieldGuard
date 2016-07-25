//
//  MutiTableViewCell.h
//  MutiTableView
//
//  Created by Jason on 16/7/21.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutiTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *NewContentView;

@property (weak, nonatomic) IBOutlet UICollectionView *CollectionView;
-(void)setTitle:(NSString*)title
          items:(NSArray<NSString*>*)items
  selectedArray:(NSMutableDictionary<NSNumber*,NSNumber*>*) selectedArray
    mulitChoose:(BOOL)mulitChoose;

-(void)setTopLineHidden:(BOOL)hidden;

@property (nonatomic,strong) UIColor* selectedColor;
@end
