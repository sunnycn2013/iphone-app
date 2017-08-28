//
//  ActivityDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/31.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "ActivityDetailViewController.h"
#import "ActivityDetailCell.h"
#import "NewLoginViewController.h"
#import "OSCCommentReplyViewController.h"
#import "OSCActivityApplyViewController.h"//测试活动报名，预拉取
#import "OSCAttendantListViewController.h" //活动出席人列表

#import "UIButtonColorHF.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import "UMSocial.h"
#import "OSCActivityFooterView.h"
#import "OSCShareManager.h"  //分享工具栏
#import "OSCListItem.h"
#import "OSCModelHandler.h"
#import "OSCActivityHeaderView.h"
#import "OSCCoustomActivityNavBar.h"
#import "OSCUserHomePageController.h"
#import "OSCActivityUserController.h"
#import "NewCommentListViewController.h"

@import SafariServices ;

static NSString * const activityHeadDetailReuseIdentifier = @"ActivityHeadCell";
static NSString * const activityDetailReuseIdentifier = @"ActivityDetailCell";
@interface ActivityDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate,OSCActivityFooterDelegate,UIScrollViewDelegate,OSCCoustomActivityNavBarDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic, strong) NSArray *cellTypes;

@property (nonatomic, strong) OSCListItem *activityDetail;
@property (nonatomic, assign) int64_t     activityID;
@property (nonatomic,strong) NSString *requstUrl;
@property (nonatomic,strong) NSDictionary *pramerDic;
@property (nonatomic, copy)   NSString *HTML;
@property (nonatomic, assign) BOOL      isLoadingFinished;
@property (nonatomic, assign) CGFloat   webViewHeight;
@property (nonatomic, strong) NSString *activityTitleStr;//活动标题

@property (nonatomic, assign) BOOL isFav;
@property (nonatomic,strong) MBProgressHUD* HUD;

@property (nonatomic,strong) OSCActivityFooterView *footerView;
@property (nonatomic,strong) OSCActivityHeaderView *headerView;
@property (nonatomic,strong) OSCCoustomActivityNavBar *coustomNavBar;
@property (nonatomic,strong) CAGradientLayer *maskLayer;

@end

@implementation ActivityDetailViewController


