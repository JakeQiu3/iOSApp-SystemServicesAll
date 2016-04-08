//
//  KCMainTableViewController.m
//  kctest
//
//  Created by Kenshin Cui on 14/4/5.
//  Copyright (c) 2015年 cmjstudio. All rights reserved.
//

#import "KCMainTableViewController.h"
#import <StoreKit/StoreKit.h>

#define kAppStoreVerifyURL @"https://buy.itunes.apple.com/verifyReceipt" //实际购买验证URL

#define kSandboxVerifyURL @"https://sandbox.itunes.apple.com/verifyReceipt" //开发阶段沙盒验证URL

// 定义可以购买的产品ID，必须和iTunes Connect中设置的一致

#define kProductID1 @"ProtectiveGloves" //强力手套，非消耗品
#define kProductID2 @"GoldenGlobe" //金球，非消耗品
#define kProductID3 @"EnergyBottle" //能量瓶，消耗品

@interface KCMainTableViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>

@property (strong,nonatomic) NSMutableDictionary *products;//有效的产品
@property (assign,nonatomic) int selectedRow;//选中行

@end

@implementation KCMainTableViewController
#pragma mark - 控制器视图方法
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadProducts];
    [self addTransactionObjserver];
    
}

#pragma mark - UI事件
//购买产品
- (IBAction)purchaseClick:(UIBarButtonItem *)sender {
    NSString *productIdentifier=self.products.allKeys[self.selectedRow];
    SKProduct *product=self.products[productIdentifier];
    if (product) {
        [self purchaseProduct:product];
    }else{
        NSLog(@"没有可用商品.");
    }
    
}
//恢复购买
- (IBAction)restorePurchaseClick:(UIBarButtonItem *)sender {
    [self restoreProduct];
}

#pragma mark - UITableView数据源方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identtityKey=@"myTableViewCellIdentityKey1";
    UITableViewCell *cell=[self.tableView dequeueReusableCellWithIdentifier:identtityKey];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identtityKey];
    }
    cell.accessoryType=UITableViewCellAccessoryNone;
    NSString *key=self.products.allKeys[indexPath.row];
    SKProduct *product=self.products[key];
    NSString *purchaseString;
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if ([product.productIdentifier isEqualToString:kProductID3]) {
        purchaseString=[NSString stringWithFormat:@"已购买%i个",[defaults integerForKey:product.productIdentifier]];
    }else{
        if([defaults boolForKey:product.productIdentifier]){
            purchaseString=@"已购买";
        }else{
            purchaseString=@"尚未购买";
        }
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%@(%@)",product.localizedTitle,purchaseString] ;
    cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",product.price];
    return cell;
}
#pragma mark - UITableView代理方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *currentSelected=[tableView cellForRowAtIndexPath:indexPath];
    currentSelected.accessoryType=UITableViewCellAccessoryCheckmark;
    self.selectedRow=indexPath.row;
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *currentSelected=[tableView cellForRowAtIndexPath:indexPath];
    currentSelected.accessoryType=UITableViewCellAccessoryNone;
}

#pragma mark - SKProductsRequestd代理方法
/**
 *  产品请求完成后的响应方法
 *
 *  @param request  请求对象
 *  @param response 响应对象，其中包含产品信息
 */
-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    //保存有效的产品
    _products=[NSMutableDictionary dictionary];
    [response.products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKProduct *product=obj;
        [_products setObject:product forKey:product.productIdentifier];
    }];
    //由于这个过程是异步的，加载成功后重新刷新表格
    [self.tableView reloadData];
}
-(void)requestDidFinish:(SKRequest *)request{
    NSLog(@"请求完成.");
}
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    if (error) {
        NSLog(@"请求过程中发生错误，错误信息：%@",error.localizedDescription);
    }
}

