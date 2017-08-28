//
//  SoftWareViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareViewController.h"

#import "SoftWareDetailCell.h"
#import "SoftWareDetailBodyCell.h"
#import "SoftWareDetailHeaderView.h"
#import "TweetTableViewController.h"
#import "recommandBlogTableViewCell.h"
#import "TweetsViewController.h"
#import "OSCUserHomePageController.h"
#import "OSCShareManager.h"
#import "OSCCommentReplyViewController.h"
#import "NewLoginViewController.h"

#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import "UMSocial.h"
#import "OSCListItem.h"
#import "OSCModelHandler.h"
#import "OSCPhotoGroupView.h"
#import "UIView+Common.h"
#import "OSCReadingInfoManager.h"
#import "ReadingInfoModel.h"
#import "UIViewController+Segue.h"

#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <MBProgressHUD.h>

#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SOFTWARE_TITLE_HEIGHT 77
#define RECOMMENDED_HEADERVIEW_HEIGHT 32
#define HEADERVIEW_HEIGHT 60
#define Nomal_SoftWare_Logo @"http://www.oschina.net/img/logo/default.gif?t=1451964198000"

static NSString * const softWareDetailCellReuseIdentifier = @"SoftWareDetailCell";
static NSString * const softWareDetailBodyCellReuseIdentifier = @"SoftWareDetailBodyCell";
static NSString * const recommandBlogTableViewCellReuseIdentifier = @"RecommandBlogTableViewCell";

@interface SoftWareViewController () <UITableViewDelegate, UITableViewDataSource,SoftWareDetailHeaderViewDelegate,UIWebViewDelegate>{
    __weak UILabel* _recommandSectionLb;
}

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, strong) NSString *identity;
@property (nonatomic, strong) NSString *networkURL;
@property (nonatomic, strong) NSMutableDictionary *parameters;

@property (nonatomic, strong) OSCListItem *sofewareDetail;

@property (nonatomic, weak) MBProgressHUD* HUD;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SoftWareDetailHeaderView* headerView;
@property (strong, nonatomic) UIView* recommendedHeaderView;
@property (nonatomic, assign) CGFloat webHeight;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *collectButton;

@property (nonatomic, strong) ReadingInfoModel *readInfoM;//用户阅读习惯
@property (nonatomic, strong) NSDate *startRead;//开始阅读
@property (nonatomic, strong) NSDate *endRead;//结束阅读

@end

@implementation SoftWareViewController

-(instancetype)initWithSoftWareID:(NSInteger)softWareID{
    self = [super init];
    if (self) {
        _id = softWareID;
        _networkURL = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX, OSCAPI_DETAIL];
        _parameters = @{
                        @"id"   : @(softWareID),
                        @"type" : @(InformationTypeSoftWare),
                      }.mutableCopy;
    }
    return self;
}

-(instancetype)initWithSoftWareIdentity:(NSString *)identity{
	self = [super init];
	if (self) {
		_identity = identity;
		_networkURL = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX, OSCAPI_DETAIL]; //
        _parameters = @{
                        @"ident" : identity,
                        @"type"  : @(InformationTypeSoftWare),
                        }.mutableCopy;
        
	}
	return self;
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialized];
    [self insertNewReadInfo];
    [self sendNetWoringRequest];
    
    _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.tableView.hidden = YES;
    self.bottomView.hidden = YES;
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.view configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [self.view hideAllGeneralPage];
        _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [strongSelf sendNetWoringRequest];
    }];
}
-(void)dealloc{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_HUD hideAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //开始到详情的的时间，每次进来都会更新
    self.startRead = [NSDate date];
}

- (void)viewWillDisappear:(BOOL)animated{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_HUD hideAnimated:YES];
    [super viewWillDisappear:animated];
    
    self.endRead = [NSDate date];
    NSTimeInterval timeInterval = [self.endRead timeIntervalSinceDate:self.startRead];
    self.readInfoM.stay += timeInterval;
    //更新单条数据  阅读时间
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET read_time = '%ld' WHERE start_time = '%ld'",(long)self.readInfoM.stay, (long)self.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];

}


-(void)initialized{
    self.title = @"软件详情";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SoftWareDetailCell" bundle:nil] forCellReuseIdentifier:softWareDetailCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"SoftWareDetailBodyCell" bundle:nil] forCellReuseIdentifier:softWareDetailBodyCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogTableViewCellReuseIdentifier];
}


