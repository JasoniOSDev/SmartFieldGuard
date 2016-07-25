//
//  MutiTableTableViewController.h
//  MutiTableView
//
//  Created by Jason on 16/7/21.
//  Copyright © 2016年 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MutiTableTableViewController : UITableViewController

-(void)setItems:(NSArray<NSArray<NSString*>*>*)allItems
       allTitle:(NSArray<NSString*>*)allTitle
allSelectedArray:(NSArray<NSMutableDictionary<NSNumber*,NSNumber*>*>*) allSelectedArray
  allMutiChoose:(NSArray<NSNumber*>*) allMutiChoose;
@property (nonatomic,strong) UIColor* selectedColor;

@end
