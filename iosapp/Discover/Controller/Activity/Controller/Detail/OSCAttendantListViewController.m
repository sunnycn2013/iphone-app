//
//  OSCAttendantListViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/12/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCAttendantListViewController.h"
#import "NewLoginViewController.h"
#import "OSCUserHomePageController.h"
#import "OSCAttendantCell.h"
#import "UIView+Common.h"

#import "Utils.h"
#import "Config.h"
#import "OSCUserItem.h"
#import "OSCAPI.h"
#import "OSCModelHandler.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>

static NSString * const activityAttendantReuseIdentifier = @"OSCAttendantCell";
@interface OSCAttendantListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating, OSCAttendantCellDelegate, UISearchBarDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) NSInteger sourceId;
@property (nonatomic, copy) NSString *filterText;

@property (nonatomic, strong) NSMutableArray *attendants;
@property (nonatomic, copy) NSString *nextPageToken;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL searchCanlceBool;

@end

@implementation OSCAttendantListViewController

- (instancetype)initWithSourceId:(NSInteger)sourceID filterText:(NSString *)filterText
{
    self = [super init];
    if (self) {
        self.sourceId = sourceID;
        self.filterText = filterText;
        self.attendants = [NSMutableArray array];
        self.searchResults = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"活动出席人";
    
    [self LayoutUI];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHidden)]];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (!self.searchController.active) {
            [self fetchDataForRefresh:YES];
        } else {
            [self.tableView.mj_header endRefreshing];
        }
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if (!self.searchController.active) {
            [self fetchDataForRefresh:NO];
        } else {
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    
    [self fetchDataForRefresh:YES];
    [self.tableView.mj_header beginRefreshing];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.tableView configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [self.tableView hideAllGeneralPage];
        [strongSelf fetchDataForRefresh:YES];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if (self.searchController.active) {
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
//    } else {
//        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)LayoutUI
{
    self.definesPresentationContext = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCAttendantCell" bundle:nil] forCellReuseIdentifier:activityAttendantReuseIdentifier];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self;
    _searchController.searchBar.delegate = self;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    _searchController.hidesNavigationBarDuringPresentation = NO;
    self.tableView.tableHeaderView = _searchController.searchBar;
    
    _searchController.searchBar.backgroundImage = [UIImage new];
    _searchController.searchBar.backgroundColor = [UIColor themeColor];
    _searchController.searchBar.barTintColor = [UIColor themeColor];
    
    UITextField *searchField = [_searchController.searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.backgroundColor = [UIColor whiteColor];
        searchField.layer.cornerRadius = 2;
        searchField.layer.borderWidth = 1;
        searchField.layer.borderColor = [UIColor colorWithHex:0xE1E1E1].CGColor;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - data
- (void)fetchDataForRefresh:(BOOL)isRefresh
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSMutableDictionary* paraMutableDic = @{@"sourceId" : @(self.sourceId)}.mutableCopy;
    if (self.searchController.active) {
        [paraMutableDic setObject:self.filterText forKey:@"filter"];
    } else {
        [paraMutableDic setObject:(isRefresh ? @"" : self.nextPageToken) forKey:@"pageToken"];
    }
    
    [manger GET:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_ATTENDEE_LIST]
      parameters:paraMutableDic.copy
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if ([responseObject[@"code"] integerValue]== 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray *items = resultDic[@"items"];
                 NSArray *models = [NSArray osc_modelArrayWithClass:[OSCUserItem class] json:items];
                 NSString *nextPageToken = resultDic[@"nextPageToken"];
                 
                 if (self.searchController.active) {
                     if (isRefresh) {
                         [self.searchResults removeAllObjects];
                     }
                     [self.searchResults addObjectsFromArray:models];
                     
                     if (self.searchResults.count == 0) {
                         [self.view showBlankPageView];
                     }else{
                         [self.view hideAllGeneralPage];
                     }
                     
                 } else {
                     if (isRefresh && models && models.count > 0) {
                         [self.attendants removeAllObjects];
                     }
                     [self.attendants addObjectsFromArray:models];

                     if (nextPageToken.length) {
                         self.nextPageToken = nextPageToken;
                     }
                     
                     if (self.attendants.count == 0) {
                         [self.view showBlankPageView];
                     }else{
                         [self.view hideAllGeneralPage];
                     }
                 }
 
             } else {
                 if (!self.searchController.active && self.attendants.count == 0) {
                     [self.view showBlankPageView];
                 } else {
                     [self.view hideAllGeneralPage];
                 }
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
                 if (isRefresh) {
                     [self.tableView.mj_header endRefreshing];
                 } else {
                     [self.tableView.mj_footer endRefreshing];
                 }
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             if (self.searchController.active) {
                 if (self.searchResults.count == 0) {
                     [self.tableView showErrorPageView];
                 }
                 
             } else {
                 if (self.attendants.count == 0) {
                     [self.tableView showErrorPageView];
                 }
                 
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (isRefresh) {
                     [self.tableView.mj_header endRefreshing];
                 } else {
                     [self.tableView.mj_footer endRefreshing];
                 }
             });
         }];
}

#pragma mark - keyboardHidden
- (void)keyboardHidden
{
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCAttendantCell *cell = [self.tableView dequeueReusableCellWithIdentifier:activityAttendantReuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPathRow = indexPath.row;
    
    if (self.searchController.active) {
        if (self.searchResults.count) {
            OSCUserItem *item = self.searchResults[indexPath.row];
            cell.userItem = item;
        }
    } else {
        if (self.attendants.count) {
            OSCUserItem *item = self.attendants[indexPath.row];
            cell.userItem = item;
        }
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active) {
        return self.searchResults.count ? self.searchResults.count : 0;
    } else {
        return self.attendants.count ? self.attendants.count : 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCAttendantCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self clickActionForAttendantCellUserPortrait:cell];
}


#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *filterString = searchController.searchBar.text;
    if (self.searchResults!= nil) {
        [self.searchResults removeAllObjects];
        [self.view hideAllGeneralPage];
    }
    
    if (filterString.length) {
        self.filterText = filterString;
        [self fetchDataForRefresh:YES];
    } else {
        self.filterText = @"";
    }
    
    //搜索数组列表
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchCanlceBool = NO;
    [self.view hideAllGeneralPage];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    self.navigationController.interactivePopGestureRecognizer.enabled = self.searchCanlceBool ? YES : NO;
    if (self.searchCanlceBool) {
        
        [self.view hideAllGeneralPage];
    } else {
        
    }
//    [UIApplication sharedApplication].statusBarStyle = self.searchCanlceBool ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view hideAllGeneralPage];
    self.searchCanlceBool = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchController.searchBar resignFirstResponder];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.searchController.active) {
        [self.searchController.searchBar resignFirstResponder];
    }
    
}

