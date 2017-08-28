//
//  NewBlogDetailController.m
//  iosapp
//
//  Created by 李萍 on 2016/11/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewBlogDetailController.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "Config.h"
#import "UIDevice+SystemInfo.h"

#import "OSCAPI.h"
#import "OSCBlogDetail.h"
#import "OSCListItem.h"
#import "BlogDetailHeadView.h"
#import "OSCModelHandler.h"
#import "RecommandBlogTableViewCell.h"
#import "NewLoginViewController.h"
#import "QuesAnsDetailViewController.h"
#import "SoftWareViewController.h"
#import "TranslationViewController.h"
#import "ActivityDetailViewController.h"
#import "NewCommentListViewController.h"
#import "OSCInformationDetailController.h"
#import "NewBlogDetailController.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "IMYWebView.h"
#import "OSCPushTypeControllerHelper.h"
#import "OSCShareManager.h" 
#import "OSCPhotoGroupView.h"
#import "OSCUserHomePageController.h"
#import "UIViewController+Segue.h"
#import "OSCReadingInfoManager.h"
#import "ReadingInfoModel.h"

#import "NSObject+Comment.h"
#import "UIView+Common.h"

#import "UMSocial.h"
#import "JDStatusBarNotification.h"
#import <MBProgressHUD.h>
#import <WebKit/WebKit.h>

static NSString *reuseIdentifierHeadView = @"BlogDetailHeadView";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";

#define Large_Frame  (CGRect){{0,0},{40,25}}
#define Medium_Frame (CGRect){{0,0},{30,25}}
#define Small_Frame  (CGRect){{0,0},{25,25}}
#define screen_width [UIScreen mainScreen].bounds.size.width

@interface NewBlogDetailController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, IMYWebViewDelegate,OSCPopInputViewDelegate,CommentTextViewDelegate>
{
    CGFloat _headViewHeight;
}

@property (nonatomic, strong) OSCListItem *blogDetail;
@property (nonatomic, strong) NSMutableArray *blogDetailRecommends;
@property (nonatomic, assign) NSInteger blogId;

@property (nonatomic, strong) UIButton *rightBarBtn;
@property (nonatomic,assign) BOOL isReboundTop;
@property (nonatomic,assign) CGPoint readingOffest;

@property (nonatomic, strong) BlogDetailHeadView *blogHeadView;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, assign) CGFloat userInfoHeight;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, assign) BOOL webViewComplete;
@property (nonatomic, strong) NSString *titleStr;//文章标题

//被评论的某条评论的信息
@property (nonatomic) NSInteger beRepliedCommentAuthorId;
@property (nonatomic) NSInteger beRepliedCommentId;

@property (nonatomic, strong)UIView *backView;
@property (nonatomic, strong)UIView *tapView;

@property (nonatomic, strong) ReadingInfoModel *readInfoM;//用户阅读习惯
@property (nonatomic, strong) NSDate *startRead;//开始阅读
@property (nonatomic, strong) NSDate *endRead;//结束阅读

@property (nonatomic, strong)OSCPopInputView *inputView;

@property (nonatomic,assign) BOOL isShowEditView;

@end

@implementation NewBlogDetailController
{
    NSString* _HtmlBody;
    NSArray<NSString* >* _hockImgsName;///< 存放全部被hock的图片的  src(原src) & 替换了src之后的链接
    NSString* _hockCommentImgsName;///< 拼接全部hock的图片的src 解决使用for循环来判断webView请求发起
    NSURL* _defaultPicUrl;///< 下载失败或者开启非wifi环境下不加载时显示的图片
    NSUInteger _hockImgsCount;
    
    NSString* _requestUrl;
    NSDictionary* _parameter;
}