#pragma mark - SKPaymentQueue监听方法
/**
 *  交易状态更新后执行
 *
 *  @param queue        支付队列
 *  @param transactions 交易数组，里面存储了本次请求的所有交易对象
 */
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    [transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SKPaymentTransaction *paymentTransaction=obj;
        if (paymentTransaction.transactionState==SKPaymentTransactionStatePurchased){//已购买成功
            NSLog(@"交易\"%@\"成功.",paymentTransaction.payment.productIdentifier);
            //购买成功后进行验证
            [self verifyPurchaseWithPaymentTransaction];
            //结束支付交易
            [queue finishTransaction:paymentTransaction];
        }else if (paymentTransaction.transactionState==SKPaymentTransactionStateRestored){//恢复成功，对于非消耗品才能恢复,如果恢复成功则transaction中记录的恢复的产品交易
            NSLog(@"恢复交易\"%@\"成功.",paymentTransaction.payment.productIdentifier);
            [queue finishTransaction:paymentTransaction];//结束支付交易
            
            //恢复后重新写入偏好配置，重新加载UITableView
            [[NSUserDefaults standardUserDefaults]setBool:YES forKey:paymentTransaction.payment.productIdentifier];
            [self.tableView reloadData];
        }else if(paymentTransaction.transactionState==SKPaymentTransactionStateFailed){
            if (paymentTransaction.error.code==SKErrorPaymentCancelled) {//如果用户点击取消
                NSLog(@"取消购买.");
            }
            NSLog(@"ErrorCode:%i",paymentTransaction.error.code);
        }
        
    }];
}
//恢复购买完成
-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue{
    NSLog(@"恢复完成.");
}

#pragma mark - 私有方法
/**
 *  添加支付观察者监控，一旦支付后则会回调观察者的状态更新方法：
 -(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
 */
-(void)addTransactionObjserver{
    //设置支付观察者（类似于代理），通过观察者来监控购买情况
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}
/**
 *  加载所有产品，注意产品一定是从服务器端请求获得，因为有些产品可能开发人员知道其存在性，但是不经过审核是无效的；
 */
-(void)loadProducts{
    //定义要获取的产品标识集合
    NSSet *sets=[NSSet setWithObjects:kProductID1,kProductID2,kProductID3, nil];
    
    //定义请求用于获取产品
    SKProductsRequest *productRequest=[[SKProductsRequest alloc]initWithProductIdentifiers:sets];

    //设置代理,用于获取产品加载状态
    productRequest.delegate=self;
  
    //开始请求
    [productRequest start];
}
/**
 *  购买产品
 *
 *  @param product 产品对象
 */
-(void)purchaseProduct:(SKProduct *)product{
    //如果是非消耗品，购买过则提示用户
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if ([product.productIdentifier isEqualToString:kProductID3]) {
        NSLog(@"当前已经购买\"%@\" %li 个.",kProductID3,(long)[defaults integerForKey:product.productIdentifier]);
    }else if([defaults boolForKey:product.productIdentifier]){
        NSLog(@"\"%@\"已经购买过，无需购买!",product.productIdentifier);
        return;
    }
    
    // 创建产品支付对象
    SKPayment *payment=[SKPayment paymentWithProduct:product];
    //支付队列，将支付对象加入支付队列就形成一次购买请求
    if (![SKPaymentQueue canMakePayments]) {
        NSLog(@"设备不支持购买.");
        return;
    }
    SKPaymentQueue *paymentQueue = [SKPaymentQueue defaultQueue];
    //添加都支付队列，开始请求支付
//    [self addTransactionObjserver];
    [paymentQueue addPayment:payment];
}

/**
 *  恢复购买，对于非消耗品如果应用重新安装或者机器重置后可以恢复购买
 *  注意恢复时只能一次性恢复所有非消耗品
 */
-(void)restoreProduct{
    SKPaymentQueue *paymentQueue=[SKPaymentQueue defaultQueue];
    //设置支付观察者（类似于代理），通过观察者来监控购买情况
//    [paymentQueue addTransactionObserver:self];
    //恢复所有非消耗品
    [paymentQueue restoreCompletedTransactions];
}

/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
-(void)verifyPurchaseWithPaymentTransaction{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:kSandboxVerifyURL];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",dic);
    if([dic[@"status"] intValue]==0){
        NSLog(@"购买成功！");
        NSDictionary *dicReceipt= dic[@"receipt"];
        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        if ([productIdentifier isEqualToString:kProductID3]) {
            int purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
            [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
        }else{
            [defaults setBool:YES forKey:productIdentifier];
        }
        [self.tableView reloadData];
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    }else{
        NSLog(@"购买失败，未通过验证！");
    }
}
@end
