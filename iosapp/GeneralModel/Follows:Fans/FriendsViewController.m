//
//  FriendsViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 12/11/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "FriendsViewController.h"
#import "OSCModelHandler.h"
#import "OSCUserItem.h"
#import "PersonCell.h"
#import "OSCUserHomePageController.h"
#import "OSCMsgCount.h"
#import "Config.h"

#import "NSObject+Comment.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>

static NSString * const kPersonCellID = @"PersonCell";

@interface FriendsViewController ()

@property (nonatomic, assign) int64_t uid;


@property (nonatomic, assign) long userID;
@property (nonatomic, copy) NSString *lastUrlDefine;
@property (nonatomic, copy) NSString *nextPageToken;

@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation FriendsViewController

- (instancetype)initUserId:(long)userId andRelation:(NSString *)lastUrlDefine
{
    self = [super init];
    if (self) {
        self.userID = userId;
        self.lastUrlDefine = lastUrlDefine;
        self.items = [NSMutableArray new];
    }
    return self;
}


#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[PersonCell class] forCellReuseIdentifier:kPersonCellID];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 68;
        
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getJsonDataWithRefresh:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getJsonDataWithRefresh:NO];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- 维护用作tableView数据源的数组
-(void)handleData:(id)responseJSON isRefresh:(BOOL)isRefresh{
    if (responseJSON) {
        NSDictionary *result = responseJSON[@"result"];
        NSArray* items = result[@"items"];
        NSArray* modelArray = [NSArray osc_modelArrayWithClass:[OSCUserItem class] json:items];
        
        if (isRefresh) {//上拉得到的数据
            [self.items removeAllObjects];
        }
        [self.items addObjectsFromArray:modelArray];
    }
}

#pragma mark - 获取具体用户博客
-(void)getJsonDataWithRefresh:(BOOL)isRefresh {
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, self.lastUrlDefine];

    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    [paraMutableDic setObject:@(self.userID) forKey:@"id"];
    if (!isRefresh && [self.nextPageToken length] > 0) {
        [paraMutableDic setObject:self.nextPageToken forKey:@"pageToken"];
    }
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:strUrl
      parameters:paraMutableDic
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([responseObject[@"code"] integerValue] == 1) {
                      
                      [self handleData:responseObject isRefresh:isRefresh];

                      NSDictionary *resultDic = responseObject[@"result"];
                      self.nextPageToken = resultDic[@"nextPageToken"];
                      NSArray* items = resultDic[@"items"];
                      
                      if (self.tableView.mj_header.isRefreshing) {
                          [self.tableView.mj_header endRefreshing];
                      }
                      if (!isRefresh) {
                          if (items.count > 0) {
                              [self.tableView.mj_footer endRefreshing];
                          } else {
                              [self.tableView.mj_footer endRefreshingWithNoMoreData];
                          }
                      }
                      
                      if ([self.lastUrlDefine isEqualToString:@"user_fans"]) {
                          [NSObject settingTagHasBeenRead:MsgCountTypeFans];
                      }
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  } else {

                      [self.tableView.mj_header endRefreshing];
                      [self.tableView.mj_footer endRefreshing];
                  }
                  
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


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PersonCell *cell = [tableView dequeueReusableCellWithIdentifier:kPersonCellID forIndexPath:indexPath];
    
    if (self.items.count > 0) {
        OSCUserItem *friend = self.items[indexPath.row];
        
        [cell.portrait loadPortrait:[NSURL URLWithString:friend.portrait] userName:friend.name];
        cell.nameLabel.text = friend.name;
        cell.infoLabel.text = friend.more.expertise;
        if (friend.identity.officialMember) {
            cell.idendityLabel.hidden = NO;
        }else{
            cell.idendityLabel.hidden = YES;
        }
    }
    
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCUserItem *friend = self.items[indexPath.row];
    if (friend.id > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:friend.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.items.count > 0) {
        return self.items.count;
    }
    
    return 0;
}


@end
