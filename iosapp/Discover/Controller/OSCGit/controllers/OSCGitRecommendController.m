//
//  OSCGitRecommendController.m
//  iosapp
//
//  Created by 王恒 on 17/3/2.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCGitRecommendController.h"
#import "OSCAPI.h"
#import "OSCModelHandler.h"
#import "OSCGitListModel.h"
#import "OSCGitListTableViewCell.h"
#import "OSCGitDetailController.h"


#import "AFHTTPRequestOperationManager+Util.h"
#import "NSObject+KitHock.h"
#import "UIColor+Util.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>

@interface OSCGitRecommendController ()<UITableViewDelegate,UITableViewDataSource>

{
    UITableView *_tableView;
    NSString *_requestURL;
    NSMutableDictionary *_paramerDic;
    NSMutableArray *_dataArray;
    
    NSString *_nextPageToken;
    NSString *_prevPageToken;
    
    NSInteger _pageNumber;
}

@end

@implementation OSCGitRecommendController

- (void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _requestURL = [NSString stringWithFormat:@"%@projects/featured/osc",OSCAPI_GIT_PREFIX];
    _pageNumber = 1;
    _paramerDic = [NSMutableDictionary dictionary];
    [self configSelf];
    [self addContentView];
    [_tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configSelf{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"码云推荐";
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)addContentView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getDataWithIsRefresh:YES];
    }];
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getDataWithIsRefresh:NO];
    }];
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
}

- (void)getDataWithIsRefresh:(BOOL)isRefresh{
    NSString *string = [_requestURL copy];
    if(isRefresh){
        _pageNumber = 1;
        string = [NSString stringWithFormat:@"%@?page=%ld",string,_pageNumber];
//        [_paramerDic setValue:@"" forKey:@"t"];
        _dataArray = [NSMutableArray array];
    }else{
        _pageNumber ++ ;
        string = [NSString stringWithFormat:@"%@?page=%ld",string,_pageNumber];
//        [_paramerDic setValue:_nextPageToken forKey:@"t"];
    }
    
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manager GET:string parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            NSArray *dataArray = [NSArray osc_modelArrayWithClass:[OSCGitListModel class] json:responseObject[@"result"]];
            for (OSCGitListModel *model in dataArray) {
                [model calculateLayoutWithCurTweetCellWidth:kScreenSize.width];
                [_dataArray addObject:model];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (dataArray.count == 0) {
                    if (isRefresh) {
                        MBProgressHUD *hud = [weakSelf getHUDWithView:self.view withString:@"没有数据" withMBPMode:MBProgressHUDModeText];
                        [hud hideAnimated:YES afterDelay:2.0];
                        [weakSelf.view addSubview:hud];
                        [_tableView.mj_header endRefreshing];
                    }else{
                        [_tableView.mj_footer endRefreshingWithNoMoreData];
                    }
                }else{
                    [_tableView.mj_header endRefreshing];
                    [_tableView.mj_footer endRefreshing];
                    [_tableView reloadData];
                }
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [weakSelf getHUDWithView:self.view withString:@"网络连接失败" withMBPMode:MBProgressHUDModeText];
                [hud hideAnimated:YES afterDelay:2.0];
                [weakSelf.view addSubview:hud];
                [_tableView.mj_header endRefreshing];
                [_tableView.mj_footer endRefreshing];
            });
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [weakSelf getHUDWithView:self.view withString:@"网络连接失败" withMBPMode:MBProgressHUDModeText];
            [hud hideAnimated:YES afterDelay:2.0];
            [weakSelf.view addSubview:hud];
            [_tableView.mj_header endRefreshing];
            [_tableView.mj_footer endRefreshing];
        });
    }];
}

- (MBProgressHUD *)getHUDWithView:(__kindof UIView *)view
                       withString:(NSString *)string withMBPMode:(MBProgressHUDMode)MBPMode{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBPMode;
    hud.label.text = string;
    [hud showAnimated:YES];
    hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    OSCGitListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[OSCGitListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.model = _dataArray[indexPath.row];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor  selectCellSColor];
    return cell;
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCGitListModel *model = _dataArray[indexPath.row];
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCGitListModel *model = _dataArray[indexPath.row];
    OSCGitDetailController *detailVC = [[OSCGitDetailController alloc] initWithProjectID:model.id];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