- (instancetype)initWithDetailId:(NSInteger)blogID{
    self = [super init];
    if (self) {
        self.blogId = blogID;
        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_DETAIL];
        _parameter = @{@"id" : @(blogID),
                       @"type" : @(3)};
        _blogDetailRecommends = [NSMutableArray new];
        
        _defaultPicUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"shaking" ofType:nil]];
        
        ///缓存读取
        _HtmlBody = @"";
        NSString* resourceName = [NSObject cacheResourceNameWithURL:_requestUrl parameterDictionaryDesc:_parameter.description];
        NSDictionary* response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_temporary];
        if (response && response[@"body"]) {
            _blogDetail = [OSCListItem osc_modelWithDictionary:response];
            _blogDetailRecommends = _blogDetail.abouts.mutableCopy;
            
            NSDictionary *data = @{@"content":  _blogDetail.body};
            _blogDetail.body = [Utils HTMLWithData:data
                                     usingTemplate:@"blog"];
//            _blogDetail.body = [self handleWebViewImgsWithBody:_blogDetail.body];
        }else{
            response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_detail];
            if (response && response[@"body"]) {
                _blogDetail = [OSCListItem osc_modelWithDictionary:response];
                _blogDetailRecommends = _blogDetail.abouts.mutableCopy;
                
                NSDictionary *data = @{@"content":  _blogDetail.body};
                _blogDetail.body = [Utils HTMLWithData:data
                                         usingTemplate:@"blog"];
//                _blogDetail.body = [self handleWebViewImgsWithBody:_blogDetail.body];
            }
        }
    }
    return self;
}

#pragma mark --- life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"博客详情";
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self insertNewReadInfo];
    [self handleNoti];
    [self layoutUI];
    [self getBlogData];
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _isShowEditView = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self hideHubView:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateRightButton:_blogDetail.statistics.comment];
    //开始到详情的的时间，每次进来都会更新
    self.startRead = [NSDate date];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!_isShowEditView) {
        [self showEditView];
        _isShowEditView = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.endRead = [NSDate date];
    NSTimeInterval timeInterval = [self.endRead timeIntervalSinceDate:self.startRead];
    self.readInfoM.stay += timeInterval;
    //更新单条数据  阅读时间
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET read_time = '%ld' WHERE start_time = '%ld'",(long)self.readInfoM.stay, (long)self.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
}

