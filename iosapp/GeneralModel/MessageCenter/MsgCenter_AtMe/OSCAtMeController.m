//
//  OSCAtMeController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCAtMeController.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "OSCPushTypeControllerHelper.h"
#import "OSCAtMeCell.h"
#import "OSCMessageCenter.h"
#import "OSCUserHomePageController.h"
#import "OSCModelHandler.h"
#import "OSCTweetAtMeCell.h"
#import "OSCMsgCount.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UINavigationController+Comment.h"
#import "NSObject+Comment.h"
#import "UIColor+Util.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>

#define ATME_HEIGHT 150

static NSString* const OSCAtMeCellReuseIdentifier = @"OSCAtMeCell";
static NSString * const OSCTweetAtMeReuseIdentifier = @"OSCTweetAtMeCell";
@interface OSCAtMeController ()<UITableViewDelegate,UITableViewDataSource,OSCAtMeCellDelegate>

@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataSource;
@property (nonatomic,strong) NSString* nextToken;
@property (nonatomic,strong) MBProgressHUD* HUD;

@property (nonatomic, strong) NSString *strUrl;

@end

@implementation OSCAtMeController

- (instancetype)init{
    self = [super init];
    if (self) {
        _strUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_MESSAGES_ATME_LIST];
        
        [self getCache];
    }
    return self;
}
- (void)getCache{
    NSString* resourceName = [NSObject cacheResourceNameWithURL:_strUrl parameterDictionaryDesc:nil];
    NSDictionary* response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_notice];
    NSArray* items = response[@"items"];
    NSString* pageToken = response[@"nextPageToken"];
    if (items && items.count > 0) {
        NSArray *modelArray = [NSArray osc_modelArrayWithClass:[AtMeItem class] json:items];
        self.dataSource = modelArray.mutableCopy;
        
    }
    if (pageToken && pageToken.length > 0) {
        self.nextToken = pageToken;
    }
}

#pragma mark --- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCAtMeCell" bundle:nil] forCellReuseIdentifier:OSCAtMeCellReuseIdentifier];
    [self.tableView registerClass:[OSCTweetAtMeCell class] forCellReuseIdentifier:OSCTweetAtMeReuseIdentifier];
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
            
            NSTimeInterval saveTimeInterval = [(NSDate* )[[NSUserDefaults standardUserDefaults] objectForKey:userDefault_mention_key_updateTime] timeIntervalSince1970];
            NSTimeInterval fileCreatTimeInterval = [NSObject getFileCreatDateWithResourceName: [NSObject cacheResourceNameWithURL:_strUrl parameterDictionaryDesc:nil] cacheType:SandboxCacheType_notice].timeIntervalSince1970;
            if (fileCreatTimeInterval > saveTimeInterval) {
                [NSObject settingTagHasBeenRead:MsgCountTypeMention];
            }
        });
    }else{
        [self.tableView.mj_header beginRefreshing];
    }
}


#pragma mark --- Networking
- (void)getDataThroughDropdown:(BOOL)dropDown{//YES:下拉  NO:上拉
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
                 NSArray *models = [NSArray osc_modelArrayWithClass:[AtMeItem class] json:items];
                 [self.dataSource addObjectsFromArray:models];
                 self.nextToken = resultDic[@"nextPageToken"];
                 
                 if (models && models.count > 0 && dropDown) {
                     NSString* resourceName = [NSObject cacheResourceNameWithURL:_strUrl parameterDictionaryDesc:nil];
                     [NSObject handleResponseObject:resultDic resource:resourceName cacheType:SandboxCacheType_notice];
                     [NSObject settingTagHasBeenRead:MsgCountTypeMention];
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
    AtMeItem *item = self.dataSource[indexPath.row];
    if (item.origin.desc.length > 0){
        OSCAtMeCell* cell = [OSCAtMeCell returnReuseAtMeCellWithTableView:tableView indexPath:indexPath identifier:OSCAtMeCellReuseIdentifier];
        cell.atMeItem = item;
        cell.delegate = self;
        return cell;
    }else{
        OSCTweetAtMeCell* cell = [tableView dequeueReusableCellWithIdentifier:OSCTweetAtMeReuseIdentifier forIndexPath:indexPath];
        cell.item = item;
        cell.delegate = self;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AtMeItem* atMeItem = self.dataSource[indexPath.row];
    [self pushController:atMeItem];
}

#pragma mark --- OSCAtMeCellDelegate
- (void)atMeCellDidClickUserPortrait:(__kindof UITableViewCell *)cell{
    AtMeItem* atMeItem;
    if ([cell isKindOfClass:[OSCAtMeCell class]]) {
        OSCAtMeCell *atMeCell = (OSCAtMeCell *)cell;
        atMeItem = atMeCell.atMeItem;
    }else if([cell isKindOfClass:[OSCTweetAtMeCell class]]){
        OSCTweetAtMeCell *atMeCell = (OSCTweetAtMeCell *)cell;
        atMeItem = atMeCell.item;
    }
    if (atMeItem.author.id > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:atMeItem.author.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}
- (void) shouldInteractTextView:(UITextView* )textView
                            URL:(NSURL *)URL
                        inRange:(NSRange)characterRange
{
    NSString* nameStr = [textView.text substringWithRange:characterRange];
    if ([[nameStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"@"]) {
        nameStr = [nameStr substringFromIndex:1];
        [self.navigationController handleURL:URL name:nameStr];
    }else{
        [self.navigationController handleURL:URL name:nil];
    }
}
- (void)textViewTouchPointProcessing:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.tableView];
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
}

#pragma mark --- push type controller
- (void)pushController:(AtMeItem* )atMeItem{
    UIViewController* pushVC = [OSCPushTypeControllerHelper pushControllerGeneralWithType:atMeItem.origin.type detailContentID:atMeItem.origin.id];
    if (pushVC == nil) {
        [self.navigationController handleURL:[NSURL URLWithString:atMeItem.origin.href] name:nil];
    }else{
        [self.navigationController pushViewController:pushVC animated:YES];
    }
}

#pragma mark --- lazy loading
- (UITableView *)tableView {
	if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,self.view.bounds.size.height - 100}} style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = ATME_HEIGHT;
        _tableView.rowHeight = UITableViewAutomaticDimension;
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
