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
@property (strong,nonatomic) PKPass *pass;//票据
@property (strong,nonatomic) PKAddPassesViewController *addPassesController;//票据添加控制器
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI事件
- (IBAction)addPassClick:(UIBarButtonItem *)sender {
    // 确保pass合法，否则无法添加
    [self addPass];
}

#pragma mark - 属性
/**
 *  创建Pass对象
 *
 *  @return Pass对象
 */
-(PKPass *)pass{
    if (!_pass) {
        NSString *passPath=[[NSBundle mainBundle] pathForResource:@"mypassbook.pkpass" ofType:nil];
        NSData *passData=[NSData dataWithContentsOfFile:passPath];
        NSError *error=nil;
        _pass=[[PKPass alloc]initWithData:passData error:&error];
        if (error) {
            NSLog(@"创建Pass过程中发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _pass;
}

/**
 *  创建添加Pass的控制器
 *
 *  @return PKAddPassesViewController
 */
-(PKAddPassesViewController *)addPassesController{
    if (!_addPassesController) {
        _addPassesController=[[PKAddPassesViewController alloc]initWithPass:self.pass];
        _addPassesController.delegate=self;//设置代理
    }
    return _addPassesController;
}

#pragma mark - 私有方法
-(void)addPass{
    if (![PKAddPassesViewController canAddPasses]) {
        NSLog(@"无法添加Pass.");
        return;
    }

    [self presentViewController:self.addPassesController animated:YES completion:nil];
}

#pragma mark - PKAddPassesViewController代理方法
-(void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller{
    NSLog(@"添加成功，打开该url");
    [self.addPassesController dismissViewControllerAnimated:YES completion:nil];
    //添加成功后转到Passbook应用并展示添加的Pass
    NSLog(@"%@",self.pass.passURL);
    [[UIApplication sharedApplication] openURL:self.pass.passURL];
    
}


@end
