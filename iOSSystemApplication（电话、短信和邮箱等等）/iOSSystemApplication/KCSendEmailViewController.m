//
//  KCSendEmailViewController.m
//  iOSSystemApplication
//
//  Created by Kenshin Cui on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "KCSendEmailViewController.h"
#import <MessageUI/MessageUI.h>

@interface KCSendEmailViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *toTecipients;//收件人
@property (weak, nonatomic) IBOutlet UITextField *ccRecipients;//抄送人
@property (weak, nonatomic) IBOutlet UITextField *bccRecipients;//密送人
@property (weak, nonatomic) IBOutlet UITextField *subject; //主题
@property (weak, nonatomic) IBOutlet UITextField *body;//正文
@property (weak, nonatomic) IBOutlet UITextField *attachments;//附件

@end

@implementation KCSendEmailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI事件

- (IBAction)sendEmailClick:(UIButton *)sender {
    //判断当前是否能够发送邮件
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailController=[[MFMailComposeViewController alloc]init];
        //设置代理，注意这里不是delegate，而是mailComposeDelegate
        mailController.mailComposeDelegate=self;
        //设置收件人
        [mailController setToRecipients:[self.toTecipients.text componentsSeparatedByString:@","]];
        //设置抄送人
        if (self.ccRecipients.text.length>0) {
            [mailController setCcRecipients:[self.ccRecipients.text componentsSeparatedByString:@","]];
        }
        //设置密送人
        if (self.bccRecipients.text.length>0) {
            [mailController setBccRecipients:[self.bccRecipients.text componentsSeparatedByString:@","]];
        }
        //设置主题
        [mailController setSubject:self.subject.text];
        //设置内容
        [mailController setMessageBody:self.body.text isHTML:YES];
        //添加附件
        if (self.attachments.text.length>0) {
            NSArray *attachments=[self.attachments.text componentsSeparatedByString:@","] ;
            [attachments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSString *file=[[NSBundle mainBundle] pathForResource:obj ofType:nil];
                NSData *data=[NSData dataWithContentsOfFile:file];
                [mailController addAttachmentData:data mimeType:@"image/jpeg" fileName:obj];//第二个参数时mimeType类型，jpg图片对应image/jpeg
            }];
        }
        [self presentViewController:mailController animated:YES completion:nil];
        
    }
}

#pragma mark - MFMailComposeViewController代理方法
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"发送成功.");
            break;
        case MFMailComposeResultSaved://如果存储为草稿（存储后可以到系统邮件应用的对应草稿箱找到）
            NSLog(@"邮件已保存.");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"取消发送.");
            break;
            
        default:
            NSLog(@"发送失败.");
            break;
    }
    if (error) {
        NSLog(@"发送邮件过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