- (void)dealloc {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 图片下载通知WebView
- (void)webViewImageNotication:(NSNotification* )noti
{
    NSDictionary* info = noti.object;
    
    BOOL isdownlaoded   = [info[WebViewImage_Notication_IsDownloaded_Key] boolValue];
    NSString* imagePath = info[WebViewImage_Notication_UseImagePath_Key];
    
    if ([_hockCommentImgsName containsString:imagePath]) {
        if (!isdownlaoded) {
            _blogDetail.body = [_blogDetail.body stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@",[NSObject webViewImagesCacheFolderPath],imagePath] withString:_defaultPicUrl.absoluteString];
        }
        _hockImgsCount ++;
    }
    
    if (_hockImgsCount == _hockImgsName.count) {
        [_blogHeadView.webView loadHTMLString:_blogDetail.body baseURL:[NSBundle mainBundle].resourceURL];
        _HtmlBody = _blogDetail.body;
    }
}

#pragma mark - hock webView handle
- (NSString* )handleWebViewImgsWithBody:(NSString* )htmlStr
{
    NSString* imgRegularStr = @"<img[^<>]*?\\ssrc=['\"]?(.*?)['\"].*?>";//匹配HTML标签中的IMG
    NSRegularExpression* re = [NSRegularExpression regularExpressionWithPattern:imgRegularStr options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray<NSTextCheckingResult *> * checkResults = [re matchesInString:htmlStr options:NSMatchingReportProgress range:NSMakeRange(0, htmlStr.length)];
    NSMutableArray* mutableArr = [NSMutableArray arrayWithCapacity:checkResults.count];
    NSMutableArray* replaceArr = [NSMutableArray arrayWithCapacity:checkResults.count];
    NSMutableString* hockCommentImgsName = [NSMutableString string];

    for (NSTextCheckingResult* checkingResult in checkResults) {
        NSString* srcStr = [htmlStr substringWithRange:checkingResult.range];
        if ([srcStr containsString:OSC_Instation_Static_Image_Path]){
            [mutableArr addObject:srcStr];
            NSString* originStr = [srcStr stringByReplacingOccurrencesOfString:OSC_Instation_Static_Image_Path withString:[NSObject webViewImagesCacheFolderPath]];
            NSString* lastPath = [[originStr componentsSeparatedByString:[NSObject webViewImagesCacheFolderPath] ] lastObject];
            lastPath = [lastPath stringByReplacingOccurrencesOfString:@"/" withString:@""];
            NSString* handlePath = [NSString stringWithFormat:@"%@%@/%@",
                                     [[originStr componentsSeparatedByString:[NSObject webViewImagesCacheFolderPath] ] firstObject],
                                    [NSObject webViewImagesCacheFolderPath],
                                    lastPath];
            [replaceArr addObject:handlePath];
            [hockCommentImgsName appendString:[NSString stringWithFormat:@"/%@",srcStr]];
        }else if ([srcStr containsString:OSC_Instation_Static_Image_Path_http]){
            [mutableArr addObject:srcStr];
            NSString* originStr = [srcStr stringByReplacingOccurrencesOfString:OSC_Instation_Static_Image_Path withString:[NSObject webViewImagesCacheFolderPath]];
            NSString* lastPath = [[originStr componentsSeparatedByString:[NSObject webViewImagesCacheFolderPath] ] lastObject];
            lastPath = [lastPath stringByReplacingOccurrencesOfString:@"/" withString:@""];
            NSString* handlePath = [NSString stringWithFormat:@"%@%@/%@",
                                    [[originStr componentsSeparatedByString:[NSObject webViewImagesCacheFolderPath] ] firstObject],
                                    [NSObject webViewImagesCacheFolderPath],
                                    lastPath];
            [replaceArr addObject:handlePath];
            [hockCommentImgsName appendString:[NSString stringWithFormat:@"/%@",srcStr]];
        }
    }

    _hockImgsName = mutableArr.copy;
    _hockCommentImgsName = hockCommentImgsName.copy;
    
    for (int i = 0; i < _hockImgsName.count; i++) {
        NSString* srcStr = _hockImgsName[i];
        NSString* replaceStr = replaceArr[i];
        htmlStr = [htmlStr stringByReplacingOccurrencesOfString:srcStr withString:replaceStr];
    }
    
    return htmlStr;
}



#pragma mark --- layout UI
- (void)layoutUI{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorColor = [UIColor separatorColor];
    self.tableView.bounces = NO;
    self.tableView.hidden = YES;
    _commentTextView.commentTextViewDelegate = self;
    [_commentTextView handleAttributeWithAttribute:[OSCPopInputView getDraftNoteById:[NSString stringWithFormat:@"%ld_%ld",InformationTypeBlog,(long)_blogId]]];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    
    _blogHeadView = [[BlogDetailHeadView alloc] initWithFrame:CGRectMake(0, 0, screen_width, _headViewHeight)];
    [_blogHeadView.relationButton addTarget:self action:@selector(favSelected) forControlEvents:UIControlEventTouchUpInside];
	
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToUserInfoView)];
	[_blogHeadView.portraitView addGestureRecognizer:gesture]; //点击用户头像跳转
	
    if (_blogDetail) {
        [self updateUIWithRequestSuccess];
    }
}

#pragma mark - MBProgressHUD
- (void)hideHubView:(NSTimeInterval)timeInterval{
    [_hud hideAnimated:YES afterDelay:timeInterval];
    [[self.view viewWithTag:10] removeFromSuperview];
}

#pragma mark - handleNoti
- (void)handleNoti{
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    //图片下载 hock
    //        [[NSNotificationCenter defaultCenter] addObserver:self
    //                                                 selector:@selector(webViewImageNotication:)
    //                                                     name:downloaded_noti_name
    //                                                   object:nil];
}

#pragma mark - 获取博客详情
-(void)getBlogData{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:_requestUrl
     parameters:_parameter
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                _blogDetail = [OSCListItem osc_modelWithDictionary:responseObject[@"result"]];
                _blogDetailRecommends = _blogDetail.abouts.mutableCopy;
                
                self.titleStr = _blogDetail.title;
                
                NSDictionary *data = @{@"content":  _blogDetail.body};
                _blogDetail.body = [Utils HTMLWithData:data
                                         usingTemplate:@"blog"];
//                _blogDetail.body = [self handleWebViewImgsWithBody:_blogDetail.body];
                
                
                //用户阅读信息
                self.readInfoM.url =  _blogDetail.href;//地址
                self.readInfoM.is_collect = _blogDetail.favorite;//收藏
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET url = '%@', collected = %@  WHERE start_time = '%ld'",self.readInfoM.url, @(self.readInfoM.is_collect), (long)self.readInfoM.operate_time];
                [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];

                
                /**  cache handle */
                NSString* resourceName = [NSObject cacheResourceNameWithURL:_requestUrl parameterDictionaryDesc:_parameter.description];
                [NSObject handleResponseObject:responseObject[@"result"] resource:resourceName cacheType:SandboxCacheType_temporary];
                if (_blogDetail.favorite) {
                    [NSObject handleResponseObject:responseObject[@"result"] resource:resourceName cacheType:SandboxCacheType_detail];
                }
                /**  cache handle */

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUIWithRequestSuccess];
                });
            }else{
                _hud.hidden = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.view showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:responseObject[@"message"]];
                });
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

