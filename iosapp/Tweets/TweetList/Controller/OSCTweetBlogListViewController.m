//
//  OSCTweetBlogListViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/12/5.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetBlogListViewController.h"
#import "OSCPushTypeControllerHelper.h"
#import "UsualTableViewCell.h"
#import "OSCBlogCell.h"

#import "Utils.h"
#import "OSCAPI.h"
#import "OSCMenuItem.h"
#import "OSCListItem.h"
#import "OSCModelHandler.h"
#import "NSObject+Comment.h"
#import "UIView+Common.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>

@interface OSCTweetBlogListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *parametersDic;
@property (nonatomic, copy) NSString *requestUrl;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSString *pageToken;

@end

@implementation OSCTweetBlogListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataSource = [NSMutableArray new];
        
        self.requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX, OSCAPI_INFORMATION_LIST];
        self.parametersDic = @{@"token" : OSCAPI_TWEET_BLOG_LIST}.mutableCopy;
        
        [self getCacheDataWithRequestUrl:self.requestUrl paraDescription:self.parametersDic.description];
    }
    return self;
}

#pragma mark - Cache plist
- (void)getCacheDataWithRequestUrl:(NSString* )requestUrl
                   paraDescription:(NSString* )paraDesc
{
    NSString* resourceName = [NSObject cacheResourceNameWithURL:requestUrl parameterDictionaryDesc:paraDesc];
    NSDictionary* response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_list];
    NSArray* items = response[@"items"];
    NSString* pageToken = response[@"nextPageToken"];
    if (items && items.count > 0) {
        NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCListItem class] json:items];
        for (OSCListItem* listItem in modelArray) {
            listItem.menuItem = [self newTweetBlogMenuItem];
            [listItem getLayoutInfo];
            [self.dataSource addObject:listItem];
        }
    }
    if (pageToken && pageToken.length > 0) {
        self.pageToken = pageToken;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerClass:[OSCBlogCell class] forCellReuseIdentifier:kNewHotBlogTableViewCellReuseIdentifier];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self sendRequestGetListData:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self sendRequestGetListData:NO];
    }];
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - post datasource
//YES:下拉获取最新数据  NO:上拉带token加载更多
- (void)sendRequestGetListData:(BOOL)isRefresh{
    NSMutableDictionary* paraMutableDic = self.parametersDic.mutableCopy;
    
    if (!isRefresh && _pageToken.length > 0) {
        [paraMutableDic setValue:_pageToken forKey:@"pageToken"];
    } else {
        self.tableView.mj_footer.state = MJRefreshStateIdle;
    }
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
    manger.requestSerializer.timeoutInterval = 20;
    [manger GET:self.requestUrl
     parameters:paraMutableDic
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSDictionary* resultDic = responseObject[@"result"];
            NSArray* items = resultDic[@"items"];
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCListItem class] json:items];
                for (OSCListItem* listItem in modelArray) {
                    listItem.menuItem = [self newTweetBlogMenuItem];
                    [listItem getLayoutInfo];
                }
                
                if (modelArray && modelArray.count > 0 && isRefresh) {
                    [self.dataSource removeAllObjects];
                }
                [self.dataSource addObjectsFromArray:modelArray];
                NSString* pageToken = resultDic[@"nextPageToken"];
                if (pageToken && pageToken.length > 0) {
                    _pageToken = pageToken;
                }
            }
            
            /**items cache buffer */
            if (items && items.count > 0 && isRefresh) {
                NSString* resourceName = [NSObject cacheResourceNameWithURL:self.requestUrl parameterDictionaryDesc:[self.parametersDic.copy description]];
                [NSObject handleResponseObject:resultDic resource:resourceName cacheType:SandboxCacheType_list];
            }
            /***********************/
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultDic == nil || items == nil || items.count < 1) {
                    if (isRefresh) {
                        [self.tableView.mj_header endRefreshing];
                        if (!self.dataSource || self.dataSource.count == 0) {
                            [self.tableView showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"这里没找到数据呢"];
                        }
                    } else {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                } else {
                    [self.tableView hideCustomPageView];
                    if (isRefresh) {
                        [self.tableView.mj_header endRefreshing];
                    }else{
                        [self.tableView.mj_footer endRefreshing];
                    }
                }
                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            } else {
                [self.tableView.mj_footer endRefreshing];
            }
            if (!self.dataSource || self.dataSource.count == 0) {
                [self.tableView showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"这里没找到数据呢"];
            }
        }];
}

-(OSCMenuItem *)newTweetBlogMenuItem
{
    OSCMenuItem *item = [OSCMenuItem new];
    item.type = InformationTypeBlog;
    item.subtype = @"5";
    item.token = OSCAPI_TWEET_BLOG_LIST;
    
    return item;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSource.count > 0) {
        OSCListItem* listItem = self.dataSource[indexPath.row];
        UsualTableViewCell *curTableView = [tableView dequeueReusableCellWithIdentifier:kNewHotBlogTableViewCellReuseIdentifier forIndexPath:indexPath];
        [curTableView setValue:listItem forKey:@"listItem"];
        
        curTableView.selectedBackgroundView = [[UIView alloc] initWithFrame:curTableView.frame];
        curTableView.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return curTableView;
    } else {
        return [UITableViewCell new];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataSource.count > 0) {
        return self.dataSource.count;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource.count > 0) {
        OSCListItem *listItem = self.dataSource[indexPath.row];
        return listItem.rowHeight;
        
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCListItem *listItem = self.dataSource[indexPath.row];
    UIViewController* curVC = [OSCPushTypeControllerHelper pushControllerGeneralWithType:listItem.type detailContentID:listItem.id];
    [self.navigationController pushViewController:curVC animated:YES];
}


@end
