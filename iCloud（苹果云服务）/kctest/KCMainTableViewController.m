//
//  KCMainTableViewController.m
//  kctest
//
//  Created by qsy on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "KCMainTableViewController.h"
#import "KCDocument.h"
#import "KCDetailViewController.h"
#define kContainerIdentifier @"iCloud.com.cmjstudio.kctest" //容器id，可以从生产的entitiements文件中查看Ubiquity Container Identifiers（注意其中的$(CFBundleIdentifier)替换为BundleID）


@interface KCMainTableViewController ()
@property (strong,nonatomic) KCDocument *document;//当前选中的管理对象
@property (strong,nonatomic) NSMutableDictionary *files; //现有文件名、创建日期集合
@property (strong,nonatomic) NSMetadataQuery *dataQuery;//数据查询对象，用于查询iCloud文档


@end

@implementation KCMainTableViewController
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDocuments];

}

#pragma mark - UI事件
//新建文档
- (IBAction)addDocumentClick:(UIBarButtonItem *)sender {
    UIAlertController *promptController=[UIAlertController alertControllerWithTitle:@"KCTest" message:@"请输入笔记名称" preferredStyle:UIAlertControllerStyleAlert];
    [promptController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder=@"笔记名称";
    }];
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField= promptController.textFields[0];
        [self addDocument:textField.text];
    }];
    [promptController addAction:okAction];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [promptController addAction:cancelAction];
    [self presentViewController:promptController animated:YES completion:nil];

}
#pragma mark - 导航
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"noteDetail"]) {
        KCDetailViewController *detailController= segue.destinationViewController;
        detailController.document=self.document;
    }
}

#pragma mark - 属性
-(NSMetadataQuery *)dataQuery{
    if (!_dataQuery) {
        //创建一个iCloud查询对象
        _dataQuery=[[NSMetadataQuery alloc]init];
        _dataQuery.searchScopes=@[NSMetadataQueryUbiquitousDocumentsScope];
        //注意查询状态是通过通知的形式告诉监听对象的
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryFinish:) name:NSMetadataQueryDidFinishGatheringNotification object:_dataQuery];//数据获取完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryFinish:) name:NSMetadataQueryDidUpdateNotification object:_dataQuery];//查询更新通知
    }
    return _dataQuery;
}
#pragma mark - 私有方法
/**
 *  取得云端存储文件的地址
 *
 *  @param fileName 文件名，如果文件名为nil则重新创建一个url
 *
 *  @return 文件地址
 */
-(NSURL *)getUbiquityFileURL:(NSString *)fileName{
    //取得云端URL基地址(参数中传入nil则会默认获取第一个容器)
    NSURL *url= [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:kContainerIdentifier];
    //取得Documents目录
    url=[url URLByAppendingPathComponent:@"Documents"];
    //取得最终地址
    url=[url URLByAppendingPathComponent:fileName];
    NSLog(@"最终的Url地址%@",url);
    return url;
    
    
    
}

/**
 *  添加文档到iCloud
 *
 *  @param fileName 文件名称（不包括后缀）
 */
-(void)addDocument:(NSString *)fileName{
    //取得保存URL
    fileName=[NSString stringWithFormat:@"%@.txt",fileName];
    NSURL *url=[self getUbiquityFileURL:fileName];
    
    /**
     创建云端文档操作对象
     */
    
    KCDocument *document= [[KCDocument alloc]initWithFileURL:url];
    [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"保存成功.");
            [self loadDocuments];
            [self.tableView reloadData];
            self.document=document;
            [self performSegueWithIdentifier:@"noteDetail" sender:self];
        }else{
            NSLog(@"保存失败.");
        }
        
    }];
}

/**
 *  加载文档列表：NSMetadataQuery对象来获取
 */
-(void)loadDocuments{
    [self.dataQuery startQuery];
}
/**
 *  获取数据完成后的通知执行方法
 *
 *  @param notification 通知对象
 */
-(void)metadataQueryFinish:(NSNotification *)notification{
    NSLog(@"数据获取成功！");
    NSArray *items=self.dataQuery.results;//查询结果数组:存放着NSMetadataItem
    
    self.files=[NSMutableDictionary dictionary];
    //变量结果集，存储文件名称、创建日期
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMetadataItem *item=obj;
        NSString *fileName=[item valueForAttribute:NSMetadataItemFSNameKey];
        NSDate *date=[item valueForAttribute:NSMetadataItemFSContentChangeDateKey];
        NSDateFormatter *dateformate=[[NSDateFormatter alloc]init];
        dateformate.dateFormat=@"YY-MM-dd HH:mm";
        NSString *dateString= [dateformate stringFromDate:date];
        [self.files setObject:dateString forKey:fileName];
    }];
    [self.tableView reloadData];
}

-(void)removeDocument:(NSString *)fileName{
    
    NSURL *url=[self getUbiquityFileURL:fileName];
    NSError *error=nil;
    //删除存储的文件
    [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (error) {
        NSLog(@"删除文档过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    
    [self.files removeObjectForKey:fileName];// 从数组中删除
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identtityKey=@"myTableViewCellIdentityKey1";
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:identtityKey];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identtityKey];
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    NSArray *fileNames = [self.files allKeys];//无序排列
    NSString *fileName = fileNames[indexPath.row];
    cell.textLabel.text=fileName;
    cell.detailTextLabel.text=[self.files valueForKey:fileName];
    return cell;
}
#pragma  mark 少  删除列表时执行的操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
       if (editingStyle == UITableViewCellEditingStyleDelete) {
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
        [self removeDocument:cell.textLabel.text];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - UITableView 代理方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//  获取到对应的cell
    UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
    NSURL *url=[self getUbiquityFileURL:cell.textLabel.text];
    
    self.document = [[KCDocument alloc]initWithFileURL:url];
    [self performSegueWithIdentifier:@"noteDetail" sender:self];
}



@end
