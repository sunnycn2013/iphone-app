//
//  OSCCodeSnippetViewController.m
//  iosapp
//
//  Created by wupei on 2017/5/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCCodeSnippetViewController.h"
#import "OSCAPI.h"
#import "OSCModelHandler.h"
#import "UIColor+Util.h"

#import "OSCCodeSnippetListTableViewCell.h"
#import "OSCCodeSnippetListModel.h"
#import "OSCGitListTableViewCell.h"
#import "OSCCodeSnippetDetailController.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "NSObject+KitHock.h"


#import <MJRefresh.h>
#import <MBProgressHUD.h>


@interface OSCCodeSnippetViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSString *requestURL;

@property (nonatomic, copy) NSMutableDictionary *paramerDic;
@property (nonatomic, copy) NSMutableArray *dataArray;
@property (nonatomic, copy) NSString *nextPageToken;
@property (nonatomic, copy) NSString *prevPageToken;

@property (nonatomic, assign) NSInteger pageNumber;

@end

@implementation OSCCodeSnippetViewController

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    _requestURL = [NSString stringWithFormat:@"%@%@",OSCAPI_GIT_PREFIX,OSCAPI_GISTS_PUBLIC];
    _pageNumber = 1;
    //    _paramerDic = [NSMutableDictionary dictionary];
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
    self.navigationItem.title = @"代码片段";
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
            NSArray *dataArray = [NSArray osc_modelArrayWithClass:[OSCCodeSnippetListModel class] json:responseObject[@"result"]];
            
            for (OSCCodeSnippetListModel *model in dataArray) {
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
    OSCCodeSnippetListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[OSCCodeSnippetListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.model = _dataArray[indexPath.row];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCCodeSnippetListModel *model = _dataArray[indexPath.row];
    return model.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCCodeSnippetListModel *model = _dataArray[indexPath.row];
    OSCCodeSnippetDetailController *detailVC = [[OSCCodeSnippetDetailController alloc] initWithContentIdStr:model.id_str];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
