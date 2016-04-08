//
//  ConnectionsViewController.m
//  GameKit
//
//  Created by 邱少依 on 16/3/31.
//  Copyright © 2016年 cmjstudio. All rights reserved.
//

#import "ConnectionsViewController.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "AppDelegate.h"

@interface ConnectionsViewController ()<MCBrowserViewControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) AppDelegate *appDelegate;//获取到AppDelegate的mcManager属性
@property (nonatomic, strong) NSMutableArray *arrConnectedDevices;//所有连接设备的数组
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UISwitch *swVisible;
@property (weak, nonatomic) IBOutlet UITableView *tblConnectedDevicesTableView;
@property (weak, nonatomic) IBOutlet UIButton *btnDisconnect;

@end

@implementation ConnectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MCManager *mcManager = [_appDelegate mcManager ];//获取到工具类对象
    [mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    [mcManager advertiseSelf:_swVisible.isOn];
    
//    设置当前的设备名称的代理为自己
    _txtName.delegate = self;
   
//
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(peerDidChangeStateWithNotification:)
                                                 name:@"MCDidChangeStateNotification"
                                               object:nil];
      _arrConnectedDevices = [[NSMutableArray alloc] init];
    _tblConnectedDevicesTableView.delegate = self;
    _tblConnectedDevicesTableView.dataSource = self;
}
//收到通知后，执行该方法:：连接点的显示名称到表格视图，禁用文本字段  或者移除名称，可用文本字段
- (void)peerDidChangeStateWithNotification:(NSNotification *)notification {
//    获取到设备的名称和连接的状态
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [_arrConnectedDevices addObject:peerDisplayName];
        }
        else if (state == MCSessionStateNotConnected){
            if ([_arrConnectedDevices count] > 0) {
                int indexOfPeer = (int)[_arrConnectedDevices indexOfObject:peerDisplayName];
                [_arrConnectedDevices removeObjectAtIndex:indexOfPeer];
            }
        }
//        刷新tableView
        [_tblConnectedDevicesTableView reloadData];
//        没有连接的设备时，为1
        BOOL peersExist = ([[_appDelegate.mcManager.session connectedPeers] count] == 0);
        [_btnDisconnect setEnabled:!peersExist];
        [_txtName setEnabled:peersExist];
    }
}
// 广播自身
- (IBAction)browseForDevices:(id)sender {
    [[_appDelegate mcManager]setupMCBrowser];//创建一个浏览器对象
    [[_appDelegate mcManager] browser].delegate = self;
    [self presentViewController:[[_appDelegate mcManager] browser] animated:YES completion:^{
        
    }];
    
}
//开关控件能启用和禁用广告
- (IBAction)toggleVisibility:(id)sender {
    [_appDelegate.mcManager advertiseSelf:_swVisible.isOn];
}
//断开连接
- (IBAction)disconnect:(id)sender {
    [_appDelegate.mcManager.session disconnect];
    
    _txtName.enabled = YES;
    
    [_arrConnectedDevices removeAllObjects];
    [_tblConnectedDevicesTableView reloadData];
}

# pragma 少 MCBrowserViewControllerDelegate方法，让代理管理该浏览器UI
//点击浏览器控制器的Done按钮
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}
//点击浏览器控制器的Cancel按钮
-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [_appDelegate.mcManager.browser dismissViewControllerAnimated:YES completion:nil];
}


# pragma 少 UITextFieldDelegate方法: 返回按钮被按下后键盘消失
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_txtName resignFirstResponder];
    
    _appDelegate.mcManager.peerID = nil;
    _appDelegate.mcManager.session = nil;
    _appDelegate.mcManager.browser = nil;
    
    if ([_swVisible isOn]) {
        [_appDelegate.mcManager.advertiser stop];
    }
    _appDelegate.mcManager.advertiser = nil;
    
    
    [_appDelegate.mcManager setupPeerAndSessionWithDisplayName:_txtName.text];
    [_appDelegate.mcManager setupMCBrowser];
    [_appDelegate.mcManager advertiseSelf:_swVisible.isOn];
    
    return YES;
}
#pragma  少 TableView的代理方法

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_arrConnectedDevices count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.textLabel.text = [_arrConnectedDevices objectAtIndex:indexPath.row];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
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
