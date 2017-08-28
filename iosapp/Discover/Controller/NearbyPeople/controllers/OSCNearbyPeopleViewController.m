//
//  OSCNearbyPeopleViewController.m
//  iosapp
//
//  Created by 王恒 on 16/12/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNearbyPeopleViewController.h"
#import "Config.h"
#import "OSCUserItem.h"
#import "OSCModelHandler.h"
#import "OSCNearByPeopleModel.h"
#import "NearbyPersonCell.h"
#import "Utils.h"
#import "OSCUserHomePageController.h"

#import "UIView+Common.h"

#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MJRefresh/MJRefresh.h>

#define kRowHeight 77

@interface OSCNearbyPeopleViewController ()<BMKLocationServiceDelegate,UIAlertViewDelegate,BMKRadarManagerDelegate,UITableViewDelegate,UITableViewDataSource>

{
    BMKLocationService *_locService;
    BMKRadarManager *_radarManager;
    CLLocationCoordinate2D _curLocation;
    NSLock *lock;
    UITableView *_tableView;
    MBProgressHUD *_hud;
    NSInteger _indexPage;
}

@property (nonatomic,strong) NSMutableArray *searchArray;

@end

@implementation OSCNearbyPeopleViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        self.navigationItem.title = @"附近的程序员";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"] style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClick)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    _indexPage = 0;
    
    _searchArray = [[NSMutableArray alloc] init];
    
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    
    _radarManager = [BMKRadarManager getRadarManagerInstance];
    [_radarManager stopAutoUpload];
    _radarManager.userId = [NSString stringWithFormat:@"%ld",(long)[Config getOwnID]];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = kRowHeight;
    [_tableView registerNib:[UINib nibWithNibName:@"NearbyPersonCell" bundle:nil] forCellReuseIdentifier:kNearbyPersonCellID];
    [self.view addSubview:_tableView];
    _tableView.tableFooterView = [UIView new];

    __weak typeof(self) weakSelf = self;
    _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf startSearchNearbyPeople];
    }];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.removeFromSuperViewOnHide = YES;
    [_hud showAnimated:YES];
    [self.view addSubview:_hud];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = YES;
    [_radarManager addRadarManagerDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _locService.delegate = nil;
    [_locService stopUserLocationService];
    [_radarManager removeRadarManagerDelegate:self];
}

- (void)dealloc{
    [BMKRadarManager releaseRadarManagerInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- Method
- (void)rightButtonClick{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    __weak typeof(alert) weakAlert = alert;
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"清除位置信息并退出" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakAlert dismissViewControllerAnimated:YES completion:nil];
        BOOL res = [_radarManager clearMyInfoRequest];
        if (res) {
            if ([self.delegate respondsToSelector:@selector(completeUpdateUserLocationIsUpload:)]) {
                [self.delegate completeUpdateUserLocationIsUpload:NO];
            }
        }
		[Utils setShouldUploadLocation:@"no"]; //设置flag
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:clearAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startSearchNearbyPeople{
	BMKRadarNearbySearchOption *option = [[BMKRadarNearbySearchOption alloc] init];
    option.radius = 38 * 1000;
    option.sortType = BMK_RADAR_SORT_TYPE_DISTANCE_FROM_NEAR_TO_FAR;
    option.centerPt = _curLocation;
    option.pageIndex = _indexPage;
    option.pageCapacity = 50;
    //发起检索
    BOOL result = [_radarManager getRadarNearbySearchRequest:option];
    if (!result) {
        [_hud hideAnimated:YES];
        MBProgressHUD *hud = [Utils createHUD];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"发起检索太频繁，一会再试吧";
        [hud hideAnimated:YES afterDelay:2];
        [_tableView.mj_footer endRefreshing];
        _indexPage--;
    }
}

- (NSString *)getUpLoadExtInfo{
    OSCUserItem *userItem = [Config myNewProfile];
    NSString *company = (userItem.more.company) ? userItem.more.company : @"";
    NSString *extInfo = [NSString stringWithFormat:
                         @"{\"id\":\"%ld\",\"name\":\"%@\",\"portrait\":\"%@\",\"gender\":%ld,\"more\":{\"company\":\"%@\"},\"identity\":{\"officialMember\":%@,\"softwareAuthor\":%@}}",userItem.id,userItem.name,userItem.portrait,userItem.gender,company,(userItem.identity.officialMember ? @"true":@"false"),(userItem.identity.softwareAuthor ? @"true":@"false")];
    extInfo = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                      (CFStringRef)extInfo,
                                                      NULL,
                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                      kCFStringEncodingUTF8);
    return extInfo;
}

- (void)getNearbyPeopleInfoWithExtInfo:(NSArray *)extArray{
    NSArray* searchIdArr = nil;
        NSMutableArray* mSearchIdArr = [NSMutableArray arrayWithCapacity:_searchArray.count];
        for (OSCNearByPeopleModel* model in _searchArray) {
            [mSearchIdArr addObject:@(model.id)];
        }
        searchIdArr = mSearchIdArr.copy;
    for (BMKRadarNearbyInfo *peopleInfo in extArray) {
        NSString *extInfo = peopleInfo.extInfo;
        [extInfo stringByRemovingPercentEncoding];
        OSCNearByPeopleModel *userInfo = [OSCNearByPeopleModel osc_modelWithJSON:extInfo];
        userInfo.meters = peopleInfo.distance;
        if (userInfo && userInfo.id != 0) {
            if (!searchIdArr || ![searchIdArr containsObject:@(userInfo.id)]) {
                [_searchArray addObject:userInfo];
            }
        }
    }
}

#pragma mark --- BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
	
	[Utils setShouldUploadLocation:@"yes"]; //设置flag
	
    BMKRadarUploadInfo *userInfo = [[BMKRadarUploadInfo alloc] init];
    [lock lock];
    _curLocation.latitude = userLocation.location.coordinate.latitude;
    _curLocation.longitude = userLocation.location.coordinate.longitude;
    [lock unlock];
    userInfo.pt = _curLocation;
    userInfo.extInfo = [self getUpLoadExtInfo];
    BOOL res = [_radarManager uploadInfoRequest:userInfo];
    if (res) {
        [self startSearchNearbyPeople];
    }
    [_locService stopUserLocationService];
}

