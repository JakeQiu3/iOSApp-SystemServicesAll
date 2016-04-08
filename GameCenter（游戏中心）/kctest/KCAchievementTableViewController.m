//
//  KCAchievementTableViewController.m
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "KCAchievementTableViewController.h"
#import <GameKit/GameKit.h>
//成就标识，就是iTunes Connect中配置的成就ID
#define kAchievementIdentifier1 @"AdidasGoldenBall"
#define kAchievementIdentifier2 @"AdidasGoldBoot"

@interface KCAchievementTableViewController ()

@end

@implementation KCAchievementTableViewController
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - UI事件
//添加成就
- (IBAction)addAchievementClick:(UIBarButtonItem *)sender {
    [self addAchievementWithIdentifier:kAchievementIdentifier1];
}

#pragma mark - UITableView数据源方法
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.achievementDescriptions.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identtityKey=@"myTableViewCellIdentityKey1";
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:identtityKey];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identtityKey];
    }
    GKAchievementDescription *desciption=[self.achievementDescriptions objectAtIndex:indexPath.row];
    cell.textLabel.text=desciption.title ;//成就标题
    //如果已经获得成就则加载进度，否则为0
    double percent=0.0;
    GKAchievement *achievement=[self getAchievementWithIdentifier:desciption.identifier];
    if (achievement) {
        percent=achievement.percentComplete;
    }
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%3.2f%%",percent]; //成就完成度
    //设置成就图片
    cell.imageView.image=[self.achievementImages valueForKey:desciption.identifier];
    return cell;
}



#pragma mark - 私有方法
//添加指定类别的成就
-(void)addAchievementWithIdentifier:(NSString *)identifier{
    if (![GKLocalPlayer localPlayer].isAuthenticated) {
        NSLog(@"未获得用户授权.");
        return;
    }
    //创建成就
    GKAchievement *achievement=[[GKAchievement alloc]initWithIdentifier:identifier];
    achievement.percentComplete=100;//设置此成就完成度，100代表获得此成就
    NSLog(@"%@",achievement);
    //保存成就到Game Center服务器,注意保存是异步的,并且支持离线提交
    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
        if(error){
            NSLog(@"保存成就过程中发生错误,错误信息:%@",error.localizedDescription);
            return ;
        }
        NSLog(@"添加成就成功.");
    }];
}

//根据标识获得已取得的成就
-(GKAchievement *)getAchievementWithIdentifier:(NSString *)identifier{
    for (GKAchievement *achievement in self.achievements) {
        if ([achievement.identifier isEqualToString:identifier]) {
            return achievement;
        }
    }
    return nil;
}
@end
