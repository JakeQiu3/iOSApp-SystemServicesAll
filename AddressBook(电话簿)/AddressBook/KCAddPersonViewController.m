//
//  KCAddPersonViewController.m
//  AddressBook
//
//  kABPersonFirstNameProperty
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "KCAddPersonViewController.h"
#import "KCContactTableViewController.h"

@interface KCAddPersonViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *workPhone;
@end

@implementation KCAddPersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

#pragma mark - UI事件
- (IBAction)cancelClick:(UIBarButtonItem *)sender {
    [self.delegate cancelEdit];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)doneClick:(UIBarButtonItem *)sender {
    //调用代理方法
    [self.delegate editPersonWithFirstName:self.firstName.text lastName:self.lastName.text workNumber:self.workPhone.text];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有方法
-(void)setupUI{
    if (self.recordID) {//如果ID不为0则认为是修改，此时需要初始化界面
        self.firstName.text=self.firstNameText;
        self.lastName.text=self.lastNameText;
        self.workPhone.text=self.workPhoneText;
    }
}

@end
