//
//  ViewController.m
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "ViewController.h"
#import <iAd/iAd.h>

@interface ViewController ()<ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet ADBannerView *advertiseBanner;//广告展示的视图


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理
    self.advertiseBanner.delegate=self;
//    设置新的广告地址
 
    
}

#pragma mark - ADBannerView代理方法
//广告将会加载
- (void)bannerViewWillLoadAd:(ADBannerView *)banner {
    NSLog(@"广告将会加载.");
}
//广告加载完成
-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"广告加载完成.");
}
//点击Banner后离开之前，返回NO则不会展开全屏广告
-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    NSLog(@"点击Banner后离开之前.");
    return YES;
}

//点击banner后全屏显示，关闭后调用
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"广告已关闭.");
}
//获取广告失败
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"加载广告失败.");
    self.advertiseBanner.hidden=YES;
}







@end