- (void)updateUIWithRequestSuccess{
    [self updateFavButtonWithIsCollected:_blogDetail.favorite];
    [self updateRightButton:_blogDetail.statistics.comment];
    _rightBarBtn.enabled = _webViewComplete;
    self.navigationItem.rightBarButtonItem.enabled = _webViewComplete;
    [self refreshHeadView];
}


#pragma mark - refreshHeadView
- (void)refreshHeadView
{
    if (_blogDetail != nil) {
        CGFloat titleHeight = (CGFloat)[_blogDetail.title boundingRectWithSize:(CGSize){(screen_width - 32),MAXFLOAT}
                                                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                    attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:22]}
                            
                                                                       context:nil].size.height;
        CGFloat abstractHeight = 0;
        if (_blogDetail.summary.length > 0) {
            abstractHeight = (CGFloat)[_blogDetail.summary boundingRectWithSize:(CGSize){(screen_width - 32), MAXFLOAT}
                                                                                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                                                                      attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}
                                                                                                                         context:nil].size.height;
        }
        
        CGFloat viewHeight = 0;
        viewHeight += titleHeight;
        viewHeight = abstractHeight > 0 ? viewHeight + abstractHeight + 17 : viewHeight;

        _blogHeadView.blogDetail = _blogDetail;
        _userInfoHeight = 121 + viewHeight;
        
        _blogHeadView.webView.delegate = self;
        if (![_HtmlBody isEqualToString:_blogDetail.body]) {
            [_blogHeadView.webView loadHTMLString:_blogDetail.body baseURL:[NSBundle mainBundle].resourceURL];
            _HtmlBody = _blogDetail.body;
        }
    }
}

- (void)updateHeaderViewFrame
{
    _webViewHeight = _webViewHeight + 32;
    _headViewHeight = _userInfoHeight + _webViewHeight;
    _blogHeadView.frame = (CGRect){{0,0},{kScreenSize.width,_headViewHeight}};
}

- (void)didReceiveMemoryWarning {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [super didReceiveMemoryWarning];
}

#pragma mark --- update RightButton
-(void)updateRightButton:(NSInteger)commentCount
{
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarBtn.userInteractionEnabled = YES;
    _rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_rightBarBtn addTarget:self action:@selector(rightBarButtonScrollToCommitSection) forControlEvents:UIControlEventTouchUpInside];
    [_rightBarBtn setTitle:@"" forState:UIControlStateNormal];
    _rightBarBtn.titleEdgeInsets = UIEdgeInsetsMake(-4, 0, 0, 0);
    [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
    
    if (commentCount >= 999) {
        _rightBarBtn.frame = Large_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_4_appbar"] forState:UIControlStateNormal];
        [_rightBarBtn setTitle:@"999+" forState:UIControlStateNormal];
    } else if (commentCount >= 100){
        _rightBarBtn.frame = Medium_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_3_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)_blogDetail.statistics.comment];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    } else{
        _rightBarBtn.frame = Small_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)_blogDetail.statistics.comment];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonScrollToCommitSection
{
    if (_blogDetail.statistics.comment > 0) {
        NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:InformationTypeBlog sourceID:_blogDetail.id titleStr:self.titleStr];
        
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
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"暂无评论";
        
        [HUD hideAnimated:YES afterDelay:2];
    }
    
}

