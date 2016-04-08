//
//  KCSettingTableViewController.m
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "KCSettingTableViewController.h"
#define kSettingAutoSave @"com.cmjstudio.kctest.settings.autosave"

@interface KCSettingTableViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *autoSaveSetting;

@end

@implementation KCSettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - UI事件
- (IBAction)autoSaveClick:(UISwitch *)sender {
    [self setSetting:sender.on];
}

#pragma mark - 私有方法
-(void)setupUI{
    //设置iCloud中的首选项值
    NSUbiquitousKeyValueStore *defaults=[NSUbiquitousKeyValueStore defaultStore];
    self.autoSaveSetting.on= [defaults boolForKey:kSettingAutoSave];
    //添加存储变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(
    keyValueStoreChange:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:defaults];
}
/**
 *  key-value store发生变化或存储空间不足
 *
 *  @param notification 通知对象
 */
-(void)keyValueStoreChange:(NSNotification *)notification{
    NSLog(@"Key-value store change...");
}

/**
 *  设置首选项
 *
 *  @param value 是否自动保存
 */
-(void)setSetting:(BOOL)value{
    //iCloud首选项设置
    NSUbiquitousKeyValueStore *defaults=[NSUbiquitousKeyValueStore defaultStore];
    [defaults setBool:value forKey:kSettingAutoSave];
    [defaults synchronize];//同步
}
@end
