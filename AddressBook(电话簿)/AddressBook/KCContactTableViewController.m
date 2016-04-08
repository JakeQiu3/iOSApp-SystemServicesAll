//
//  KCTableViewController.m
//  AddressBook
//
//  Created by qsy on 14/04/05.
//  Copyright (c) 2014年 cmjstudio. All rights reserved.
//

#import "KCContactTableViewController.h"
#import <AddressBook/AddressBook.h>
#import "KCAddPersonViewController.h"

@interface KCContactTableViewController ()<KCContactDelegate>

@property (assign,nonatomic) ABAddressBookRef addressBook;//通讯录
@property (strong,nonatomic) NSMutableArray *allPerson;//通讯录所有人员

@property (assign,nonatomic) int isModify;//标识是修改还是新增，通过选择cell进行导航则认为是修改，否则视为新增
@property (assign,nonatomic) UITableViewCell *selectedCell;//当前选中的单元格

@end

@implementation KCContactTableViewController

#pragma mark - 控制器视图
- (void)viewDidLoad {
    [super viewDidLoad];

    //请求访问通讯录并初始化数据
    [self requestAddressBook];
}

//由于在整个视图控制器周期内addressBook都驻留在内存中，所有当控制器视图销毁时销毁该对象
-(void)dealloc{
    if (self.addressBook!=NULL) {
        CFRelease(self.addressBook);
    }
}

#pragma mark - UI事件
//点击删除按钮
- (IBAction)trashClick:(UIBarButtonItem *)sender {
    self.tableView.editing = ! self.tableView.editing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ABRecordRef recordRef=(__bridge ABRecordRef )self.allPerson[indexPath.row];
//        //取得记录中得信息:根据名字来删除联系人
//        NSString *firstName=(__bridge NSString *) ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);//注意这里进行了强转，不用自己释放资源
//        NSString *lastName=(__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
//        
//        NSString *fullName = [NSString stringWithFormat:@"%@%@",firstName,lastName];
//        [self removePersonWithName:fullName];
        [self removePersonWithRecord:recordRef];//从通讯录删除整个联系人
        
        
        [self.allPerson removeObjectAtIndex:indexPath.row];//从数组移除
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];//从列表删除
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/**
 *  删除指定的记录
 *
 *  @param recordRef 要删除的记录
 */
-(void)removePersonWithRecord:(ABRecordRef)recordRef{
    ABAddressBookRemoveRecord(self.addressBook, recordRef, NULL);//删除
    ABAddressBookSave(self.addressBook, NULL);//删除之后提交更改
}
/**
 *  根据姓名删除记录
 */
-(void)removePersonWithName:(NSString *)personName{
    
    CFStringRef personNameRef=(__bridge CFStringRef)(personName);
    CFArrayRef recordsRef= ABAddressBookCopyPeopleWithName(self.addressBook, personNameRef);//根据人员姓名查找
    
    CFIndex count= CFArrayGetCount(recordsRef);//取得记录数
    for (CFIndex i=0; i<count; ++i) {
        ABRecordRef recordRef=CFArrayGetValueAtIndex(recordsRef, i);//取得指定的记录
        ABAddressBookRemoveRecord(self.addressBook, recordRef, NULL);//删除
    }
    
    ABAddressBookSave(self.addressBook, NULL);//删除之后提交更改
    CFRelease(recordsRef);
}

/**
 *  添加一条记录
 *
 *  @param firstName  名
 *  @param lastName   姓
 *  @param iPhoneName iPhone手机号
 */
-(void)addPersonWithFirstName:(NSString *)firstName lastName:(NSString *)lastName workNumber:(NSString *)workNumber{
    //创建一条记录
    ABRecordRef recordRef= ABPersonCreate();
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), NULL);//添加名
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), NULL);//添加姓
    
    ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);//添加设置多值属性
    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(workNumber), kABWorkLabel, NULL);//添加工作电话
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
    
    //添加记录
    ABAddressBookAddRecord(self.addressBook, recordRef, NULL);
    
    //保存通讯录，提交更改
    ABAddressBookSave(self.addressBook, NULL);
    //释放资源
    CFRelease(recordRef);
    CFRelease(multiValueRef);
}

/**
 *  根据RecordID修改联系人信息
 *
 *  @param recordID   记录唯一ID
 *  @param firstName  姓
 *  @param lastName   名
 *  @param homeNumber 工作电话
 */
-(void)modifyPersonWithRecordID:(ABRecordID)recordID firstName:(NSString *)firstName lastName:(NSString *)lastName workNumber:(NSString *)workNumber{
    ABRecordRef recordRef=ABAddressBookGetPersonWithRecordID(self.addressBook,recordID);
    ABRecordSetValue(recordRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstName), NULL);//添加名
    ABRecordSetValue(recordRef, kABPersonLastNameProperty, (__bridge CFTypeRef)(lastName), NULL);//添加姓
    
    ABMutableMultiValueRef multiValueRef =ABMultiValueCreateMutable(kABStringPropertyType);
    ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFStringRef)(workNumber), kABWorkLabel, NULL);
    ABRecordSetValue(recordRef, kABPersonPhoneProperty, multiValueRef, NULL);
    //保存记录，提交更改
    ABAddressBookSave(self.addressBook, NULL);
    //释放资源
    CFRelease(multiValueRef);
}