#pragma mark - fav关注
- (void)favSelected
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        
        NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_USER_RELATION_REVERSE];
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        [manger POST:blogDetailUrlStr
          parameters:@{
                       @"id"  : @(_blogDetail.author.id),
                       }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"] integerValue]== 1) {
                     _blogDetail.author.relation = [responseObject[@"result"][@"relation"] integerValue];
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self refreshHeadView];
                 });
             } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 NSLog(@"%@",error);
             }];
    }
    
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_blogDetailRecommends.count > 0) {
        RecommandBlogTableViewCell *recommandBlogCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
        
        if (_blogDetailRecommends.count > 0) {
            OSCAbout *about = _blogDetailRecommends[indexPath.row];
            recommandBlogCell.abouts = about;
            recommandBlogCell.hiddenLine = _blogDetailRecommends.count - 1 == indexPath.row ? YES : NO;
        }
        
        recommandBlogCell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        recommandBlogCell.selectedBackgroundView = [[UIView alloc] initWithFrame:recommandBlogCell.frame];
        recommandBlogCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        
        return recommandBlogCell;
    }
    
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_blogDetailRecommends.count > 0) {
        return _blogDetailRecommends.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _blogDetailRecommends.count ? 1 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_blogDetailRecommends.count > 0) {
        return [self headerViewWithSectionTitle:@"相关文章"];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 32;
    }
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == _blogDetailRecommends.count-1) {
            return 72;
        } else {
            return 60;
        }
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        if (_blogDetailRecommends.count > 0) {
            OSCAbout *detailRecommend = _blogDetailRecommends[indexPath.row];
            if (detailRecommend.type == 0) { detailRecommend.type = 3; }
            UIViewController* pushViewController = [OSCPushTypeControllerHelper pushControllerGeneralWithType:detailRecommend.type detailContentID:detailRecommend.id];
            if (pushViewController) {
                [self.navigationController pushViewController:pushViewController animated:YES];
            }
        }
    }
}

#pragma mark - IMYWebView delegate
- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
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

- (void)webViewDidFinishLoad:(IMYWebView *)webView{
    [webView evaluateJavaScript:@"setImageClickFunction" completionHandler:nil];
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(NSNumber* result, NSError * error) {
        _webViewHeight = [result floatValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.tableView.hidden) {
                self.tableView.hidden = NO;
            }
            
            _webViewComplete = YES;
            _rightBarBtn.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            [self updateHeaderViewFrame];
            self.tableView.tableHeaderView = _blogHeadView;
            [self.tableView reloadData];
            [self hideHubView:0.5];
        });
    }];
}


#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 0.5)];
    topLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:topLineView];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 0.5)];
    bottomLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:bottomLineView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

#pragma mark - favorate action

- (void)updateFavButtonWithIsCollected:(BOOL)isCollected {
    if (isCollected) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    }else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

- (void)favAction:(id)sender {
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        NSDictionary *parameterDic = @{@"id"   : @(_blogDetail.id), @"type" : @(3)};
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        
        [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_FAVORITE_REVERSE]
          parameters:parameterDic
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 
                 BOOL isCollected = NO;
                 if ([responseObject[@"code"] integerValue]== 1) {
                     isCollected = [responseObject[@"result"][@"favorite"] boolValue];
                     
                     //更新单条数据 收藏
                     __weak typeof (self)weakSelf = self;
                     self.readInfoM.is_collect = isCollected ? 1 : 0;
                     NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET collected = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_collect, (long)weakSelf.readInfoM.operate_time];
                     [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                 }
                 
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = isCollected? @"收藏成功": @"取消收藏";
                 
                 [HUD hideAnimated:YES afterDelay:1];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self updateFavButtonWithIsCollected:isCollected];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，操作失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }];
    }
}

#pragma mark - share action
- (IBAction)shareAction:(id)sender {
    [_commentTextView resignFirstResponder];
    
    OSCShareManager *shareManeger = [OSCShareManager shareManager];
    [shareManeger showShareBoardWithShareType:InformationTypeBlog withModel:_blogDetail];
    
    //搜集分享信息
    //更新单条数据 收藏
    __weak typeof (self)weakSelf = self;
    self.readInfoM.is_share = 1;
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET share = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_share, (long)weakSelf.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
}

CGRect oldFrame;
- (void)keyboardWillShow:(NSNotification *)nsNotification
{
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardRect.size.height, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _tapView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardRect.size.height);
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self hideEditView];
}