- (void)didFailToLocateUserWithError:(NSError *)error{
    UIAlertController *alert =
		[UIAlertController alertControllerWithTitle:@"提示" message:@"开源中国无法获取您的位置信息\n现在去「设置」打开定位服务并允许开源中国获取位置信息吗？" preferredStyle:UIAlertControllerStyleAlert];
	
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		BOOL res = [_radarManager clearMyInfoRequest];
		if (res) {
			if ([self.delegate respondsToSelector:@selector(completeUpdateUserLocationIsUpload:)]) {
				[self.delegate completeUpdateUserLocationIsUpload:NO];
			}
		}
		[Utils setShouldUploadLocation:@"no"];//设置flag
        [self.navigationController popViewControllerAnimated:YES];
    }];
	
    UIAlertAction *setAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
	
    [alert addAction:cancelAction];
    [alert addAction:setAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark --- BMKRadarManagerDelegate
- (void)onGetRadarNearbySearchResult:(BMKRadarNearbyResult *)result error:(BMKRadarErrorCode)error{
    if (error == 0) {
        _indexPage ++;
        [self getNearbyPeopleInfoWithExtInfo:result.infoList];
        [_tableView reloadData];
        [_tableView.mj_footer endRefreshing];
        [_hud hideAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(completeUpdateUserLocationIsUpload:)]) {
            [self.delegate completeUpdateUserLocationIsUpload:YES];
        }
    }else if(error == 1){
        if (_searchArray.count == 0) {
            [_hud hideAnimated:YES];
            [self.view showBlankPageView];
        }else{
            [_tableView.mj_footer endRefreshingWithNoMoreData];
        }
        if ([self.delegate respondsToSelector:@selector(completeUpdateUserLocationIsUpload:)]) {
            [self.delegate completeUpdateUserLocationIsUpload:YES];
        }
    }else{
        [_hud hideAnimated:YES];
        MBProgressHUD *hud = [Utils createHUD];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"其他错误,请检查网络问题";
        [hud hideAnimated:YES afterDelay:2];
        [_tableView.mj_footer endRefreshing];
        if (_searchArray.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _searchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NearbyPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:kNearbyPersonCellID forIndexPath:indexPath];
    if (!cell) {
        cell = [[NearbyPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNearbyPersonCellID];
    }
    cell.model = _searchArray[indexPath.row];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    return cell;
}

#pragma mark --- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OSCNearByPeopleModel *model = _searchArray[indexPath.row];
    if (model.id) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:model.id] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        [HUD hideAnimated:YES afterDelay:1];
    }
}

@end