#pragma mark - Networking method 
-(void)sendNetWoringRequest{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:_networkURL
      parameters:_parameters
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if ([responseObject[@"code"] integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 self.sofewareDetail = [OSCListItem osc_modelWithDictionary:resultDic];
                 
                 NSDictionary *data = @{@"content":  self.sofewareDetail.body};
                 self.sofewareDetail.body = [Utils HTMLWithData:data
                                     usingTemplate:@"blog"];
                 //用户阅读信息
                 self.readInfoM.url =  _sofewareDetail.href;//地址
                 self.readInfoM.is_collect = _sofewareDetail.favorite;//收藏
                 NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET url = '%@', collected = %@  WHERE start_time = '%ld'",self.readInfoM.url, @(self.readInfoM.is_collect), (long)self.readInfoM.operate_time];
                 [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                     [self updateBottomBtns];
                 });
             } else {
                 [self.view showBlankPageView];
                 _HUD.label.text = responseObject[@"message"];
                 _HUD.hidden = YES;
                 [_HUD hideAnimated:YES];
             }
        }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             [self.view showErrorPageView];
             _HUD.hidden = YES;
             [_HUD hideAnimated:YES];
    }];
    
}
-(void)sendFavoriteRequest{
    
    if ([Config getOwnID] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak typeof(self) weakSelf = self;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
            NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
            [weakSelf.navigationController presentViewController:loginVC animated:YES completion:nil];
        });
    }
    
    __weak typeof(self) weakSelf = self;

    _HUD = [Utils createHUD];
    _HUD.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX, OSCAPI_FAVORITE_REVERSE]
       parameters:@{
                    @"id"   : @(self.sofewareDetail.id),
                    @"type" : @(1)
                    }
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              NSInteger resultCode = [responseObject[@"code"] intValue];
              if (resultCode == 1) {
                  NSDictionary* resultDic = responseObject[@"result"];
                  NSInteger favoriteCode = [resultDic[@"favCount"] integerValue];
                  weakSelf.sofewareDetail.statistics.favCount = favoriteCode;
                  weakSelf.sofewareDetail.favorite = !weakSelf.sofewareDetail.favorite;
                  _HUD.mode = MBProgressHUDModeCustomView;
                  
                  //更新单条数据 收藏
                  __weak typeof (self)weakSelf = self;
                  self.readInfoM.is_collect = favoriteCode;
                  NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET collected = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_collect, (long)weakSelf.readInfoM.operate_time];
                  [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                  
                  _HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                  _HUD.label.text = weakSelf.sofewareDetail.favorite ? @"添加收藏成功" : @"删除收藏成功" ;
              }else{
                  _HUD.mode = MBProgressHUDModeText;
                  _HUD.label.text = @"网络异常";
              }

              dispatch_async(dispatch_get_main_queue(), ^{
                  [_HUD hideAnimated:YES afterDelay:1];
                  [weakSelf updateBottomBtns];
              });
}
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              _HUD.label.text = @"网络异常，操作失败";
              
              [_HUD hideAnimated:YES afterDelay:1];
          }];
}


#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.sofewareDetail.abouts.count > 0 ? 3 : 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {
        return self.sofewareDetail.abouts.count;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SoftWareDetailCell *softWareCell = [tableView dequeueReusableCellWithIdentifier:softWareDetailCellReuseIdentifier forIndexPath:indexPath];
        OSCNetImage *netImage = self.sofewareDetail.images[0];
        NSString *imageUrlStr = netImage.href;
        if (imageUrlStr.length > 0) {
            if ([imageUrlStr isEqualToString:Nomal_SoftWare_Logo]) {
                softWareCell.softImageView.image = [UIImage imageNamed:@"logo_software_default"];
            }else{
                [softWareCell.softImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"logo_software_default"]];
            }
        }
        softWareCell.titleLabel.text = [NSString stringWithFormat:@"%@%@",self.sofewareDetail.extra.softwareTitle?:@"",self.sofewareDetail.extra.softwareName?:@""];
        
        __block BOOL isRecommend = NO;
        [self.sofewareDetail.tags enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:@""]) {
                isRecommend = YES;
            }
        }];
        softWareCell.tagImageView.hidden = !isRecommend;
        softWareCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return softWareCell;
    }else if(indexPath.section == 1){
        SoftWareDetailBodyCell* cell = [tableView dequeueReusableCellWithIdentifier:softWareDetailBodyCellReuseIdentifier forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.webView.delegate = self;
        [cell.webView loadHTMLString:self.sofewareDetail.body baseURL:[NSBundle mainBundle].resourceURL];
		
		if (self.sofewareDetail.author.id > 0) {
			//如果不是「匿名」作者，则给作者名称那个label加一个点击响应，跳转到其个人首页
			UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(authorNameTapped:)];
			[cell configurationRelatedInfo:self.sofewareDetail tapGesture:recognizer];
		} else {
			[cell configurationRelatedInfo:self.sofewareDetail];
		}
        return cell;
    }else if(indexPath.section == 2){//相关推荐section
		RecommandBlogTableViewCell* recommandCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogTableViewCellReuseIdentifier forIndexPath:indexPath];
		NSArray* recommandArray = self.sofewareDetail.abouts;		
		if (recommandArray.count > 0) {
			OSCAbout* currentModel = recommandArray[indexPath.row];
			[recommandCell setAbouts:currentModel];
			[recommandCell setHiddenLine:self.sofewareDetail.abouts.count - 1 == indexPath.row ? YES : NO ];
		}
		recommandCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        return recommandCell;
    }else{
        return [UITableViewCell new];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        NSArray* recommandArray = self.sofewareDetail.abouts;
        OSCAbout* currentModel = recommandArray[indexPath.row];
        SoftWareViewController* softWareVC =[[SoftWareViewController alloc]initWithSoftWareID:currentModel.id];
        [self.navigationController pushViewController:softWareVC animated:YES];
    }
}

