//
//  FavoritesViewController.m
//  iosapp
//
//  Created by ChanAetern on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "FavoritesViewController.h"

#import "Config.h"
#import "Utils.h"
#import "OSCNews.h"
#import "OSCBlog.h"
#import "OSCPost.h"
#import "OSCModelHandler.h"

#import "FavoritesCell.h"
#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "ActivityDetailViewController.h"
#import "TranslationViewController.h"
#import "NewBlogDetailController.h"
#import "OSCInformationDetailController.h"

#import "UIView+Common.h"

#import <MBProgressHUD.h>
#import <MJRefresh.h>

static NSString * const kFavoriteCellID = @"FavoritesCell";

@interface FavoritesViewController ()

@property (nonatomic, strong) NSMutableArray *dataModels;
@property (nonatomic, assign) FavoritesType favoritesType;
@property (nonatomic, copy) NSString *pageToken;

@end


@implementation FavoritesViewController

- (instancetype)initWithFavoritesType:(FavoritesType)favoritesType
{
    self = [super init];
    if (self) {
        self.favoritesType = favoritesType;
        self.dataModels = [NSMutableArray array];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
    });
}

- (NSString *)title {
    return @"收藏";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"收藏";
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoritesCell" bundle:nil] forCellReuseIdentifier:kFavoriteCellID];
    
    self.tableView.estimatedRowHeight = 65;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView.mj_header beginRefreshing];
    [self getJsonDataWithRefresh:YES];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getJsonDataWithRefresh:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getJsonDataWithRefresh:NO];
    }];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.tableView configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [self.tableView hideAllGeneralPage];
        
        [strongSelf getJsonDataWithRefresh:YES];

    }];
}

#pragma mark - 获取数据
-(void)getJsonDataWithRefresh:(BOOL)isRefresh
{
    [self.tableView hideAllGeneralPage];
    
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    [paraMutableDic setObject:@(self.favoritesType) forKey:@"catalog"];
    if (!isRefresh && [self.pageToken length] > 0) {//下拉刷新请求
        [paraMutableDic setObject:self.pageToken forKey:@"pageToken"];
    }
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_FAVORITES];
    
    [manager GET:strUrl
           parameters:paraMutableDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  NSMutableArray *modelArray = [NSMutableArray new];
                  if([responseObject[@"code"] integerValue] == 1) {
                      NSDictionary *resultDic = responseObject[@"result"];
                      
                      modelArray = [NSArray osc_modelArrayWithClass:[OSCFavorites class] json:resultDic[@"items"]].mutableCopy;
                      if (isRefresh) {//下拉得到的数据
                          [self.dataModels removeAllObjects];
                      }
                      
                      [self.dataModels addObjectsFromArray:modelArray];
                      self.pageToken = resultDic[@"nextPageToken"];
                      
                  } else {
                      if (self.dataModels.count == 0) {
                          [self.tableView showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"没有数据哦！！"];
                      }
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (isRefresh) {
                          [self.tableView.mj_header endRefreshing];
                      } else {
                          if (modelArray.count < 1) {
                              [self.tableView.mj_footer endRefreshingWithNoMoreData];
                          } else {
                              [self.tableView.mj_footer endRefreshing];
                          }
                      }
                      [self.tableView reloadData];
                  });
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if (self.dataModels.count == 0) {
                      [self.tableView showErrorPageView];
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (isRefresh) {
                          [self.tableView.mj_header endRefreshing];
                      } else{
                          [self.tableView.mj_footer endRefreshing];
                      }
                      
                      [self.tableView reloadData];
                  });
              }
     ];
}

#pragma mark - fav
- (void)postFav:(long)favId favType:(FavoritesType)type
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_FAVORITE_REVERSE]
      parameters:@{
                   @"id"   : @(favId),
                   @"type" : @(type)
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue]== 1) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             } else {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"取消收藏失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }
             
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:1];
         }];

}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FavoritesCell *favoriteCell = [tableView dequeueReusableCellWithIdentifier:kFavoriteCellID forIndexPath:indexPath];
    
    if (self.dataModels.count > 0) {
        OSCFavorites *favorite = self.dataModels[indexPath.row];

        favoriteCell.favorite = favorite;
    }
    
    favoriteCell.selectedBackgroundView = [[UIView alloc] initWithFrame:favoriteCell.frame];
    favoriteCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return favoriteCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataModels.count > 0) {
        return self.dataModels.count;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    

    if (self.dataModels.count > 0) {
        
        OSCFavorites *favorite = self.dataModels[indexPath.row];

        switch (favorite.type) {
            case FavoritesTypeSoftware: {        //软件详情
                SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:favorite.id];
                [detailsViewController setHidesBottomBarWhenPushed:YES];
                [self.navigationController pushViewController:detailsViewController animated:YES];
            }
                break;
            case FavoritesTypeQuestion: {           //问答详情
                QuesAnsDetailViewController *detailVC = [[QuesAnsDetailViewController alloc] initWithDetailID:favorite.id];
                detailVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailVC animated:YES];
            }
                break;
            case FavoritesTypeBlog: {            //博客详情
                NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithDetailId:favorite.id];
                [self.navigationController pushViewController:blogDetailVC animated:YES];
            }
                break;
            case FavoritesTypeTranslate: {
                //翻译
                TranslationViewController *translationVc = [[TranslationViewController alloc] initWithTranslationID:favorite.id];
                [self.navigationController pushViewController:translationVc animated:YES];
            }
                break;
            case FavoritesTypeActivity: {
                //活动
                ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:favorite.id];
                [self.navigationController pushViewController:activityDetailCtl animated:YES];
            }
                break;
            case FavoritesTypeNews: {            //资讯详情
                OSCInformationDetailController* informationDeetailVC = [[OSCInformationDetailController alloc] initWithInformationID:favorite.id];
                [self.navigationController pushViewController:informationDeetailVC animated:YES];
            }
                break;
            default:
                [self.navigationController handleURL:[NSURL URLWithString:favorite.href] name:nil];
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        OSCFavorites *favorite = self.dataModels[indexPath.row];
        [self postFav:favorite.id favType:favorite.type];
        [_dataModels removeObjectAtIndex:indexPath.row];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}



@end