#pragma mark - UITableView数据源方法

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allPerson.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identtityKey=@"myTableViewCellIdentityKey1";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identtityKey];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identtityKey];
    }
    
    //取得1条人员记录
    ABRecordRef recordRef=(__bridge ABRecordRef)self.allPerson[indexPath.row];
   
    //取得记录中得信息
    NSString *firstName=(__bridge NSString *) ABRecordCopyValue(recordRef, kABPersonFirstNameProperty);//注意这里进行了强转，不用自己释放资源
    NSString *lastName=(__bridge NSString *)ABRecordCopyValue(recordRef, kABPersonLastNameProperty);
    ABMultiValueRef phoneNumbersRef= ABRecordCopyValue(recordRef, kABPersonPhoneProperty);//获取手机号，注意手机号是ABMultiValueRef类，有可能有多条
//    NSArray *phoneNumbers=(__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneNumbersRef);//取得CFArraryRef类型的手机记录并转化为NSArrary
    long count= ABMultiValueGetCount(phoneNumbersRef);
//    for(int i=0;i<count;++i){
//        NSString *phoneLabel= (__bridge NSString *)(ABMultiValueCopyLabelAtIndex(phoneNumbersRef, i));
//        NSString *phoneNumber=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, i));
//        NSLog(@"%@:%@",phoneLabel,phoneNumber);
//    }
    
    cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",firstName,lastName];
    
    if (count>0) {
        cell.detailTextLabel.text=(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phoneNumbersRef, 0));
    }
    
    if(ABPersonHasImageData(recordRef)){//如果有照片数据
        NSData *imageData= (__bridge NSData *)(ABPersonCopyImageData(recordRef));
        cell.imageView.image=[UIImage imageWithData:imageData];
    }else{
        cell.imageView.image=[UIImage imageNamed:@"avatar"];//没有图片使用默认头像
    }
    //使用cell的tag存储记录id
    cell.tag=ABRecordGetRecordID(recordRef);
    
    return cell;
}

#pragma mark - UITableView代理方法
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.isModify=1;
    self.selectedCell=[tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:@"AddPerson" sender:self];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"AddPerson"]){
        UINavigationController *navigationController=(UINavigationController *)segue.destinationViewController;
        //根据导航控制器取得添加/修改人员的控制器视图
        KCAddPersonViewController *addPersonController=(KCAddPersonViewController *)navigationController.topViewController;
        addPersonController.delegate=self;
        //如果是通过选择cell进行的导航操作说明是修改，否则为添加
        if (self.isModify) {
            UITableViewCell *cell=self.selectedCell;
            addPersonController.recordID=(ABRecordID)cell.tag;//设置
            
            
            NSArray *array=[cell.textLabel.text componentsSeparatedByString:@" "];
            
             if (array.count>0) {
                addPersonController.firstNameText=[array firstObject];
            }
            if (array.count>1) {
                addPersonController.lastNameText=[array lastObject];
            }
            addPersonController.workPhoneText=cell.detailTextLabel.text;
            
        }
    }
}


#pragma mark - KCContact代理方法
-(void)editPersonWithFirstName:(NSString *)firstName lastName:(NSString *)lastName workNumber:(NSString *)workNumber{
    if (self.isModify) {
        UITableViewCell *cell=self.selectedCell;
        NSIndexPath *indexPath= [self.tableView indexPathForCell:cell];
        [self modifyPersonWithRecordID:(ABRecordID)cell.tag firstName:firstName lastName:lastName workNumber:workNumber];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }else{
        [self addPersonWithFirstName:firstName lastName:lastName workNumber:workNumber];//通讯簿中添加信息
        [self initAllPerson];//重新初始化数据
        [self.tableView reloadData];
    }
    self.isModify=0;
}

-(void)cancelEdit{
    self.isModify=0;
}

#pragma mark - 私有方法
/**
 *  请求访问通讯录
 */
-(void)requestAddressBook{
    //创建通讯录对象
    self.addressBook=ABAddressBookCreateWithOptions(NULL, NULL);
    
    //请求访问用户通讯录,注意无论成功与否block都会调用
    ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
        if (!granted) {
            NSLog(@"未获得通讯录访问权限！");
        }
        [self initAllPerson];
        
    });
}
/**
 *  取得所有通讯录记录
 */
-(void)initAllPerson{
    //取得通讯录访问授权
    ABAuthorizationStatus authorization= ABAddressBookGetAuthorizationStatus();
      //如果未获得授权
    if (authorization!=kABAuthorizationStatusAuthorized) {
        NSLog(@"尚未获得通讯录访问授权！");
        return ;
    }
    //取得通讯录中所有人员记录
    CFArrayRef allPeople= ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    self.allPerson=(__bridge NSMutableArray *)allPeople;
    
    //释放资源
    CFRelease(allPeople);
}

@end