#pragma mark - headerView and height method
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return HEADERVIEW_HEIGHT;
    }else if (section == 2){
        return RECOMMENDED_HEADERVIEW_HEIGHT;
    }else{
        return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return self.headerView;
    }else if (section == 2){
        return self.recommendedHeaderView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return SOFTWARE_TITLE_HEIGHT;
    }else if(indexPath.section == 1){
        return _webHeight + 30 + 134;
    }else{
        return indexPath.row == _sofewareDetail.abouts.count-1 ? 72 : 60;
    }
}

#pragma mark - 点击作者名称label时的响应 & webview的响应处理
-(void) authorNameTapped:(UITapGestureRecognizer *) gesture {
	OSCUserHomePageController *homePageVC = [[OSCUserHomePageController alloc] initWithUserID:_sofewareDetail.author.id];
	[self.navigationController pushViewController:homePageVC animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGFloat webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    if (_webHeight == webViewHeight) {return;}
    _webHeight = webViewHeight;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_HUD hideAnimated:YES];
        self.tableView.hidden = NO;
        self.bottomView.hidden = NO;
        [self.tableView reloadData];
    });

}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    NSString* absoluteUrl = [[request URL]absoluteString];
    if ([absoluteUrl rangeOfString:@"jpg"].location  != NSNotFound ||
        [absoluteUrl rangeOfString:@"png"].location  != NSNotFound ||
        [absoluteUrl rangeOfString:@"jepg"].location != NSNotFound ||
        [absoluteUrl rangeOfString:@"gif"].location  != NSNotFound)
    {
        OSCPhotoGroupItem* item = [OSCPhotoGroupItem new];
        item.largeImageURL = [NSURL URLWithString:absoluteUrl];
        
        OSCPhotoGroupView* groupView = [[OSCPhotoGroupView alloc] initWithGroupItems:@[item]];
        UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
        
        [groupView presentFromImageView:nil toContainer:currentWindow animated:NO completion:nil];
        return NO;
    }
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}


#pragma mark - VC_xib click Button  &&  headerView delegate

-(void)updateBottomBtns{
    [_commentButton setTitle:[NSString stringWithFormat:@"评论(%ld)",(long)self.sofewareDetail.statistics.comment] forState:UIControlStateNormal];
    UIImage* image = self.sofewareDetail.favorite ? [UIImage imageNamed:@"ic_faved_normal"] : [UIImage imageNamed:@"ic_fav_normal"];
    NSString* collectTitle = self.sofewareDetail.favorite ? @"已收藏" : @"收藏" ;
    [_collectButton setImage:image forState:UIControlStateNormal];
    [_collectButton setTitle:[NSString stringWithFormat:@"%@(%ld)",collectTitle,(long)self.sofewareDetail.statistics.favCount] forState:UIControlStateNormal];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (IBAction)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 1:{//评论{
            OSCCommentReplyViewController *newCommentVC = [[OSCCommentReplyViewController alloc] initWithCommentType:InformationTypeSoftWare sourceID:self.sofewareDetail.id];

            __weak typeof (self)weakSelf = self;
            //评论状态回传
            [newCommentVC setChangeCommentStatus_block:^(BOOL isComment){
                if (isComment) {
                    self.readInfoM.is_comment = 1; // 1 代表
                    //更新单条数据 评论
                    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET comment = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_comment, (long)weakSelf.readInfoM.operate_time];
                    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                }
            }];

            
            [self.navigationController pushViewController:newCommentVC animated:YES];
            break;
        }
            
        case 2:{//收藏
            [self sendFavoriteRequest];
            break;
        }
            
        case 3:{//share按钮
            [self share];
            break;
        }
            
        default:
            break;
    }
    
}

