//
//  MyActivityListViewController.m
//  iosapp
//
//  Created by 李萍 on 2017/1/19.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "MyActivityListViewController.h"
#import "OSCListItem.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCModelHandler.h"
#import "UIView+Common.h"

#import "OSCActivityTableViewCell.h"
#import "ActivityDetailViewController.h"
#import "ScanViewController.h"

#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MBProgressHUD.h>

static NSString * const activityReuseIdentifier = @"OSCActivityTableViewCell";
@interface MyActivityListViewController ()

@property (nonatomic, assign) long userId;
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *urlStr;
@property (nonatomic, strong) NSMutableDictionary *paramaters;
@property (nonatomic, copy) NSString *pageToken;

@property (nonatomic, strong) NSMutableArray <OSCListItem *> *activitys;

@end

@implementation MyActivityListViewController

- (instancetype)initWithAuthorID:(long)userID authorName:(NSString *)authorName
{
    self = [super init];
    if (self) {
        self.userId = userID;
        self.userName = authorName;
        
        _urlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_LIST];
        _paramaters = @{
                        @"authorId"   : @(userID),
//                        @"authorName" : authorName,
                        }.mutableCopy;
        _pageToken = @"";
        
        _activitys = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的活动";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCActivityTableViewCell" bundle:nil] forCellReuseIdentifier:activityReuseIdentifier];
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getFetchActivityData:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getFetchActivityData:NO];
    }];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView.mj_header beginRefreshing];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.tableView configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [self.tableView hideAllGeneralPage];
        
        [strongSelf getFetchActivityData:YES];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_discover_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(scanAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - get data
- (void)getFetchActivityData:(BOOL)isRefresh
{
    [self.tableView hideAllGeneralPage];
    
    if (!isRefresh && _pageToken && _pageToken.length > 0) {
        [_paramaters setObject:_pageToken forKey:@"pageToken"];
    }
    
    MBProgressHUD *HUD = [MBProgressHUD new];
    HUD.mode = MBProgressHUDModeCustomView;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:_urlStr
      parameters: _paramaters.copy
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if ([responseObject[@"code"] integerValue] == 1) {
                 NSDictionary *result = responseObject[@"result"];
                 
                 if (result && result.count > 0) {
                     _pageToken = result[@"nextPageToken"];
                     NSArray <OSCListItem *> *items = [NSArray osc_modelArrayWithClass:[OSCListItem class] json:result[@"items"]];
                     if (items && items.count > 0) {
                         if (isRefresh) {
                             _activitys = items.mutableCopy;
                             [self.tableView.mj_header endRefreshing];
                         } else {
                             [_activitys addObjectsFromArray:items];
                             [self.tableView.mj_footer endRefreshing];
                         }
                         if ([result[@"requestCount"] intValue] > [result[@"responseCount"] intValue]) {
                             [self.tableView.mj_footer endRefreshingWithNoMoreData];
                             self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                         } else {
                             [self.tableView.mj_footer endRefreshing];
                         }
                     } else {
                         if (isRefresh) {
                            [self.tableView.mj_header endRefreshing];
                         } else {
                             [self.tableView.mj_footer endRefreshingWithNoMoreData];
                             self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                         }
                     }
                 } else {
                     if (isRefresh) {
                         [self.tableView.mj_header endRefreshing];
                     } else {
                         [self.tableView.mj_footer endRefreshingWithNoMoreData];
                         self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                     }
                 }
                 
                 
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [HUD hideAnimated:YES];
                 if (self.activitys.count == 0) {
                     self.tableView.mj_footer.hidden = YES;
                     [self.tableView showBlankPageView];
                 }else{
                     self.tableView.mj_footer.hidden = NO;
                     [self.tableView hideBlankPageView];
                     [self.tableView reloadData];
                 }
             });
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (!(_activitys.count > 0)) {
                 [self.view showErrorPageView];
             } else {
                 HUD.label.text = @"网络异常，操作失败";
                 [HUD hideAnimated:YES afterDelay:0.3];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (isRefresh) {
                     [self.tableView.mj_header endRefreshing];
                 } else {
                     [self.tableView.mj_footer endRefreshing];
                 }
             });
         }
     ];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activitys.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSCActivityTableViewCell *cell = [OSCActivityTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:activityReuseIdentifier];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    if (_activitys.count > 0) {
        OSCListItem *listItem = self.activitys[indexPath.row];
        cell.listItem = listItem;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCListItem *activity = _activitys[indexPath.row];
    
    //新活动详情页面
    ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:activity.id];
    activityDetailCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityDetailCtl animated:YES];
}

#pragma mark - scanAction

- (void)scanAction:(UIButton *)button
{
    ScanViewController *scanVC = [ScanViewController new];
    UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
    [self.navigationController presentViewController:scanNav animated:NO completion:nil];
}


@end
