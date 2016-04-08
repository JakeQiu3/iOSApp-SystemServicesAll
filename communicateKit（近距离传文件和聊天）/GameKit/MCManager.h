//
//  MCManager.h
//  GameKit
//
//  Created by 邱少依 on 16/3/31.
//  Copyright © 2016年 cmjstudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface MCManager : NSObject <MCSessionDelegate>
@property (nonatomic, strong) MCPeerID *peerID;//设备
@property (nonatomic, strong) MCSession *session;//重要：表示当前将或已经创建的会话，任何数据交换和通信,节点。
@property (nonatomic, strong) MCBrowserViewController *browser;//浏览其他对等设备点的默认UI
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;//从目前的设备去宣传自身对象
//公有方法
-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end
