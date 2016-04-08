//
//  ViewController.m
//  AddressBookUI
//
//  Created by qsy on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "ViewController.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBookUI/AddressBookUI.h>
@interface ViewController ()<CNContactPickerDelegate,CNContactViewControllerDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI事件
//添加联系人
- (IBAction)addPersonClick:(UIButton *)sender {

    CNContactPickerViewController *contactPickerController = [[CNContactPickerViewController alloc]init];
    
    contactPickerController.delegate = self;
    //注意ABNewPersonViewController必须包装一层UINavigationController才能使用，否则不会出现取消和完成按钮，无法进行保存等操作
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:contactPickerController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
#pragma  少 CNContactPickerDelegate方法
- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
//选择的联系人 单个
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
    
}
//选择的联系人 多个
- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContacts:(NSArray<CNContact*> *)contacts {
    
}

// 未知联系人点击方法
- (IBAction)unknownPersonClick:(UIButton *)sender {
    CNContact *contact = [[CNContact alloc] init];
    
    CNContactViewController  *unknownPersonController = [CNContactViewController viewControllerForUnknownContact:contact];
    unknownPersonController.delegate = self;
    //使用导航控制器包装
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:unknownPersonController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
#pragma 少 CNContactViewControllerDelegate 的代理方法
- (BOOL)contactViewController:(CNContactViewController *)viewController shouldPerformDefaultActionForContactProperty:(CNContactProperty *)property {
    return  YES;
}

- (void)contactViewController:(CNContactViewController *)viewController didCompleteWithContact:(nullable CNContact *)contact {
//    传值给上一个界面或者直接保存到那儿
    
}


// 显示联系人
- (IBAction)showPersonClick:(UIButton *)sender {
    CNContact *contact = [[CNContact alloc]init];
    CNContactViewController *showContactController = [CNContactViewController viewControllerForContact:contact];
    showContactController.delegate = self;
    showContactController.shouldShowLinkedContacts = YES;
    
    //使用导航控制器包装
    UINavigationController *navigationController=[[UINavigationController alloc]initWithRootViewController:showContactController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
//选择联系人
- (IBAction)selectPersonClick:(UIButton *)sender {
    
    ABPeoplePickerNavigationController *peoplePickerController=[[ABPeoplePickerNavigationController alloc]init];
    //设置代理
    peoplePickerController.peoplePickerDelegate=self;
    [self presentViewController:peoplePickerController animated:YES completion:nil];
}

@end
