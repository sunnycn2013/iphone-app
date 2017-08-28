//
//  OSCMessageController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMessageController.h"
#import "OSCMessageCell.h"
#import "OSCMessageCenter.h"
#import "OSCUserHomePageController.h"
#import "BubbleChatViewController.h"
#import "OSCPrivateChatController.h"
#import "OSCModelHandler.h"
#import "OSCListItem.h"
#import "OSCMsgCount.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UINavigationController+Comment.h"
#import "UIColor+Util.h"
#import "NSObject+Comment.h"

#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MBProgressHUD.h>

#define MESSAGE_CELL_ROW 76

static NSString* const messageCellIdentifier = @"OSCMessageCell";

@interface OSCMessageController ()<UITableViewDelegate,UITableViewDataSource,OSCMessageCellDelegate>

@property (nonatomic,strong) UITableView* tableView;

@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,strong) NSString* nextToken;
@property (nonatomic,strong) MBProgressHUD* HUD;

@property (nonatomic,strong) NSString* strUrl;

@end

@implementation OSCMessageController

- (instancetype)init{
    self = [super init];
    if (self) {
        _strUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX, OSCAPI_MESSAGES_LIST];
        
        [self getCache];
    }
    return self;
}
- (void)getCache{
    NSString *resourceName = [NSObject cacheResourceNameWithURL:_strUrl parameterDictionaryDesc:nil];
    NSDictionary *response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_notice];
    NSArray *items = response[@"items"];
    NSString *pageToken = response[@"nextPageToken"];
    if(items && items.count > 0){
        _dataSource = [NSArray osc_modelArrayWithClass:[MessageItem class] json:items].mutableCopy;
    }
    if (pageToken && pageToken.length > 0) {
        _nextToken = pageToken;
    }
}

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCMessageCell" bundle:nil] forCellReuseIdentifier:messageCellIdentifier];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getDataThroughDropdown:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getDataThroughDropdown:NO];
    }];

    if (self.dataSource && self.dataSource.count > 0) {
        self.tableView.mj_header.state = MJRefreshStateRefreshing;
        
        [self.tableView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.mj_header.state = MJRefreshStateIdle;
            
            NSTimeInterval saveTimeInterval = [(NSDate* )[[NSUserDefaults standardUserDefaults] objectForKey:userDefault_letter_key_updateTime] timeIntervalSince1970];
            NSTimeInterval fileCreatTimeInterval = [NSObject getFileCreatDateWithResourceName:[NSObject cacheResourceNameWithURL:_strUrl parameterDictionaryDesc:nil] cacheType:SandboxCacheType_notice].timeIntervalSince1970;
            if (fileCreatTimeInterval > saveTimeInterval) {
                [NSObject settingTagHasBeenRead:MsgCountTypeLetter];
            }
        });
    }else{
        [self.tableView.mj_header beginRefreshing];
    }
}


#pragma mark --- Network 
- (void)getDataThroughDropdown:(BOOL)dropDown{//YES:下拉   NO:上拉

    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSMutableDictionary *paraMutableDic = @{}.mutableCopy;
    if (!dropDown && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }

    [manager GET:_strUrl
      parameters:paraMutableDic.copy
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if([responseObject[@"code"]integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray* items = resultDic[@"items"];
                 if (dropDown && items && items.count > 0) {
                     [self.dataSource removeAllObjects];
                 }
                 NSArray* models = [NSArray osc_modelArrayWithClass:[MessageItem class] json:items];
                 [self.dataSource addObjectsFromArray:models];
                 self.nextToken = resultDic[@"nextPageToken"];
                 
                 /*存入缓存*/
                 if (models && models.count > 0 && dropDown) {
                     NSString* resourceName = [NSObject cacheResourceNameWithURL:_strUrl parameterDictionaryDesc:nil];
                     [NSObject handleResponseObject:resultDic resource:resourceName cacheType:SandboxCacheType_notice];
                     [NSObject settingTagHasBeenRead:MsgCountTypeLetter];
                 }
                 
             }else{
                 _HUD = [Utils createHUD];
                 _HUD.label.text = @"未知错误";
                 [_HUD hideAnimated:YES afterDelay:0.3];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (dropDown) {
                     [self.tableView.mj_header endRefreshing];
                 }else{
                     [self.tableView.mj_footer endRefreshing];
                 }
                 [self.tableView reloadData];
             });
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (dropDown) {
                     [self.tableView.mj_header endRefreshing];
                 }else{
                     [self.tableView.mj_footer endRefreshing];
                 }
                 _HUD = [Utils createHUD];
                 _HUD.label.text = @"网络异常，操作失败";
                 [_HUD hideAnimated:YES afterDelay:0.3];
             });
    }];
}


#pragma mark --- UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCMessageCell* cell = [OSCMessageCell returnReuseMessageCellWithTableView:tableView indexPath:indexPath identifier:messageCellIdentifier];
    cell.messageItem = self.dataSource[indexPath.row];
    cell.delegate = self;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MessageItem* msgItem = self.dataSource[indexPath.row];
    OSCAuthor* author = [OSCAuthor new];
    author.id = msgItem.sender.id;
    author.name = msgItem.sender.name;
    author.portrait = msgItem.sender.portrait;
    BubbleChatViewController* vc = [[BubbleChatViewController alloc] initWithUser:author];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark --- OSCMessageCellDelegate
- (void)messageCellDidClickUserPortrait:(OSCMessageCell *)cell{
    MessageItem* messageItem = cell.messageItem;
    if (messageItem.sender.id > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:messageItem.sender.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}


#pragma mark --- lazy loading
- (UITableView *)tableView {
	if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,self.view.bounds.size.height - 100}} style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = MESSAGE_CELL_ROW;
        _tableView.scrollsToTop = YES;
        _tableView.tableFooterView = [UIView new];
	}
	return _tableView;
}
- (NSMutableArray *)dataSource {
	if(_dataSource == nil) {
		_dataSource = [[NSMutableArray alloc] init];
	}
	return _dataSource;
}

@end
