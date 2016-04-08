//
//  ViewController.m
//  Social_UM
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "ViewController.h"
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"

@interface ViewController ()<UMSocialUIDelegate>

@end

@implementation ViewController
#pragma mark - 控制器视图事件
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - UI事件
- (IBAction)shareClick:(UIBarButtonItem *)sender {
    //设置微信AppId、appSecret，分享url
//    [UMSocialWechatHandler setWXAppId:@"wx30dbea5d5a258ed3" appSecret:@"cd36a9829e4b49a0dcac7b4162da5a5" url:@"http://www.cmj.com/social-UM"];
    //微信好友、微信朋友圈、微信收藏、QQ空间、QQ好友、来往好友等都必须经过各自的平台集成否则不会出现在分享列表,例如上面是设置微信的AppId和appSecret
// 表格式
    [UMSocialSnsService presentSnsIconSheetView:self appKey:@"54aa0a0afd98c5209f000efa" shareText:@"邱少依的 Blog..." shareImage:[UIImage imageNamed:@"stevenChow"] shareToSnsNames:@[UMShareToSina,UMShareToTencent,UMShareToRenren,UMShareToDouban] delegate:self];
//  tableview 式
//    [UMSocialSnsService presentSnsController:self appKey:@"54aa0a0afd98c5209f000efa" shareText:@"邱少依的 Blog..." shareImage:[UIImage imageNamed:@"stevenChow"] shareToSnsNames:@[UMShareToSina,UMShareToTencent,UMShareToRenren] delegate:self];
}

#pragma mark - UMSocialSnsService代理
//分享完成
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    //分享成功
    if(response.responseCode==UMSResponseCodeSuccess){
        NSLog(@"分享成功");
    }
}


@end
