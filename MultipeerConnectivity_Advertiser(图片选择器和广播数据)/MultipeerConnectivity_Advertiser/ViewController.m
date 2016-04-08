//
//  ViewController.m
//  MultipeerConnectivity_Advertiser
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()<MCSessionDelegate,MCAdvertiserAssistantDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong,nonatomic) MCSession *session;//节点
@property (strong,nonatomic) MCAdvertiserAssistant *advertiserAssistant;//广告助手
@property (strong,nonatomic) UIImagePickerController *imagePickerController;// 图片选择器

@property (weak, nonatomic) IBOutlet UIImageView *photo;

@end

@implementation ViewController

#pragma mark - 控制器视图事件
- (void)viewDidLoad {
    [super viewDidLoad];
    //创建节点，displayName是用于提供给周边设备查看和区分此服务的
    MCPeerID *peerID=[[MCPeerID alloc]initWithDisplayName:@"QSY_Advertiser"];
    _session=[[MCSession alloc]initWithPeer:peerID];
    _session.delegate=self;
    //创建广播
    _advertiserAssistant=[[MCAdvertiserAssistant alloc]initWithServiceType:@"cmj-photo" discoveryInfo:nil session:_session];
    _advertiserAssistant.delegate=self;
    
}

#pragma mark - UI事件
- (IBAction)advertiserClick:(UIBarButtonItem *)sender {
    //开始广播
    [self.advertiserAssistant start];
}

- (IBAction)selectClick:(UIBarButtonItem *)sender {
    _imagePickerController=[[UIImagePickerController alloc]init];
    _imagePickerController.delegate=self;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}

#pragma mark - MCSession代理方法

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSLog(@"didChangeState");
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"连接成功.");
            break;
        case MCSessionStateConnecting:
            NSLog(@"正在连接...");
            break;
        default:
            NSLog(@"连接失败.");
            break;
    }
}

//接收数据
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSLog(@"开始接收数据...");
    UIImage *image=[UIImage imageWithData:data];
    [self.photo setImage:image];
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    
}
#pragma mark - MCAdvertiserAssistant代理方法

#pragma mark - UIImagePickerController代理方法

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
//    UIKIT_EXTERN  NSData * __nullable UIImagePNGRepresentation(UIImage * __nonnull image);
    UIImage *image=[info objectForKey:UIImagePickerControllerOriginalImage];
    [self.photo setImage:image];
    //发送数据给所有已连接设备
    
    NSError *error=nil;
    [self.session sendData:UIImagePNGRepresentation(image) toPeers:[self.session connectedPeers] withMode:MCSessionSendDataUnreliable error:&error];
    NSLog(@"开始发送数据...");
    if (error) {
        NSLog(@"发送数据过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}
@end
