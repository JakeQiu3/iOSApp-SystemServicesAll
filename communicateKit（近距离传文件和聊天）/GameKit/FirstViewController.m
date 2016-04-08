//
//  FirstViewController.m
//  GameKit
//
//  Created by 邱少依 on 16/3/31.
//  Copyright © 2016年 cmjstudio. All rights reserved.
//

#import "FirstViewController.h"
#import "AppDelegate.h"
@interface FirstViewController ()<UITextFieldDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtMessage;
@property (weak, nonatomic) IBOutlet UITextView *tvChat;
@property (nonatomic, strong) AppDelegate *appDelegate;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _txtMessage.delegate = self;
    _tvChat.delegate = self;
    _tvChat.editable = NO;
//    注册通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didReceiveDataWithNotification:) name:@"MCDidReceiveDataNotification" object:nil];
}
 //通知发出后，执行的方法
- (void)didReceiveDataWithNotification:(NSNotification *)notification {
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    NSData *receivedData = [[notification userInfo] objectForKey:@"data"];
    NSString *receivedText = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    [_tvChat performSelectorOnMainThread:@selector(setText:) withObject:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"%@ wrote:\n%@\n\n", peerDisplayName, receivedText]] waitUntilDone:NO];
}


- (IBAction)sendMessage:(id)sender {
     [self sendMyMessage];
}
- (IBAction)cancelMessage:(id)sender {
    [_txtMessage resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self sendMyMessage];
    return YES;
}
#pragma  发送消息
-(void)sendMyMessage {

    NSData *dataToSend = [_txtMessage.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *allPeers = _appDelegate.mcManager.session.connectedPeers;
    NSError *error;
//    MCSessionSendDataReliable 可靠模式，不会有数据丢失现象
    [_appDelegate.mcManager.session sendData:dataToSend
                                     toPeers:allPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_tvChat setText:[_tvChat.text stringByAppendingString:[NSString stringWithFormat:@"I wrote:\n%@\n\n", _txtMessage.text]]];
    [_txtMessage setText:@""];//清空输入框
    
    [_txtMessage resignFirstResponder];//退出textfield键盘
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
