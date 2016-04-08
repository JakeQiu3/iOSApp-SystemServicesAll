//
//  AppDelegate.m
//  iOSOpenApplication
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
    
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    NSString *str=[NSString stringWithFormat:@"url:%@,source application:%@,params:%@",url,sourceApplication,[url host]];
    [str writeToFile:@"/Users/qiushaoyi/Desktop/未命名.rtf" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"%@",str);
    return YES;//是否能够打开
}

@end
