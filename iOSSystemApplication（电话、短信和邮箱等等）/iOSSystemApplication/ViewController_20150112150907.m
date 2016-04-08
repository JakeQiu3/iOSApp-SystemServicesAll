//
//  ViewController.m
//  iOSSystemApplication
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark - UI事件
//打电话
- (IBAction)callClicK:(UIButton *)sender {
    NSString *phoneNumber=@"18500138888";
//    NSString *url=[NSString stringWithFormat:@"tel://%@",phoneNumber];//这种方式会直接拨打电话
    NSString *url=[NSString stringWithFormat:@"telprompt://%@",phoneNumber];//这种方式会提示用户确认是否拨打电话
    [self openUrl:url];
}

//发送短信
- (IBAction)sendMessageClick:(UIButton *)sender {
    NSString *phoneNumber=@"18500138888";
    NSString *url=[NSString stringWithFormat:@"sms://%@",phoneNumber];
    [self openUrl:url];
}

//发送邮件
- (IBAction)sendEmailClick:(UIButton *)sender {
    NSString *mailAddress=@"kenshin@hotmail.com";
    NSString *url=[NSString stringWithFormat:@"mailto://%@",mailAddress];
    [self openUrl:url];
}

//浏览网页
- (IBAction)browserClick:(UIButton *)sender {
    NSString *url=@"http://www.cnblogs.com/kenshincui";
    [self openUrl:url];
}

//打开第三方应用
- (IBAction)thirdPartyApplicationClick:(UIButton *)sender {
    NSString *url=@"cmj://com.cmjstudio.iosapplication222";
    [self openUrl:url];
}

#pragma mark - 私有方法
-(void)openUrl:(NSString *)urlStr{
    //注意url中包含协议名称，iOS根据协议确定调用哪个应用，例如发送邮件是“sms://”其中“//”可以省略写成“sms:”(其他协议也是如此)
    NSURL *url=[NSURL URLWithString:urlStr];
    UIApplication *application=[UIApplication sharedApplication];
    if(![application canOpenURL:url]){
        NSLog(@"无法打开\"%@\"，请确保此应用已经正确安装.",url);
        return;
    }
    [[UIApplication sharedApplication] openURL:url];
}

@end