#pragma mark - OSCAttendantCellDelegate

- (void)clickActionForAttendantCellUserPortrait:(OSCAttendantCell *)attendantCell
{
    OSCUserItem *item = attendantCell.loUserItem;
	if (item.id > 0) {
//        self.searchController.active = NO;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:item.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
//		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:item.id];
//            [self.navigationController pushViewController:userDetailsVC animated:YES];
//		});
	}
	else {
		MBProgressHUD *HUD = [Utils createHUD];
		HUD.mode = MBProgressHUDModeCustomView;
		HUD.label.text = @"该用户不存在";
		[HUD hideAnimated:YES afterDelay:1];
	}
}

	
- (void)clickActionForAttendantCell:(OSCAttendantCell *)attendantCell relationAction:(UserRelationStatus)relationStatus indexforRow:(NSInteger)row
{
    OSCUserItem *userItem = !self.searchController.active ? self.attendants[row] : self.searchResults[row];
    //关注请求
    [self changeRelation:userItem withCell:attendantCell];
}

- (void)changeRelation:(OSCUserItem *)userItem withCell:(OSCAttendantCell *)attendantCell
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_USER_RELATION_REVERSE] parameters:@{ @"id" : @(userItem.id) }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"] floatValue] == 1) {
                     NSDictionary* resultDic = responseObject[@"result"];
                     userItem.relation = [resultDic[@"relation"] intValue];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         HUD.mode = MBProgressHUDModeCustomView;
                         if (userItem.relation == 1 || userItem.relation == 2) {
                             HUD.label.text = @"关注成功";
                         }else{
                             HUD.label.text = @"取消关注";
                         }
                         
                         [HUD hideAnimated:YES afterDelay:1];
                         
                         [attendantCell relationLayoutWithItem:userItem button:attendantCell.followButton];
                     });
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSIndexPath *path = [NSIndexPath indexPathForRow:attendantCell.followButton.tag-1 inSection:0];
                         [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
                     });
                 } else {
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.label.text = responseObject[@"message"];
                     
                     [HUD hideAnimated:YES afterDelay:1];
                 }
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，操作失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }];
    }
}



@end
