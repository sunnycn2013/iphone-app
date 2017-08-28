//
//  OSCNetWorkContactController.m
//  iosapp
//
//  Created by Graphic-one on 16/12/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNetWorkContactController.h"
#import "OSCAPI.h"
#import "OSCListItem.h"
#import "OSCNetWorkSearchCell.h"
#import "OSCModelHandler.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIView+Common.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>

@interface OSCNetWorkContactController ()
{
    __weak MBProgressHUD* _hud;
}

@property (nonatomic,strong) NSMutableArray<OSCAuthor* >* dataSourceArr;

@end

@implementation OSCNetWorkContactController
{
    NSString* _requestUrl;
    NSDictionary* _paramaterDic;
    
    NSString* _nextToken;
}

- (instancetype)initWithSearchKey:(nonnull NSString* )key
{
    self = [super init];
    if (self) {
        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_SEARCH];
        _paramaterDic = @{
                          @"catalog"    :   @(11),
                          @"content"    :   key,
                          };
        _nextToken = nil;
        _dataSourceArr = [NSMutableArray arrayWithCapacity:40];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.title = @"网络搜索";

    self.tableView.rowHeight = 52;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    self.tableView.separatorColor = [self.tableView.separatorColor colorWithAlphaComponent:0.6];
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCNetWorkSearchCell" bundle:nil] forCellReuseIdentifier:OSCNetWorkSearchCellReuseIdentifier];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self sendRequestWithRefresh:NO];
    }];

    [self sendRequestWithRefresh:YES];
}


#pragma mark --- sendRequest
/**  入参YES:不带token  入参NO:带token  */
- (void)sendRequestWithRefresh:(BOOL)isRefresh{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSMutableDictionary* mutableDic = _paramaterDic.mutableCopy;
    if (!isRefresh && _nextToken && _nextToken.length > 0) {
        [mutableDic setValue:_nextToken forKey:@"pageToken"];
    }
    
    [manger GET:_requestUrl
     parameters:mutableDic.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                
                if (result && result.count > 0) {
                    _nextToken = result[@"nextPageToken"];
                    NSArray<OSCAuthor* >* authors = [NSArray osc_modelArrayWithClass:[OSCAuthor class] json:result[@"items"]];
                    if (authors && authors.count > 0) {
                        if (isRefresh) {
                            _dataSourceArr = authors.mutableCopy;
                        } else {
                            [_dataSourceArr addObjectsFromArray:authors];
                            [self.tableView.mj_footer endRefreshing];
                        }
                        if ([result[@"requestCount"] intValue] > [result[@"responseCount"] intValue]) {
                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
                            self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                        } else {
                            [self.tableView.mj_footer endRefreshing];
                        }
                    } else {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                        self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                    }
                } else {
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
                }
                
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_hud hideAnimated:YES];
                if (self.dataSourceArr.count == 0) {
                    self.tableView.mj_footer.hidden = YES;
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    [self.tableView showBlankPageView];
                }else{
                    self.tableView.mj_footer.hidden = NO;
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    [self.tableView hideBlankPageView];
                    [self.tableView reloadData];
                }
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            [_hud hideAnimated:YES];
            if (self.dataSourceArr.count == 0) {
                self.tableView.mj_footer.hidden = YES;
                self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                [self.tableView showBlankPageView];
            }
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSCNetWorkSearchCell* cell = [tableView dequeueReusableCellWithIdentifier:OSCNetWorkSearchCellReuseIdentifier forIndexPath:indexPath];
    cell.author = self.dataSourceArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCNetWorkSearchCell* curCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(netWorkContactController:selectedUser:)]) {
        [_delegate netWorkContactController:self selectedUser:curCell.author];
    }
}

@end
