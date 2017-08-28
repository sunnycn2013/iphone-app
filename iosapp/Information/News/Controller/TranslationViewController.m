//
//  TranslationViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TranslationViewController.h"
#import "TitleInfoTableViewCell.h"
#import "webAndAbsTableViewCell.h"
#import "RecommandBlogTableViewCell.h"
#import "ContentWebViewCell.h"

#import "RelatedSoftWareCell.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCBlogDetail.h"
#import "Utils.h"
#import "Config.h"
#import "OSCBlog.h"
#import "OSCSoftware.h"
#import "OSCNewHotBlogDetails.h"
#import "OSCModelHandler.h"
#import "NewLoginViewController.h"
#import "AppDelegate.h"
#import "NewCommentListViewController.h"//新评论列表
#import "OSCInformationHeaderView.h"
#import "OSCListItem.h"
#import "OSCShareManager.h" //分享工具栏
#import "OSCCommentItem.h"

#import "UIView+Common.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UMSocial.h"
#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "JDStatusBarNotification.h"

#import "UIViewController+Segue.h"
#import "OSCReadingInfoManager.h"
#import "ReadingInfoModel.h"

static NSString *titleInfoReuseIdentifier = @"TitleInfoTableViewCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";
static NSString *abstractReuseIdentifier = @"abstractTableViewCell";
static NSString *contentWebReuseIdentifier = @"contentWebTableViewCell";
static NSString *relatedSoftWareReuseIdentifier = @"RelatedSoftWareCell";


#define Large_Frame  (CGRect){{0,0},{40,25}}
#define Medium_Frame (CGRect){{0,0},{30,25}}
#define Small_Frame  (CGRect){{0,0},{25,25}}

@interface TranslationViewController ()<UITableViewDelegate, UITableViewDataSource,CommentTextViewDelegate,OSCPopInputViewDelegate,OSCInformationHeaderViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger translationId;
@property (nonatomic, copy) NSString *requestUrl;
@property (nonatomic, strong) NSDictionary *parameter;;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet CommentTextView *commentTextView;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic, strong) OSCListItem *translationDetails;
@property (nonatomic, strong) NSMutableArray *translationDetailComments;
@property (nonatomic) BOOL isExistRelatedTranslation;      //存在相关软件的信息
@property (nonatomic,assign)BOOL isShowEditView;

//被评论的某条评论的信息
@property (nonatomic) NSInteger beRepliedCommentAuthorId;
@property (nonatomic) NSInteger beRepliedCommentId;

@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) MBProgressHUD *hud;
//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic,strong) OSCNewHotBlogDetails *detail;
@property (nonatomic, copy) NSString *mURL;
@property (nonatomic, strong) NSString *titleStr;//博客标题
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIButton *rightBarBtn;

@property (nonatomic,assign) BOOL isReboundTop;
@property (nonatomic,assign) CGPoint readingOffest;

@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIView *tapView;
@property (nonatomic,strong) OSCInformationHeaderView *headerView;

@property (nonatomic, strong) ReadingInfoModel *readInfoM;//用户阅读习惯
@property (nonatomic, strong) NSDate *startRead;//开始阅读
@property (nonatomic, strong) NSDate *endRead;//结束阅读

@end

@implementation TranslationViewController

- (instancetype)initWithTranslationID:(NSInteger)translationID
{
    self = [super init];
    if (self) {
        self.translationId = translationID;
        self.requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX, OSCAPI_DETAIL];
        self.parameter = @{ @"id"   : @(self.translationId),
                            @"type" : @(InformationTypeTranslation)};
    }
    return self;
}

- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    [self.view addSubview:coverView];
    _hud = [[MBProgressHUD alloc] initWithView:coverView];
    _hud.center = coverView.center;
    _hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    [coverView addSubview:_hud];
    [_hud showAnimated:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}
