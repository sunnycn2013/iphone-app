//
//  OSCActivityViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityViewController.h"
#import "OSCActivityTableViewCell.h"
#import "OSCBanner.h"
#import "OSCListItem.h"
#import "OSCActivityHead.h"
#import "ActivityDetailViewController.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "NSObject+Comment.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "OSCModelHandler.h"

#define OSC_SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define OSC_BANNER_HEIGHT 223

static NSString * const activityReuseIdentifier = @"OSCActivityTableViewCell";

@interface OSCActivityViewController ()<UITableViewDelegate,UITableViewDataSource, OSCActivityHeadDelegate>

@property (nonatomic, strong) OSCActivityHead *bannerScrView;
@property (nonatomic, strong) NSMutableArray *activitys;
@property (nonatomic, strong) NSMutableArray *bannerModels;
@property (nonatomic, strong) NSString* nextToken;

@property (nonatomic, strong) NSString *activityURLStr;
@property (nonatomic, strong) NSDictionary* parameterDic;
@property (nonatomic, strong) NSString *bannerURLStr;
@property (nonatomic, strong) NSDictionary* bannerParameterDic;

@end

@implementation OSCActivityViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        _activitys = [NSMutableArray new];
        _bannerModels = [NSMutableArray new];
        _activityURLStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX, OSCAPI_INFORMATION_LIST];
        _bannerURLStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX, OSCAPI_BANNER];
        _parameterDic = @{  @"token" : @"727d77c15b2ca641fff392b779658512" };//线下活动token
        _bannerParameterDic = @{ @"catalog" : @(3) };
    }
    return self;
}

#pragma mark - cache method
- (void)getBannerCache{
    NSString *resouceName = [NSObject cacheResourceNameWithURL:_bannerURLStr parameterDictionaryDesc:_bannerParameterDic.description];
    NSDictionary *responseDic = [NSObject responseObjectWithResource:resouceName cacheType:SandboxCacheType_banner];
    NSArray *item = responseDic[@"items"];
    if (item && item.count > 0) {
        self.bannerModels = [[NSArray osc_modelArrayWithClass:[OSCBanner class] json:item] mutableCopy];
        self.bannerScrView.banners = self.bannerModels.mutableCopy;
    }
}

- (void)getActivityCache{
    NSString *resouceName = [NSObject cacheResourceNameWithURL:_activityURLStr parameterDictionaryDesc:_parameterDic.description];
    NSDictionary *responseDic = [NSObject responseObjectWithResource:resouceName cacheType:SandboxCacheType_list];
    NSArray *item = responseDic[@"items"];
    NSString *pageToken = responseDic[@"nextPageToken"];
    if(item && item.count > 0){
        _activitys = [[NSArray osc_modelArrayWithClass:[OSCListItem class] json:item] mutableCopy];
        [self.tableView reloadData];
    }
    if(pageToken.length > 0){
        _nextToken = pageToken;
    }
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"线下活动";
    
    self.bannerScrView = [[OSCActivityHead alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), OSC_BANNER_HEIGHT)];
    self.bannerScrView.delegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getJsonDataWithRefresh:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getJsonDataWithRefresh:NO];
    }];
    self.tableView.tableFooterView = [UIView new];
    
    [self layoutUI];
    
    [self getBannerCache];
    [self getActivityCache];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark --- 维护用作tableView数据源的数组
-(void)handleData:(id)responseJSON isRefresh:(BOOL)isRefresh{
    if (responseJSON) {
        NSDictionary* result = responseJSON[@"result"];
        NSArray* items = result[@"items"];
        NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCListItem class] json:items];
        if (isRefresh && items && items.count > 0) {
            [self.activitys removeAllObjects];
        }
        [self.activitys addObjectsFromArray:modelArray];
        
        if (responseJSON && items && items.count > 0 && isRefresh) {
            NSString *resouceName = [NSObject cacheResourceNameWithURL:_activityURLStr parameterDictionaryDesc:_parameterDic.description];
            [NSObject handleResponseObject:result resource:resouceName cacheType:SandboxCacheType_list];
        }
    }
}


