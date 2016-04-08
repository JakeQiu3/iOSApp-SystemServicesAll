//
//  ViewController.m
//  Passbook
//
//  Created by Kenshin Cui on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "ViewController.h"
#import <PassKit/PassKit.h>

@interface ViewController ()<PKAddPassesViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - UI事件
- (IBAction)addPassClick:(UIBarButtonItem *)sender {
    //确保pass合法，否则无法添加
    [self addPass];
}


#pragma mark - 私有方法
-(void)addPass{
    if (![PKAddPassesViewController canAddPasses]) {
        NSLog(@"无法添加Pass.");
        return;
    }
    //创建Pass对象
    NSString *passPath=[[NSBundle mainBundle] pathForResource:@"mypassbook.pkpass" ofType:nil];
    NSData *passData=[NSData dataWithContentsOfFile:passPath];
    NSError *error=nil;
    PKPass *pass=[[PKPass alloc]initWithData:passData error:&error];
    if (error) {
        NSLog(@"创建Pass过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    //创建添加Pass的控制器视图
    PKAddPassesViewController *addPassController=[[PKAddPassesViewController alloc]initWithPass:pass];
    addPassController.delegate=self;//设置代理
    
    //显示
    [self presentViewController:addPassController animated:YES completion:nil];
}

#pragma mark - PKAddPassesViewController代理方法
-(void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller{
    NSLog(@"添加成功.");
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[UIApplication sharedApplication] openURL:@"shoebox://"];
}
@end