- (void)hideHubView {
    [_hud hideAnimated:YES];
    [[self.view viewWithTag:10] removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self insertNewReadInfo];
    
    _headerView = [[OSCInformationHeaderView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _headerView.delegate = self;
    
    self.title = @"翻译详情";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.commentTextView.commentTextViewDelegate = self;
    [self.commentTextView handleAttributeWithAttribute:[OSCPopInputView getDraftNoteById:[NSString stringWithFormat:@"%ld_%ld",InformationTypeTranslation,_translationId]]];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TitleInfoTableViewCell" bundle:nil] forCellReuseIdentifier:titleInfoReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"webAndAbsTableViewCell" bundle:nil] forCellReuseIdentifier:abstractReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContentWebViewCell" bundle:nil] forCellReuseIdentifier:contentWebReuseIdentifier];

    [self.tableView registerNib:[UINib nibWithNibName:@"RelatedSoftWareCell" bundle:nil] forCellReuseIdentifier:relatedSoftWareReuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    
    // 添加等待动画
    [self showHubView];
    
    [self getTranslationData];
//    [self getTranslationComments];
    
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarBtn.userInteractionEnabled = YES;
    _rightBarBtn.frame  = CGRectMake(0, 0, 27, 20);
    _rightBarBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    _rightBarBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [_rightBarBtn addTarget:self action:@selector(rightBarButtonScrollToCommitSection) forControlEvents:UIControlEventTouchUpInside];
    _rightBarBtn.titleEdgeInsets = UIEdgeInsetsMake(-3, 0, 0, 0);
    
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _isShowEditView = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    
    [self hideHubView];
}

-(void)updateRightButton:(NSInteger)commentCount{
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
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)commentCount];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    } else{
        _rightBarBtn.frame = Small_Frame;
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_comment_appbar"] forState:UIControlStateNormal];
        NSString* titleStr = [NSString stringWithFormat:@"%ld",(long)commentCount];
        [_rightBarBtn setTitle:titleStr forState:UIControlStateNormal];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
    
}

#pragma mark - 右导航栏按钮
- (void)rightBarButtonScrollToCommitSection
{
    if (_translationDetails.statistics.comment > 0) {
        NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:InformationTypeTranslation sourceID:self.translationId titleStr:self.titleStr];//

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
#pragma mark - 获取翻译详情
- (void)getTranslationData {
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:self.requestUrl
     parameters:self.parameter
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _translationDetails = [OSCListItem osc_modelWithDictionary:responseObject[@"result"]];
                
                self.titleStr = _translationDetails.title;
                NSDictionary *data = @{@"content":  _translationDetails.body};
                _translationDetails.body = [Utils HTMLWithData:data
                                                 usingTemplate:@"blog"];
                
                //用户阅读信息
                self.readInfoM.url =  _translationDetails.href;//地址
                self.readInfoM.is_collect = _translationDetails.favorite;//收藏
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET url = '%@', collected = %@  WHERE start_time = '%ld'",self.readInfoM.url, @(self.readInfoM.is_collect), (long)self.readInfoM.operate_time];
                [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateFavButtonWithIsCollected:_translationDetails.favorite];
                    [self updateRightButton:_translationDetails.statistics.comment];
                    _rightBarBtn.enabled = NO;
                    self.navigationItem.rightBarButtonItem.enabled = NO;
                    _headerView.newsModel = _translationDetails;
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

#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(16, 0, 100, 16)];
    titleLabel.center = CGPointMake(titleLabel.center.x, headerView.center.y);
    titleLabel.tag = 8;
    titleLabel.textColor = [UIColor colorWithHex:0x6a6a6a];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = title;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [UITableViewCell new];
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
        self.headerView.frame = CGRectMake(0, 0, kScreenSize.width - 16 * 2, height);
        self.tableView.tableHeaderView = self.headerView;
        [self hideHubView];
        _rightBarBtn.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView reloadData];
    });
}


#pragma mark - 回复某条评论
- (void)selectedToComment:(UIButton *)button
{
    OSCCommentItem *comment =  _translationDetailComments[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
        if (comment.author.id > 0) {
            _commentTextView.placeholder = [NSString stringWithFormat:@"@%@", comment.author];
            _beRepliedCommentId = comment.id;
            _beRepliedCommentAuthorId = comment.author.id;
        } else {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"该用户不存在，不可引用回复";
            [hud hideAnimated:YES afterDelay:1];
        }
        
    } else {
        _commentTextView.placeholder = @"发表评论";
    }
    
    [_commentTextView becomeFirstResponder];
}