- (instancetype)initWithActivityID:(int64_t)activityID
{
    self = [super init];
    if (self) {
        _activityID = activityID;
        _requstUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX , OSCAPI_DETAIL];
        _pramerDic = @{@"id"   : @(self.activityID),
                       @"type" : @(InformationTypeActivity)};
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self fetchForActivityDetailDate];
    _cellTypes = @[@"priceType", @"timeType", @"addressType"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    UIViewController *topVC = self.navigationController.topViewController;
    if (!([topVC isKindOfClass:[ActivityDetailViewController class]] || [topVC isKindOfClass:[OSCUserHomePageController class]])) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    _HUD.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _coustomNavBar = [[OSCCoustomActivityNavBar alloc] init];
    _coustomNavBar.delegate = self;
    
    _headerView = [[OSCActivityHeaderView alloc] init];
    
    _footerView = [[OSCActivityFooterView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _footerView.delegate = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityDetailCell" bundle:nil] forCellReuseIdentifier:activityDetailReuseIdentifier];
    
    [self showEnable:YES];
    self.addButton.enabled = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 250;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    
    self.bottomView.backgroundColor = [UIColor newCellColor];
    [self.tableView setContentOffset:CGPointZero];
    
    [self.view.layer addSublayer:self.maskLayer];
    
    [self.view addSubview:_coustomNavBar];

}

- (void)didReceiveMemoryWarning {
    [self.navigationController popViewControllerAnimated:YES];
    [super didReceiveMemoryWarning];
}

#pragma mark - showHudEnable
- (void)showEnable:(BOOL)isShow
{
    self.tableView.hidden = isShow;
    self.favButton.enabled = !isShow;
    self.commentButton.enabled = !isShow;
    self.coustomNavBar.shareBtn.enabled = !isShow;
    self.coustomNavBar.favoriteBtn.enabled = !isShow;
    self.bottomView.hidden = isShow;
}

#pragma mark - right BarButton
- (void)shareForActivity:(UIBarButtonItem *)barButton
{
	NSLog(@"share");
    
    OSCShareManager *shareManeger = [OSCShareManager shareManager];
    [shareManeger showShareBoardWithShareType:InformationTypeActivity withModel:_activityDetail];
    
}

#pragma mark - 获取数据
- (void)fetchForActivityDetailDate
{
	
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _HUD.userInteractionEnabled = NO;
	
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manager GET:self.requstUrl
      parameters:self.pramerDic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"]integerValue] == 1) {
                 _activityDetail = [OSCListItem osc_modelWithDictionary:responseObject[@"result"]];
                 self.activityTitleStr = _activityDetail.title;
                 _activityDetail.body = [Utils HTMLWithData:@{@"content":  _activityDetail.body}
                                              usingTemplate:@"newTweet"];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.commentButton setTitle:[NSString stringWithFormat:@"评论(%ld)", (long)_activityDetail.statistics.comment] forState:UIControlStateNormal];
                     
                     _headerView.model = _activityDetail;
                     _headerView.frame = CGRectMake(0, 0, kScreenSize.width, [_headerView getHeaderViewHeight]);
                     
                     [self.coustomNavBar favoritButtonIsFavorite:_activityDetail.favorite];
                     
                     [self setApplyButton];
                     
                     [_footerView setNeedLoad:_activityDetail.body];
                 });
             }else{
                 _HUD.hidden = YES;
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"这个活动找不到了(不存在/已删除)";
                 [HUD hideAnimated:YES afterDelay:1];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self.navigationController popViewControllerAnimated:YES];
                 });
             }
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            MBProgressHUD *HUD = [MBProgressHUD new];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"网络异常，加载失败";

            [HUD hideAnimated:YES afterDelay:1];
    }];

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_activityDetail) {
        return 3;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ActivityDetailCell *cell = [_tableView dequeueReusableCellWithIdentifier:activityDetailReuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellType = _cellTypes[indexPath.row];
    cell.activity = _activityDetail;
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y > kScreenSize.width / 2) {
        self.maskLayer.hidden = YES;
    }else{
        self.maskLayer.hidden = NO;
    }
    [_coustomNavBar setColorWithState:scrollView.contentOffset.y > kScreenSize.width / 2];
}

#pragma --mark OSCInformationHeaderViewDelegate
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.footerView.frame = CGRectMake(0, 0, kScreenSize.width , height);
        _HUD.hidden = YES;
        self.tableView.tableFooterView = self.footerView;
        self.tableView.tableHeaderView = self.headerView;
        [self showEnable:NO];
        [self.tableView reloadData];
    });
}

#pragma mark --- OSCCoustomActivityNavBarDelegate
- (void)ClickBackBtn{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ClickFavoriteBtn{
    [self postFav];
}

- (void)ClickShareBtn{
    [self shareForActivity:nil];
}

#pragma mark - button clicked
- (IBAction)settingTouchDownColor:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHex:0x188E50];
}
- (IBAction)settingTouchUp:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHex:0x18BB50];
}

- (IBAction)clickedButton:(UIButton *)sender {
    
    
    
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        if (sender.tag == 2){
            
            
            switch (_activityDetail.extra.eventApplyStatus) {
                case ApplyStatusUnSignUp:
                {
                    //报名
                    [self enrollActivity];
                    break;
                }
                case ApplyStatusAttended:
                {
                    //出席人列表
                    [self activityAttendantList];
                    break;
                }
                case ApplyStatusCanceled://已取消
				case ApplyStatusRejected:
				{
					//允许再次报名
					[self enrollActivity];
					break;
				}
                case ApplyStatusAudited:
                {
                    OSCActivityUserController *activityUserC = [[OSCActivityUserController alloc] initWithType:ActivityUserTypeNormal withActivityID:_activityID isQR:NO];
                    [self.navigationController pushViewController:activityUserC animated:YES];
                    break;
                }
                case ApplyStatusDetermined:
                {
                    OSCActivityUserController *activityUserC = [[OSCActivityUserController alloc] initWithType:ActivityUserTypeNormal withActivityID:_activityID isQR:NO];
                    [self.navigationController pushViewController:activityUserC animated:YES];
                    break;
                }
                default:
                    break;
            }
            
        } else if (sender.tag == 3) {
            //修改 调到可以分享的评论界面
           // OSCCommentReplyViewController *newCommentVC = [[OSCCommentReplyViewController alloc] initWithCommentType:InformationTypeActivity sourceID:_activityDetail.id];
            NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:InformationTypeActivity sourceID:_activityDetail.id titleStr:self.activityTitleStr];
            
            [self.navigationController pushViewController:newCommentVC animated:YES];
        }
    }
    
}

