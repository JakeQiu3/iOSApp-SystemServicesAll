//
//  KCAchievementTableViewController.h
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KCAchievementTableViewController : UITableViewController
@property (strong,nonatomic) NSArray *achievements;//成就
@property (strong,nonatomic) NSArray *achievementDescriptions;//成就描述
@property (strong,nonatomic) NSMutableDictionary *achievementImages;//成就图片
@end