#pragma mark - 发评论
- (void)sendCommentWithString:(NSString *)commentStr
{
    JDStatusBarView *staute = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
    NSInteger fixedTranslastionId = _translationId > 10000000 ? _translationId-10000000:_translationId;
    NSDictionary *paraDic = @{
                              @"sourceId":@(fixedTranslastionId),
                              @"type":@(4),
                              @"content":commentStr,
                              @"reAuthorId": @(_beRepliedCommentAuthorId),
                              @"replyId": @(_beRepliedCommentId)
                              };
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX,OSCAPI_COMMENT_PUSH]
      parameters:paraDic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if ([responseObject[@"code"]integerValue] == 1) {
                 staute.textLabel.text = @"评论成功";
                 [JDStatusBarNotification dismissAfter:2];
                 
                 //更新单条数据 评论
                 __weak typeof (self)weakSelf = self;
                 self.readInfoM.is_comment = 1;
                 NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET comment = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_comment, (long)weakSelf.readInfoM.operate_time];
                 [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                 
                 _translationDetails.statistics.comment ++ ;
                 _commentTextView.text = @"";
                 _commentTextView.placeholder = @"发表评论";
             }else {
                 staute.textLabel.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
                 [JDStatusBarNotification dismissAfter:2];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self updateRightButton:_translationDetails.statistics.comment];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             staute.textLabel.text = @"网络异常，评论发送失败";
             [JDStatusBarNotification dismissAfter:2];
             [_commentTextView handleAttributeWithString:commentStr];
         }];
}

#pragma mark --- 转发
- (void)forwardTweetWithContent:(NSString *)contentText{
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"转发中.."];
    NSDictionary *parameDic = @{
                                @"content":contentText,
                                @"aboutId":@(_translationId),
                                @"aboutType":@(4)
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

#pragma mark - 更新收藏状态
- (void)updateFavButtonWithIsCollected:(BOOL)isCollected
{
    if (isCollected) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    }else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}
#pragma mark - 收藏
- (IBAction)favClick:(id)sender {
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        
        NSDictionary *parameterDic =@{@"id"     : @(_translationId),
                                      @"type"   : @(4)};
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
}

#pragma mark - 分享
- (IBAction)shareClick:(id)sender {
    [_commentTextView resignFirstResponder];
    //搜集分享信息
    //更新单条数据 收藏
    __weak typeof (self)weakSelf = self;
    self.readInfoM.is_share = 1;
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET share = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_share, (long)weakSelf.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];

    
    OSCShareManager *shareManeger = [OSCShareManager shareManager];
    [shareManeger showShareBoardWithShareType:InformationTypeTranslation withModel:_translationDetails];
}

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
//    _bottomConstraint.constant = _keyboardHeight;
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - _keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _tapView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardRect.size.height);
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
    [self.view addGestureRecognizer:_tap];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self hideEditView];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commentTextView resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [self.navigationController popViewControllerAnimated:YES];
    [super didReceiveMemoryWarning];
    
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

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView{
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

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView selectedforwarding:(BOOL)isSelectedForwarding curTextView:(YYTextView *)textView{
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

#pragma mark - reading infomation collect
- (void)insertNewReadInfo {
    if ([Config getOwnID] == 0) {//用户没有登录，不搜集
        
    }else {
        //用户数据收集
        self.readInfoM = [[ReadingInfoModel alloc] init];
        self.readInfoM.user = [Config getOwnID];
        self.readInfoM.user_name = [Config getOwnUserName];
        self.readInfoM.operation = @"read";//
        self.readInfoM.operate_type = OperateTypeTranslate;
        
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

#pragma mark --- lazy load
- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Forwarding;
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld_%ld",InformationTypeTranslation,_translationId];
    }
    return _inputView;
}
@end
