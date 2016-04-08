//
//  ViewController.m
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "KCDetailViewController.h"
#import "KCDocument.h"
#define kSettingAutoSave @"com.cmjstudio.kctest.settings.autosave"

@interface KCDetailViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation KCDetailViewController
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //根据首选项来确定离开当前控制器视图是否自动保存
    BOOL autoSave=[[NSUbiquitousKeyValueStore defaultStore] boolForKey:kSettingAutoSave];
    if (autoSave) {
        [self saveDocument];
    }
}

#pragma mark - 私有方法
-(void)setupUI{
    UIBarButtonItem *rightButtonItem=[[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveDocument)];
    self.navigationItem.rightBarButtonItem=rightButtonItem;
    
    if (self.document) {
        //打开文档，读取文档
        [self.document openWithCompletionHandler:^(BOOL success) {
            if(success){
                NSLog(@"读取数据成功.");
                NSString *dataText=[[NSString alloc]initWithData:self.document.data encoding:NSUTF8StringEncoding];
                self.textView.text=dataText;
            }else{
                NSLog(@"读取数据失败.");
            }
        }];
    }
}
/**
 *  保存文档
 */
-(void)saveDocument{
    if (self.document) {
        NSString *dataText=self.textView.text;
        NSData *data=[dataText dataUsingEncoding:NSUTF8StringEncoding];
        self.document.data=data;
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            NSLog(@"保存成功！");
        }];
    }
}

@end
