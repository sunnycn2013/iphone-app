//
//  MyBlogsViewController.m
//  iosapp
//
//  Created by 李萍 on 16/7/11.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "MyBlogsViewController.h"
#import "NewBlogDetailController.h"
#import "NewHotBlogTableViewCell.h"

#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "UIColor+Util.h"
#import "OSCBlog.h"
#import "OSCNewHotBlog.h"
#import "OSCModelHandler.h"
#import "UIView+Common.h"

#import <MBProgressHUD.h>
#import <MJRefresh.h>


static NSString *reuseIdentifier = @"NewHotBlogTableViewCell";

@interface MyBlogsViewController ()

@property (nonatomic, strong) NSMutableArray *blogObjects;
@property (nonatomic,strong) NSString* nextToken;

@property (nonatomic, assign) NSInteger userId;

@end

@implementation MyBlogsViewController

- (instancetype)initWithUserID:(NSInteger)userID
{
    self = [super init];
    if (self) {
        
        self.userId = userID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _blogObjects = [NSMutableArray new];
    
    self.navigationItem.title = @"我的博客";
    self.tableView.tableFooterView = [UIView new];
    self.view.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NewHotBlogTableViewCell class]) bundle:[NSBundle mainBundle]] forCellReuseIdentifier:reuseIdentifier];
    self.tableView.estimatedRowHeight = 105;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self sendNetworkingRequestWithRefresh:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self sendNetworkingRequestWithRefresh:NO];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.tableView configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [self.tableView hideAllGeneralPage];
        
        [strongSelf sendNetworkingRequestWithRefresh:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - method

#pragma mark - 获取具体用户博客
-(void)sendNetworkingRequestWithRefresh:(BOOL)isRefresh {
    [self.tableView hideAllGeneralPage];
    
    NSMutableDictionary* paraMutableDic = @{}.mutableCopy;
    [paraMutableDic setObject:@(self.userId) forKey:@"userId"];
    
    if (isRefresh) {
        self.nextToken = @"";
    }
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_BLOGS_LIST];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manager GET:url
           parameters:paraMutableDic
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  if ([responseObject[@"code"]integerValue] == 1) {
                      
                      NSDictionary *result = responseObject[@"result"];
                      NSArray* JsonItems = result[@"items"];
                      self.nextToken = result[@"nextPageToken"];
                      NSArray *models = [NSArray osc_modelArrayWithClass:[OSCNewHotBlog class] json:JsonItems];
                      
                      if (isRefresh) {
                          _blogObjects = models.mutableCopy;
                      } else {
                          [self.blogObjects addObjectsFromArray:models];
                      }
                      if (_blogObjects.count == 0) {
                          [self.tableView showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"没有数据耶！"];
                      }
                      
                  } else {
                      if (_blogObjects.count == 0) {
                          NSString *message = responseObject[@"message"];
                          [self.tableView showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_fail"] tipString:message];
                      }
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (isRefresh) {
                          [self.tableView.mj_header endRefreshing];
                      } else {
                          [self.tableView.mj_footer endRefreshing];
                      }
                      [self.tableView reloadData];
                  });
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  if (!(_blogObjects.count > 0)) {
                      [self.tableView showErrorPageView];
                  }
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (isRefresh) {
                          [self.tableView.mj_header endRefreshing];
                      }else{
                          [self.tableView.mj_footer endRefreshing];
                      }
                      [self.tableView reloadData];
                      NSLog(@"%@",error);
                  });
              }
     ];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (_blogObjects.count > 0) {
        return _blogObjects.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewHotBlogTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.titleLabel.textColor = [UIColor newTitleColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    if (self.blogObjects.count > 0) {
        OSCNewHotBlog *blog = self.blogObjects[indexPath.row];
        
        cell.blog = blog;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    OSCNewHotBlog *blog;
    
    if (self.blogObjects.count > 0) {
        blog = self.blogObjects[indexPath.row];
    }
    NewBlogDetailController* blogDetailVC = [[NewBlogDetailController alloc] initWithDetailId:blog.id];
    blogDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:blogDetailVC animated:YES];
}

@end