#pragma mark - layout UI
-(void)layoutUI{
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCActivityTableViewCell" bundle:nil] forCellReuseIdentifier:activityReuseIdentifier];
    self.tableView.tableHeaderView = self.bannerScrView;
    self.tableView.estimatedRowHeight = 132;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma --mark 网络请求
-(void)getBannerData{
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager manager];
    manger.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    [manger GET:_bannerURLStr
     parameters:_bannerParameterDic
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                NSArray* responseArr = resultDic[@"items"];
                NSArray *bannerModels = [NSArray osc_modelArrayWithClass:[OSCBanner class] json:responseArr];
                self.bannerModels = bannerModels.mutableCopy;
                self.bannerScrView.banners = self.bannerModels.mutableCopy;
                
                /** banner缓存 */
                if (bannerModels && bannerModels.count > 0) {
                    NSString *resourceName = [NSObject cacheResourceNameWithURL:_bannerURLStr parameterDictionaryDesc:_bannerParameterDic.description];
                    [NSObject handleResponseObject:resultDic resource:resourceName cacheType:SandboxCacheType_banner];
                }
                /** banner缓存 */
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

-(void)getJsonDataWithRefresh:(BOOL)isRefresh{//yes 下拉 no 上拉
    
    if(isRefresh) {
        [self getBannerData];
    }
    
    NSMutableDictionary* paraMutableDic = _parameterDic.mutableCopy;
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:_activityURLStr
           parameters: paraMutableDic.copy
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if([responseObject[@"code"]integerValue] == 1) {
                      [self handleData:responseObject isRefresh:isRefresh];
                      NSDictionary* resultDic = responseObject[@"result"];
                      NSArray* items = resultDic[@"items"];
                      self.nextToken = resultDic[@"nextPageToken"];
                      
                      if (self.tableView.mj_header.isRefreshing) {
                          [self.tableView.mj_header endRefreshing];
                      }
                      if (!isRefresh) {
                          if (items.count > 0) {
                              [self.tableView.mj_footer endRefreshing];
                          } else {
                              [self.tableView.mj_footer endRefreshingWithNoMoreData];
                          }
                      }else{
                          [self.tableView.mj_footer endRefreshing];
                      }
                  }else{
                      [self.tableView.mj_footer endRefreshingWithNoMoreData];
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self.tableView reloadData];
                  });
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
                  
                  [HUD hideAnimated:YES afterDelay:1];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (self.tableView.mj_header.isRefreshing) {
                          [self.tableView.mj_header endRefreshing];
                      }
                      [self.tableView reloadData];
                  });
              }
     ];
}

#pragma mark - tableView datasource && delegate 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.activitys.count;
}
-(UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCActivityTableViewCell* cell = [OSCActivityTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:activityReuseIdentifier];
    
    cell.listItem = self.activitys[indexPath.row];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCListItem* listItem = _activitys[indexPath.row];
    
    //新活动详情页面
    ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:listItem.id];
    activityDetailCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityDetailCtl animated:YES];
}


#pragma mark - 生成bannerItem View 并转换成最终的UIImage

-(UIImage* )mapBannerItem:(id)model{
    return [self imageWithUIView:nil];
}

#pragma mark - UIView 通过Graphics 转换成 UIImage

-(UIImage*)imageWithUIView:(UIView*) view{
    UIGraphicsBeginImageContext(view.bounds.size);
    
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - ActivityHeadViewDelegate
- (void)clickScrollViewBanner:(NSInteger)bannerTag
{
    if (_bannerModels.count > 0) {
        OSCBanner *banner = _bannerModels[bannerTag];
        //新活动详情页面
        ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:banner.id];
        activityDetailCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activityDetailCtl animated:YES];
    }
    
}

@end
