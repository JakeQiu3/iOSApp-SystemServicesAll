
//
//  KCMainTableViewController.m
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//  静态表格

#import "KCMainTableViewController.h"
#import <GameKit/GameKit.h>
#import "KCLeaderboardTableViewController.h"
#import "KCAchievementTableViewController.h"

@interface KCMainTableViewController ()<GKGameCenterControllerDelegate>

@property (strong,nonatomic) NSArray *leaderboards;//排行榜对象数组
@property (strong,nonatomic) NSArray *achievements;//成就
@property (strong,nonatomic) NSArray *achievementDescriptions;//成就描述
@property (strong,nonatomic) NSMutableDictionary *achievementImages;//成就图片

@property (weak, nonatomic) IBOutlet UILabel *leaderboardLabel; //排行个数
@property (weak, nonatomic) IBOutlet UILabel *achievementLable; //成就个数

@end

@implementation KCMainTableViewController

#pragma mark - 控制器视图事件
- (void)viewDidLoad {
    [super viewDidLoad];

    [self authorize];
}

#pragma mark - 私有方法
//检查是否经过认证，如果没经过认证则弹出Game Center登录界面
-(void)authorize{
    //创建一个本地用户
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    //检查用于授权，如果没有登录则让用户登录到GameCenter(注意此事件设置之后或点击登录界面的取消按钮都会被调用)
    [localPlayer setAuthenticateHandler:^(UIViewController * controller, NSError *error) {
        if ([[GKLocalPlayer localPlayer] isAuthenticated]) {
            NSLog(@"已授权");
            [self setupUI];
        }else {
            //注意：在设置中找到Game Center，设置其允许沙盒，否则controller为nil
            if (controller) {
                  [self  presentViewController:controller animated:YES completion:nil];
            } else {//沙盒未设置时，为空
                NSLog(@"请去设置中->GameCenter->允许沙盒");
            }
          
        }
    }];
}

#pragma mark - UI事件
- (IBAction)viewGameCenterClick:(UIBarButtonItem *)sender {
    [self viewGameCenter];
}

#pragma mark - GKGameCenterViewController代理方法
//点击完成
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    NSLog(@"完成.");
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -导航
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //如果是导航到排行榜，则将当前排行榜传递到排行榜视图
    if ([segue.identifier isEqualToString:@"leaderboard"]) {
        UINavigationController *navigationController=segue.destinationViewController;
        KCLeaderboardTableViewController *leaderboardController=[navigationController.childViewControllers firstObject];
        leaderboardController.leaderboards=self.leaderboards;
    }else if ([segue.identifier isEqualToString:@"achievement"]) {
        UINavigationController *navigationController=segue.destinationViewController;
        KCAchievementTableViewController *achievementController=[navigationController.childViewControllers firstObject];
        achievementController.achievements=self.achievements;
        achievementController.achievementDescriptions=self.achievementDescriptions;
        achievementController.achievementImages=self.achievementImages;
    }
}

//UI布局
-(void)setupUI{
    //更新排行榜个数
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray<GKLeaderboard *> * _Nullable leaderboards, NSError * _Nullable error) {
        if (error) {
            NSLog(@"加载排行榜过程中发生错误,错误信息:%@",error.localizedDescription);
        }
        self.leaderboards = leaderboards;
        self.leaderboardLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)leaderboards.count];
        [leaderboards enumerateObjectsUsingBlock:^(GKLeaderboard * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKLeaderboard *leaderboard = obj;
            [leaderboard loadScoresWithCompletionHandler:^(NSArray<GKScore *> * _Nullable scores, NSError * _Nullable error) {
                
            }];
        }];
    }];
       //更新获得成就个数，注意这个个数不一定等于iTunes Connect中的总成就个数，此方法只能获取到成就完成进度不为0的成就
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray<GKAchievement *> * _Nullable achievements, NSError * _Nullable error) {
        if (error) {
             NSLog(@"加载成就过程中发生错误,错误信息:%@",error.localizedDescription);
        }
        self.achievements = achievements;
        self.achievementLable.text = [NSString stringWithFormat:@"%lu",(unsigned long)achievements.count];
        [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray<GKAchievementDescription *> * _Nullable descriptions, NSError * _Nullable error) {
            if (error) {
                NSLog(@"加载成就描述信息过程中发生错误,错误信息:%@",error.localizedDescription);
                return ;

            }
            self.achievementDescriptions = descriptions;
// 加载图片
            _achievementImages = [NSMutableDictionary dictionary];
            [descriptions enumerateObjectsUsingBlock:^(GKAchievementDescription * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GKAchievementDescription *description = (GKAchievementDescription *)obj;
                [description loadImageWithCompletionHandler:^(UIImage *image, NSError *error) {
                    [_achievementImages setObject:image forKey:description.identifier];
                }];
            }];
        }];
    }];
    
    
}

//查看Game Center
-(void)viewGameCenter{
    
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        NSLog(@"未获得用户授权.");
        return;
    }
       //Game Center视图控制器
    GKGameCenterViewController *gameCenterController=[[GKGameCenterViewController alloc]init];
    //设置代理
    gameCenterController.gameCenterDelegate=self;
    //显示
    [self presentViewController:gameCenterController animated:YES completion:nil];
}
@end