#pragma mark - 发评论
- (void)sendCommentWithString:(NSString *)commentStr
{
    [NSObject updateToRecentlyContacterList:_blogDetail.author];
    
    //新 发评论
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithDictionary:
                                    @{
                                      @"sourceId"   : @(_blogDetail.id),
                                      @"type"       : @(3),
                                      @"content"    : commentStr,
                                      @"reAuthorId" : @(_beRepliedCommentAuthorId),
                                      @"replyId"    : @(_beRepliedCommentId)
                                      }
                                    ];
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX,OSCAPI_COMMENT_PUSH]
      parameters:paraDic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if ([responseObject[@"code"]integerValue] == 1) {
                 stauts.textLabel.text = @"评论成功";
                 [JDStatusBarNotification dismissAfter:2];
                 _blogDetail.statistics.comment +=1;
                 
                 _commentTextView.text = @"";
                 _commentTextView.placeholder = @"发表评论";
                 
                 //更新单条数据 评论
                 __weak typeof (self)weakSelf = self;
                 self.readInfoM.is_comment = 1;
                 NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET comment = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_comment, (long)weakSelf.readInfoM.operate_time];
                 [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                 
             } else {
                 stauts.textLabel.text = @"发布失败";
                 [JDStatusBarNotification dismissAfter:2];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self updateRightButton:_blogDetail.statistics.comment];
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             stauts.textLabel.text = @"网络异常，评论发送失败";
             [JDStatusBarNotification dismissAfter:2];
             [_commentTextView handleAttributeWithString:commentStr];
         }];
}

#pragma mark --- 转发
- (void)forwardTweetWithContent:(NSString *)contentText{
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"转发中.."];
    NSDictionary *parameDic = @{
                                @"content":contentText,
                                @"aboutId":@(_blogId),
                                @"aboutType":@(3)
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:[OSCAPI_V2_HTTPS_PREFIX stringByAppendingString:@"tweet"] parameters:parameDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            stauts.textLabel.text = @"转发成功";
        }else{
            stauts.textLabel.text = @"转发失败";
        }
        [JDStatusBarNotification dismissAfter:2];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        stauts.textLabel.text = @"转发失败";
        [JDStatusBarNotification dismissAfter:2];
    }];
}



#pragma mark -- 点击用户头像跳转

-(void) goToUserInfoView {
	OSCUserHomePageController *homePageVC = [[OSCUserHomePageController alloc] initWithUserID:_blogDetail.author.id];
	[self.navigationController pushViewController:homePageVC animated:YES];
}

#pragma CommentTextViewDelegate
- (void)ClickTextViewWithString:(NSString *)string
{
    [self showEditView];
}

#pragma --mark OSCPopInputViewDelegate

- (void)popInputViewDidDismiss:(OSCPopInputView *)popInputView
            draftNoteAttribute:(NSAttributedString *)draftNoteAttribute
{
    [_commentTextView handleAttributeWithAttribute:draftNoteAttribute];
}

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView
{
    OSCTweetFriendsViewController * vc = [OSCTweetFriendsViewController new];
    [self hideEditView];
    _isShowEditView = NO;
    [vc setSelectDone:^(NSString *result) {
        [self showEditView];
        [self.inputView insertAtrributeString2TextView:[Utils handle_TagString:result fontSize:14]];
        _isShowEditView = YES;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView
                    selectedforwarding:(BOOL)isSelectedForwarding
                           curTextView:(YYTextView *)textView
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    if (textView.text.length > 0) {
         [self sendCommentWithString:textView.text];
        if (isSelectedForwarding) {
            [self forwardTweetWithContent:textView.text];
        }
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"评论不能为空";
        [HUD hideAnimated:YES afterDelay:1];
    }
    [self.inputView clearDraftNote];
    [self hideEditView];
}





#pragma mark --- EditView status
- (void)showEditView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _backView = [[UIView alloc] initWithFrame:window.bounds];
    _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [_backView addSubview:self.inputView];
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
//    [_backView addGestureRecognizer:tapGR];
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 200 )];
    
    _tapView = tapView;
    tapView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
    [tapView addGestureRecognizer:tapGR];
    
    [_backView addSubview:tapView];
    
    
    [self.inputView activateInputView];
    [window addSubview:_backView];
}
- (void)hideEditView{
    [self.inputView freezeInputView];
    [UIView animateWithDuration:0.3 animations:^{
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.inputView.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) ;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
        _backView = nil;
    }];
}

- (void)touchBackWithGR:(UITapGestureRecognizer *)tapGR{
    CGPoint touchPoint = [tapGR locationInView:_backView];
    CGRect rect = CGRectMake(0, 0, kScreenSize.width, CGRectGetMinY(self.inputView.frame));
    if (CGRectContainsPoint(rect, touchPoint)) {
        [self hideEditView];
    }
}
#pragma mark --- lazy loading
- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Forwarding;
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld_%ld",InformationTypeBlog,(long)_blogId];
    }
    return _inputView;
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
        self.readInfoM.operate_type = OperateTypeBlog;
        
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
