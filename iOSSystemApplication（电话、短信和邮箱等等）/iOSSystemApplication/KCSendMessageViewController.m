//
//  KCSendMessageViewController.m
//  iOSSystemApplication
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "KCSendMessageViewController.h"
#import <MessageUI/MessageUI.h>

@interface KCSendMessageViewController ()<MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *receivers;
@property (weak, nonatomic) IBOutlet UITextField *body;
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextField *attachments;

@end

@implementation KCSendMessageViewController
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
}


#pragma mark - UI事件
- (IBAction)sendMessageClick:(UIButton *)sender {
    //如果能发送文本信息
    if([MFMessageComposeViewController canSendText]){
        MFMessageComposeViewController *messageController=[[MFMessageComposeViewController alloc]init];
        //收件人
        messageController.recipients=[self.receivers.text componentsSeparatedByString:@","];
        //信息正文
        messageController.body=self.body.text;
        //设置代理,注意这里不是delegate而是messageComposeDelegate
        messageController.messageComposeDelegate=self;
        //如果运行商支持主题
        if([MFMessageComposeViewController canSendSubject]){
            messageController.subject=self.subject.text;
        }
        //如果运行商支持附件
        if ([MFMessageComposeViewController canSendAttachments]) {
            /*第一种方法*/
            //messageController.attachments=...;
            
            /*第二种方法*/
            NSArray *attachments= [self.attachments.text componentsSeparatedByString:@","];
            if (attachments.count>0) {
                [attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *path=[[NSBundle mainBundle]pathForResource:obj ofType:nil];
                    NSURL *url=[NSURL fileURLWithPath:path];
                    [messageController addAttachmentURL:url withAlternateFilename:obj];
                }];
            }
            
            /*第三种方法*/
//            NSString *path=[[NSBundle mainBundle]pathForResource:@"photo.jpg" ofType:nil];
//            NSURL *url=[NSURL fileURLWithPath:path];
//            NSData *data=[NSData dataWithContentsOfURL:url];
            /**
             *  attatchData:文件数据
             *  uti:统一类型标识，标识具体文件类型，详情查看：帮助文档中System-Declared Uniform Type Identifiers
             *  fileName:展现给用户看的文件名称
             */
//            [messageController addAttachmentData:data typeIdentifier:@"public.image"  filename:@"photo.jpg"];
        }
        [self presentViewController:messageController animated:YES completion:nil];
    }
}

#pragma mark - MFMessageComposeViewController代理方法
//发送完成，不管成功与否
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultSent:
            NSLog(@"发送成功.");
            break;
        case MessageComposeResultCancelled:
            NSLog(@"取消发送.");
            break;
        default:
            NSLog(@"发送失败.");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
