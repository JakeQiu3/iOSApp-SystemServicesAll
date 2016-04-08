//
//  ViewController.m
//  MultipeerConnectivity
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "ViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController ()<MCSessionDelegate,MCBrowserViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong,nonatomic) MCSession *session;
@property (strong,nonatomic) MCBrowserViewController *browserController;
@property (strong,nonatomic) UIImagePickerController *imagePickerController;

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@end

@implementation ViewController

#pragma mark - 控制器视图事件
- (void)viewDidLoad {
    [super viewDidLoad];
    //创建节点
    MCPeerID *peerID=[[MCPeerID alloc]initWithDisplayName:@"KenshinCui"];
    //创建会话
    _session=[[MCSession alloc]initWithPeer:peerID];
    _session.delegate=self;
    
    
}
#pragma mark- UI事件
- (IBAction)browserClick:(UIBarButtonItem *)sender {
    _browserController=[[MCBrowserViewController alloc]initWithServiceType:@"cmj-photo" session:self.session];
    _browserController.delegate=self;
    
    [self presentViewController:_browserController animated:YES completion:nil];
}

- (IBAction)selectClick:(UIBarButtonItem *)sender {
    _imagePickerController=[[UIImagePickerController alloc]init];
    _imagePickerController.delegate=self;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}


#pragma mark - MCBrowserViewController代理方法
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    NSLog(@"已选择");
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    NSLog(@"取消浏览.");
    [self.browserController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MCSession代理方法
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    NSLog(@"didChangeState");
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"连接成功.");
            [self.browserController dismissViewControllerAnimated:YES completion:nil];
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
#pragma mark - UIImagePickerController代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
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