- (IBAction)highlightedState:(UIButton *)sender {
    if (_addButton.enabled) {
        _addButton.backgroundColor = ButtonPressedBackgroundColor;
        [_addButton setTitleColor:ButtonPressedTextColor forState:UIControlStateNormal];
    }
    
}

- (IBAction)outSideState:(UIButton *)sender {
    if (_addButton.enabled) {
        _addButton.backgroundColor = ButtonNormalBackgroundColor;
        [_addButton setTitleColor:ButtonNormalTextColor forState:UIControlStateNormal];
    }
    
}

- (void)setApplyButton
{
    switch (_activityDetail.extra.eventApplyStatus) {//applyStatus
            
            
        case ApplyStatusUnSignUp://未报名
        {
            switch (_activityDetail.extra.eventStatus) {
                case ActivityStatusEnd:
                {
                    _addButton.backgroundColor = ButtonDissableBackgroundColor;
                    [_addButton setTitle:@"活动结束" forState:UIControlStateNormal];
                    [_addButton setTitleColor:ButtonDissableTextColor forState:UIControlStateNormal];
                    [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
                    _addButton.enabled = NO;
                    break;
                }
                case ActivityStatusHaveInHand:{
                    //活动进行中
                    _addButton.backgroundColor = ButtonNormalBackgroundColor;
                    [_addButton setTitle:@"我要报名" forState:UIControlStateNormal];
                    [_addButton setTitleColor:ButtonNormalTextColor forState:UIControlStateNormal];
                    [_addButton setImage:[UIImage imageNamed:@"ic_user_add-1"] forState:UIControlStateNormal];
                    _addButton.enabled = YES;
                    break;
                }
                case ActivityStatusClose:{
                    _addButton.backgroundColor = ButtonDissableBackgroundColor;
                    [_addButton setTitle:@"报名截止" forState:UIControlStateNormal];
                    [_addButton setTitleColor:ButtonDissableTextColor forState:UIControlStateNormal];
                    [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
                    _addButton.enabled = NO;
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case ApplyStatusAudited://审核中
        {
            
            switch (_activityDetail.extra.eventStatus) {
                case ActivityStatusEnd:
                {
                    _addButton.backgroundColor = ButtonDissableBackgroundColor;
                    [_addButton setTitle:@"活动结束" forState:UIControlStateNormal];
                    [_addButton setTitleColor:ButtonDissableTextColor forState:UIControlStateNormal];
                    [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
                    _addButton.enabled = NO;
                    break;
                }
                case ActivityStatusHaveInHand:{
                    //活动进行中
                    _addButton.backgroundColor = ButtonNormalBackgroundColor;
                    [_addButton setTitle:@"我的报名信息" forState:UIControlStateNormal];
                    [_addButton setTitleColor:ButtonNormalTextColor forState:UIControlStateNormal];
                    [_addButton setImage:[UIImage imageNamed:@"ic_user_add-1"] forState:UIControlStateNormal];
                    _addButton.enabled = YES;
                    break;
                }
                case ActivityStatusClose:{
                    _addButton.backgroundColor = ButtonDissableBackgroundColor;
                    [_addButton setTitle:@"报名截止" forState:UIControlStateNormal];
                    [_addButton setTitleColor:ButtonDissableTextColor forState:UIControlStateNormal];
                    [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
                    _addButton.enabled = NO;
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case ApplyStatusDetermined://已经确认
        {
            _addButton.backgroundColor = ButtonNormalBackgroundColor;
            [_addButton setTitle:@"我的报名信息" forState:UIControlStateNormal];
            [_addButton setTitleColor:ButtonNormalTextColor forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add-1"] forState:UIControlStateNormal];
            _addButton.enabled = YES;
            break;
        }
        case ApplyStatusAttended://已经出席
        {
            _addButton.backgroundColor = ButtonNormalBackgroundColor;
            [_addButton setTitle:@"查看活动出席人" forState:UIControlStateNormal];
            [_addButton setTitleColor:ButtonNormalTextColor forState:UIControlStateNormal];
            [_addButton setImage:[UIImage imageNamed:@"ic_user_add-1"] forState:UIControlStateNormal];
            _addButton.enabled = YES;

            break;
        }
        case ApplyStatusCanceled://已取消
//        {
//            _addButton.backgroundColor = ButtonDissableBackgroundColor;
//            [_addButton setTitle:@"已取消" forState:UIControlStateNormal];
//            [_addButton setTitleColor:ButtonDissableTextColor forState:UIControlStateNormal];
//            [_addButton setImage:[UIImage imageNamed:@"ic_user_add"] forState:UIControlStateNormal];
//            _addButton.enabled = YES;
//            break;
//        }
        case ApplyStatusRejected://已拒绝
        {
			_addButton.backgroundColor = ButtonNormalBackgroundColor;
			[_addButton setTitle:@"我要报名" forState:UIControlStateNormal];
			[_addButton setTitleColor:ButtonNormalTextColor forState:UIControlStateNormal];
			[_addButton setImage:[UIImage imageNamed:@"ic_user_add-1"] forState:UIControlStateNormal];
			_addButton.enabled = YES;
            break;
        }
            
        default:
            break;
    }
	
}

#pragma mark - fav
- (void)postFav
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_FAVORITE_REVERSE];
    [manger POST:strUrl
      parameters:@{
                   @"id"   : @(_activityDetail.id),
                   @"type" : @(5)
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue]== 1) {
                 _activityDetail.favorite = [responseObject[@"result"][@"favorite"] boolValue];
             }
             
             
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = _activityDetail.favorite? @"收藏成功": @"取消收藏";
             
             [HUD hideAnimated:YES afterDelay:1];
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.coustomNavBar favoritButtonIsFavorite:_activityDetail.favorite];
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             MBProgressHUD *HUD = [Utils createHUD];
             HUD.mode = MBProgressHUDModeCustomView;
             HUD.label.text = @"网络异常，操作失败";
             
             [HUD hideAnimated:YES afterDelay:1];
         }];
}

#pragma mark - 报名

- (void)enrollActivity
{
    if (_activityDetail.extra.eventType == ActivityTypeBelow) {
		NSURL *url = [NSURL URLWithString:_activityDetail.href];
		if([[[UIDevice currentDevice] systemVersion] hasPrefix:@"9"]) {
			SFSafariViewController *webviewController = [[SFSafariViewController alloc] initWithURL:url];
			[self presentViewController:webviewController animated:YES completion:^{
				//
			}];
		} else {
			[[UIApplication sharedApplication] openURL:url];
		}
    } else {
        if (_activityDetail.extra.eventApplyStatus == ApplyStatusAttended) {
            [self activityAttendantList];
        } else {
            
            //新活动报名页面
            OSCActivityApplyViewController *applyVC = [[OSCActivityApplyViewController alloc] initWithActivitySourceId:_activityDetail.id];
            [self.navigationController pushViewController:applyVC animated:YES];
        }
    }
}

#pragma mark - 出席人列表
- (void)activityAttendantList
{
    OSCAttendantListViewController *attendListVC = [[OSCAttendantListViewController alloc] initWithSourceId:_activityDetail.id filterText:@""];
    [self.navigationController pushViewController:attendListVC animated:YES];
}

#pragma lazyLoad
- (CAGradientLayer *)maskLayer{
    if (!_maskLayer) {
        _maskLayer = [[CAGradientLayer alloc] init];
        _maskLayer.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.width/3);
        _maskLayer.startPoint = CGPointMake(0, 0);
        _maskLayer.endPoint = CGPointMake(0, 1);
        _maskLayer.locations = @[@(0.1),@(0.9)];
        _maskLayer.colors = @[(id)[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5].CGColor,(id)[UIColor clearColor].CGColor];
    }
    return _maskLayer;
}

@end