-(void)softWareDetailHeaderViewClickLeft:(SoftWareDetailHeaderView *)headerView{
    [self.navigationController handleURL:[NSURL URLWithString:self.sofewareDetail.extra.softwareHomePage] name:nil];
}
-(void)softWareDetailHeaderViewClickRight:(SoftWareDetailHeaderView *)headerView{
    [self.navigationController handleURL:[NSURL URLWithString:self.sofewareDetail.extra.softwareDocument] name:nil];
}

#pragma mark --- share method 
-(void)share{
    //更新单条数据 收藏
    __weak typeof (self)weakSelf = self;
    self.readInfoM.is_share = 1;
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET share = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_share, (long)weakSelf.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
    
	[[OSCShareManager shareManager] showShareBoardWithShareType:InformationTypeSoftWare withModel:self.sofewareDetail];
}


#pragma mark --- lazy loading
- (SoftWareDetailHeaderView *)headerView {
	if(_headerView == nil) {
		SoftWareDetailHeaderView* headerView = [[SoftWareDetailHeaderView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,HEADERVIEW_HEIGHT}}];
        headerView.delegate = self;
        _headerView = headerView;
    }
	return _headerView;
}

- (UIView *)recommendedHeaderView {
	if(_recommendedHeaderView == nil) {
        _recommendedHeaderView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{SCREEN_WIDTH,32}}];
        _recommendedHeaderView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
        
        UIView* topLine = [[UIView alloc]initWithFrame:(CGRect){{0,0},{SCREEN_WIDTH,0.5}}];
        topLine.backgroundColor = [UIColor colorWithHex:0xc8c7cc];
        [_recommendedHeaderView addSubview:topLine];
        UIView* bottomLine = [[UIView alloc]initWithFrame:(CGRect){{0,31},{SCREEN_WIDTH,0.5}}];
        bottomLine.backgroundColor = [UIColor colorWithHex:0xc8c7cc];
        [_recommendedHeaderView addSubview:bottomLine];
        
        UILabel* textLabel = [[UILabel alloc]initWithFrame:(CGRect){{16,8},{200,16}}];
        textLabel.text = @"相关推荐";
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.font = [UIFont systemFontOfSize:15];
        textLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
        [_recommendedHeaderView addSubview:textLabel];
        _recommandSectionLb = textLabel;
	}
	return _recommendedHeaderView;
}

#pragma mark - reading infomation collect
- (void)insertNewReadInfo {
    if ([Config getOwnID] == 0) {//用户没有登录，不搜集
        
    }else {
        //用户数据收集
        self.readInfoM = [[ReadingInfoModel alloc] init];
        self.readInfoM.user = [Config getOwnID];
        self.readInfoM.user_name = [Config getOwnUserName];
        self.readInfoM.operation = @"read";//
        self.readInfoM.operate_type = OperateTypeProject;
        
        NSDate *datenow =[NSDate date];//现在时间
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:datenow];
        NSDate *localeDate = [datenow  dateByAddingTimeInterval:interval];
        
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localeDate timeIntervalSince1970]];
        NSLog(@"时间戳%@",timeSp);
        
        self.readInfoM.operate_time = [localeDate timeIntervalSince1970];
        self.readInfoM.stay = 0;
        //    [[OSCReadingInfoManager shareManager] deleteTable];
        [[OSCReadingInfoManager shareManager] insertDataWithInfoModel:self.readInfoM];
    }
}

//点击pop 的时候，判断是否上传。
- (BOOL)navigationShouldPopOnBackButton{
    
    if (self.endRead) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.endRead];
        self.readInfoM.stay += timeInterval;
    }else {//如果没有离开过当前控制器，
        self.readInfoM.stay += [[NSDate date] timeIntervalSinceDate:self.startRead];
    }
    //更新单条数据  阅读时间
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET read_time = '%ld' WHERE start_time = '%ld'",(long)self.readInfoM.stay, (long)self.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
    //renturn no 拦截pop事件
    NSMutableArray<ReadingInfoModel*> *arrDic = [[OSCReadingInfoManager shareManager] queryData];
    
    if ([arrDic count] >= 15) {
        [[OSCReadingInfoManager shareManager] uploadReadingInfoWith:arrDic];
    }
    
    return YES;
}
@end
