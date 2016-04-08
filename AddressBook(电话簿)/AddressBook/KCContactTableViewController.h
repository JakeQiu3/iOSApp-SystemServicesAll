//
//  KCTableViewController.h
//  AddressBook
//
//  Created by qsy on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  定义一个协议作为代理
 */
@protocol KCContactDelegate

//新增或修改联系人
-(void)editPersonWithFirstName:(NSString *)firstName lastName:(NSString *)lastName workNumber:(NSString *)workNumber;
//取消修改或新增
-(void)cancelEdit;

@end

@interface KCContactTableViewController : UITableViewController


@end
