//
//  SYAddSubAccountViewController.m
//  YLB
//
//  Created by sayee on 17/3/29.
//  Copyright © 2017年 yuanweihao. All rights reserved.
//

#import "SYAddSubAccountViewController.h"
//#import "MJRefresh.h"
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
#import "SYAddSubAccountTableViewCell.h"
#import "SYContactsModel.h"
#import "SYSubAccountInfoViewController.h"
#import "SYConfigInfoModel.h"

@interface SYAddSubAccountViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *contactsArrm;
@property (nonatomic, retain) NSMutableArray *sourceArr;
@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, strong) SipInfoModel *sipInfoModel;
@property (nonatomic, retain) UISearchBar *searchBar;
//@property (nonatomic, copy) void(^addressBookChangedHandler)();
@end

@implementation SYAddSubAccountViewController

- (instancetype)initWitSipInfoModel:(SipInfoModel *)sipInfoModel{
    if (self = [super init]) {
        self.sipInfoModel = sipInfoModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initData];
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    ABAddressBookUnregisterExternalChangeCallback(self.addressBook, addressBookChangedBlock, nil);
}


#pragma mark - private
void addressBookChangedBlock (ABAddressBookRef addressBok,
                              CFDictionaryRef info,
                              void *context
                              )
{
    NSLog(@"=======通讯录修改了========");
}


- (void)initData{
    
    self.contactsArrm = [[NSMutableArray alloc] init];
    self.sourceArr = [[NSMutableArray alloc] init];
    [self getContactsList];
}

- (void)initUI{
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0xebebeb);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width - 70, 30)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.layer.cornerRadius = 5;
    titleView.clipsToBounds = YES;
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, titleView.width, titleView.height)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = @"搜索";
    [titleView addSubview:self.searchBar];
    
    self.navigationItem.titleView = titleView;
    
//    WEAK_SELF;
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//       
//        [weakSelf.tableView.mj_header endRefreshing];
//    }];
}

- (void)getContactsList{
    
    [self showWithContent:nil];
    WEAK_SELF;
    //AddressBookUI.framework ios9弃用了 （不过在iOS9系统上依然可以获得联系人信息）
    if (isAfteriOS9) {
        //通讯录改变监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsChange:) name:CNContactStoreDidChangeNotification object:nil];
        
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if(status == CNAuthorizationStatusNotDetermined){
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if (!granted) {
                    NSLog(@"通讯录授权失败, error=%@", error);
                }else{
                    [weakSelf getContacts];
                }
            }];
        }
        else if (status == CNAuthorizationStatusAuthorized){
            [self getContacts];
        }
    }else{
  
        ABAuthorizationStatus authorizationStatus = ABAddressBookGetAuthorizationStatus();
        if (authorizationStatus == kABAuthorizationStatusNotDetermined) {
            // 请求授权
            if (self.addressBook == NULL) {
                self.addressBook = ABAddressBookCreate();
            }
            ABAddressBookRequestAccessWithCompletion(self.addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    [weakSelf getAddressBooks];
                }else {
                    NSLog(@"通讯录授权失败, error=%@", error);
                }
            });
        }
        else if (authorizationStatus == kABAuthorizationStatusAuthorized){
            [self getAddressBooks];
        }
    }
}

//Contact.framework
- (void)getContacts{
    
    WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactPhoneNumbersKey, CNContactFamilyNameKey];
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        [weakSelf.contactsArrm removeAllObjects];
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            
            for (CNLabeledValue *labelValue in contact.phoneNumbers) {
                
                CNPhoneNumber *phoneNumber = labelValue.value;
                SYContactsModel *contactsModel = [[SYContactsModel alloc] init];
                contactsModel.firstNameStr = contact.givenName ? : @""; //名字
                contactsModel.lastNameStr = contact.familyName ? : @"";    //姓
                if (phoneNumber.stringValue) {
                    contactsModel.phoneNumberStr = [phoneNumber.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
                }
                contactsModel.fullNameStr = [NSString stringWithFormat:@"%@%@",contactsModel.lastNameStr, contactsModel.firstNameStr];
                [weakSelf.contactsArrm addObject:contactsModel];
            }
        }];
        
        @synchronized (weakSelf.sourceArr) {
            [weakSelf.sourceArr removeAllObjects];
            [weakSelf.sourceArr addObjectsFromArray:weakSelf.contactsArrm];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
        [weakSelf dismissHud:YES];
    });
}

