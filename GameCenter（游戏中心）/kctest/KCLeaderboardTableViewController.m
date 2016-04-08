
//
//  KCLeaderboardTableViewController.m
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "KCLeaderboardTableViewController.h"
#import <GameKit/GameKit.h>
//排行榜标识，就是iTunes Connect中配置的排行榜ID
#define kLeaderboardIdentifier1 @"Goals"

@interface KCLeaderboardTableViewController ()
@end

@implementation KCLeaderboardTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - UI事件
//添加得分(这里指的是进球数)
- (IBAction)addScoreClick:(UIBarButtonItem *)sender {
    [self addScoreWithIdentifier:kLeaderboardIdentifier1 value:100];
}
#pragma mark - UITableView数据源方法
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.leaderboards.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identtityKey=@"myTableViewCellIdentityKey1";
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:identtityKey];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identtityKey];
    }
    GKLeaderboard *leaderboard=self.leaderboards[indexPath.row];
    GKScore *score=[leaderboard.scores firstObject];
    NSLog(@"scores:%@",leaderboard.scores);
    cell.textLabel.text=leaderboard.title;//排行榜标题
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%lld",score.value]; //排行榜得分
    return cell;
}

#pragma mark - 属性

#pragma mark - 私有方法
/**
 *  设置得分
 *
 *  @param identifier 排行榜标识
 *  @param value      得分
 */
-(void)addScoreWithIdentifier:(NSString *)identifier value:(int64_t)value{
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        NSLog(@"未获得用户授权.");
        return;
    }
    //创建积分对象
    GKScore *score=[[GKScore alloc]initWithLeaderboardIdentifier:identifier];
    //设置得分
    score.value=value;
    //提交积分到Game Center服务器端,注意保存是异步的,并且支持离线提交
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if(error){
            NSLog(@"保存积分过程中发生错误,错误信息:%@",error.localizedDescription);
            return ;
        }
        NSLog(@"添加积分成功.");
    }];
}
@end