//ddressBook.framework
- (void)getAddressBooks{
    
    WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        ABAddressBookRef addressBookRef = ABAddressBookCreate();
        CFArrayRef arrayRef = ABAddressBookCopyArrayOfAllPeople(addressBookRef);
        long count = CFArrayGetCount(arrayRef);
        
        if (weakSelf.addressBook == NULL) {
            weakSelf.addressBook = ABAddressBookCreate();
        }
        ABAddressBookRegisterExternalChangeCallback(weakSelf.addressBook, addressBookChangedBlock, (__bridge void *)(self));    //通讯录改变监听
        
            [weakSelf.contactsArrm removeAllObjects];
            for (int i = 0; i < count; i++) {
                //获取联系人对象的引用
                ABRecordRef people = CFArrayGetValueAtIndex(arrayRef, i);
                //获取当前联系人名字
                NSString *firstName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
                //获取当前联系人姓氏
                NSString *lastName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
                //获取当前联系人的电话 数组
                ABMultiValueRef phones = ABRecordCopyValue(people, kABPersonPhoneProperty);
                
                for (NSInteger j = 0; j<ABMultiValueGetCount(phones); j++) {
                    
                    NSString *phoneNumber = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j));
                    SYContactsModel *contactsModel = [[SYContactsModel alloc] init];
                    contactsModel.firstNameStr = firstName ? : @""; //名字
                    contactsModel.lastNameStr = lastName ? : @"";    //姓
                    if (phoneNumber) {
                        contactsModel.phoneNumberStr = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    }
                    contactsModel.fullNameStr = [NSString stringWithFormat:@"%@%@",contactsModel.lastNameStr, contactsModel.firstNameStr];
                    [weakSelf.contactsArrm addObject:contactsModel];
                }

                @synchronized (weakSelf.sourceArr) {
                    [weakSelf.sourceArr removeAllObjects];
                    [weakSelf.sourceArr addObjectsFromArray:weakSelf.contactsArrm];
                }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
        [weakSelf dismissHud:YES];
    });
}


#pragma mark - notification
- (void)contactsChange:(NSNotification *)noti{
    NSLog(@"==contactsChange=====%@",[noti userInfo]);
    [self getContacts];
}


#pragma mark - tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return SYAddSubAccountTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identify = @"SYAddSubAccountTableViewCell";
    
    SYAddSubAccountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[SYAddSubAccountTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (self.sourceArr.count > indexPath.row) {
        [cell updateData:[self.sourceArr objectAtIndex:indexPath.row]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.searchBar resignFirstResponder];
    if (self.sourceArr.count > indexPath.row) {
        SYContactsModel *contactsModel = [self.sourceArr objectAtIndex:indexPath.row];
        SYSubAccountInfoViewController *subAccountInfoViewController = [[SYSubAccountInfoViewController alloc] initWithNickName:contactsModel.fullNameStr PhoneNumber:contactsModel.phoneNumberStr SipInfoModel:self.sipInfoModel];
        [FrameManager pushViewController:subAccountInfoViewController animated:YES];
    }
}


#pragma mark - scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
     [self.searchBar resignFirstResponder];
}


#pragma mark - UISearchBar delegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{

    if (searchText.length == 0) {
        
        @synchronized (self.sourceArr) {
            [self.sourceArr removeAllObjects];
            [self.sourceArr addObjectsFromArray:self.contactsArrm];
        }
    }else{

        NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
        for (SYContactsModel *contactsModel in self.contactsArrm) {

            //搜索不到则显示输入的号码
            if ([contactsModel.phoneNumberStr rangeOfString:searchText].location == NSNotFound) {
              
                if ([contactsModel.fullNameStr rangeOfString:searchText].location == NSNotFound) {
                    
                }else{
                    [arrTmp addObject:contactsModel];
                }
            }
            else{
                [arrTmp addObject:contactsModel];
            }
        }
        
        @synchronized (self.sourceArr) {
            [self.sourceArr removeAllObjects];
            if (arrTmp.count == 0) {
                SYContactsModel *tmpModel = [[SYContactsModel alloc] init];
                tmpModel.phoneNumberStr = searchText;
                tmpModel.fullNameStr = searchText;
                [self.sourceArr addObject:tmpModel];
            }
            else{
                [self.sourceArr addObjectsFromArray:arrTmp];
            }
        }
    }

    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
}
@end
