//
//  QuesAnsDetailViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "QuesAnsDetailViewController.h"
#import "QuesAnsDetailHeadCell.h"
#import "OSCUserHomePageController.h"
#import "OSCNewComment.h"
#import "OSCBlogDetail.h"
#import "CommentDetailViewController.h"
#import "AppDelegate.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "NewLoginViewController.h"
#import "OSCQuesAnsDetailsContentView.h"
#import "enumList.h"
#import "OSCListItem.h"
#import "OSCCommentItem.h"
#import "OSCCommetCell.h" //
#import "GAMenuView.h"

#import "CommentTextView.h"
#import "JDStatusBarNotification.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "OSCShareManager.h" //分享工具栏
#import "OSCModelHandler.h"

#import "NSObject+Comment.h"
#import "UIView+Common.h"

#import <MBProgressHUD.h>
#import <AFNetworking.h>
#import "UMSocial.h"
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MJRefresh.h>

#import "UIViewController+Segue.h"
#import "OSCReadingInfoManager.h"
#import "ReadingInfoModel.h"

static NSString *quesAnsDetailHeadReuseIdentifier = @"QuesAnsDetailHeadCell";

@interface QuesAnsDetailViewController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, UITextFieldDelegate,CommentTextViewDelegate, OSCPopInputViewDelegate, OSCQuestionAnsDetailDelegate, OSCCommetCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

@property (weak, nonatomic) IBOutlet CommentTextView *commendTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (nonatomic, strong) OSCListItem *questionDetail;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, assign) CGFloat webViewHeight;

@property (nonatomic, copy) NSString *nextPageToken;

@property (nonatomic, strong) UITapGestureRecognizer *tap;
//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIView *tapView;

@property (nonatomic,strong) OSCQuesAnsDetailsContentView *headerView;

@property (nonatomic,assign) BOOL isShowEditView;

@property (nonatomic,strong) NSString *requstUrl;
@property (nonatomic,strong) NSDictionary *pramerDic;
@property (nonatomic, assign) NSInteger questionID;

@property (nonatomic, strong) ReadingInfoModel *readInfoM;//用户阅读习惯
@property (nonatomic, strong) NSDate *startRead;//开始阅读
@property (nonatomic, strong) NSDate *endRead;//结束阅读

@end

@implementation QuesAnsDetailViewController

- (instancetype)initWithDetailID:(NSInteger)detailID{
    self = [super init];
    if (self) {
        _questionID = detailID;
        _requstUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX , OSCAPI_DETAIL];
        _pramerDic = @{@"id"   : @(detailID),
                       @"type" : @(InformationTypeForum)};
        
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self insertNewReadInfo];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initialized];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getCommentsForQuestion:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getCommentsForQuestion:NO];
    }];
    
    

    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_more_normal"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(rightBarButtonClicked)];
    [self getCommentsForQuestion:YES];
    [self getDetailForQuestion];
    /* 待调试 */
//    [self.tableView.mj_footer beginRefreshing]; 
	
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
	
	[self showHubView];
    _isShowEditView = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //开始到详情的的时间，每次进来都会更新
    self.startRead = [NSDate date];
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


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!_isShowEditView) {
        [self showEditView];
        _isShowEditView = YES;
    }
}

- (void)didReceiveMemoryWarning{
    [self.navigationController popViewControllerAnimated:YES];

    [super didReceiveMemoryWarning];
}
#pragma mark --- 
-(void)initialized{
    _headerView = [[OSCQuesAnsDetailsContentView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _headerView.delegate = self;
    
    _comments = [NSMutableArray new];
    _nextPageToken = @"";
    
    self.commendTextView.commentTextViewDelegate = self;
    self.commendTextView.placeholder = @"我要回答";
    [self.commendTextView handleAttributeWithAttribute:[OSCPopInputView getDraftNoteById:[NSString stringWithFormat:@"%ld_%ld",InformationTypeForum,(long)self.questionID]]];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"QuesAnsDetailHeadCell" bundle:nil] forCellReuseIdentifier:quesAnsDetailHeadReuseIdentifier];
    [self.tableView registerClass:[OSCCommetCell class] forCellReuseIdentifier:OSCCommetCellIdentifier];
}


#pragma mark - 获取数据
- (void)getDetailForQuestion
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:_requstUrl
     parameters:_pramerDic
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _questionDetail = [OSCListItem osc_modelWithDictionary:responseObject[@"result"]];
                
                //用户阅读信息
                self.readInfoM.url =  _questionDetail.href;//地址
                self.readInfoM.is_collect = _questionDetail.favorite;//收藏
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET url = '%@', collected = %@  WHERE start_time = '%ld'",self.readInfoM.url, @(self.readInfoM.is_collect), (long)self.readInfoM.operate_time];
                [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];

                
                NSDictionary *data;
                if (!_questionDetail.body || [_questionDetail.body isEqual:[NSNull null]]) {
                    data = @{@"content": @"  "};
                }else{
                    data = @{@"content":  _questionDetail.body};
                }
                _questionDetail.body = [Utils HTMLWithData:data
                                          usingTemplate:@"newTweet"];
                
                self.title = [NSString stringWithFormat:@"%ld个回答",(long)_questionDetail.statistics.comment];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setFavButtonImage:_questionDetail.favorite];
                    _headerView.question = _questionDetail;
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

#pragma mark - 获取评论数组
- (void)getCommentsForQuestion:(BOOL)isRefresh
{
    
    NSString *qCommentUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENTS_LIST];
    NSMutableDictionary *mutableParamDic = @{
                               @"sourceId"  : @(self.questionID),
                               @"type"      : @(2),
                               @"parts"     : @"refer,reply",
                               @"order"     : @(1),
                               }.mutableCopy;
    if (!isRefresh) {//上拉刷新
        [mutableParamDic setValue:_nextPageToken forKey:@"pageToken"];
    }
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:qCommentUrlStr
     parameters:mutableParamDic.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                NSArray *jsonItems = result[@"items"]?:@[];
                NSArray *array;
                if (jsonItems.count > 0) {
                    array = [NSArray osc_modelArrayWithClass:[OSCCommentItem class] json:jsonItems];
                }
                for (OSCCommentItem *item in array) {
                    [item calculateLayout:NO];
                }
                
                _nextPageToken = result[@"nextPageToken"];
                
                if (isRefresh) {
                    [_comments removeAllObjects];
                }
                [_comments addObjectsFromArray:array];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (isRefresh) {
                        [self.tableView.mj_header endRefreshing];
                    }else{
                        if (array.count == 0) {
                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
                        }else{
                            [self.tableView.mj_footer endRefreshing];
                        }
                    }
                    [self.tableView reloadData];
                });
            }else {
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                }else{
                    [self.tableView.mj_footer endRefreshing];
                }
            }
            
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            [self.tableView reloadData];
            NSLog(@"error = %@",error);
        }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_comments.count > 0) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (_comments.count > 0) {
            return _comments.count;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_comments.count) {
        OSCCommentItem *commentItem = _comments[indexPath.row];
        OSCCommetCell *commentCell = [OSCCommetCell commetCellWithTableView:self.tableView
                                                                 identifier:OSCCommetCellIdentifier
                                                                  indexPath:indexPath
                                                                commentItem:commentItem
                                                        commentUxiliaryNode:CommentUxiliaryNode_comment
                                                            isNeedReference:NO];
        commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
        commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        commentCell.delegate = self;
        
        return commentCell;
    } else {
        return [UITableViewCell new];
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        if (_questionDetail.statistics.comment > 0) {
            return [self headerViewWithSectionTitle:[NSString stringWithFormat:@"回答(%lu)", (unsigned long)_questionDetail.statistics.comment]];
        }
        return [self headerViewWithSectionTitle:@"回答"];
    }
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (_comments.count) {
            OSCCommentItem *commentItem = _comments[indexPath.row];
            return commentItem.layoutHeight;
        } else {
            return 0;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32;
}
#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        if (_comments.count > indexPath.row) {
            OSCCommentItem *comment = _comments[indexPath.row];
            
            CommentDetailViewController *commentDetailVC = [[CommentDetailViewController alloc] initWithDetailCommentID:comment.id commentAuthorID:comment.author.id detailType:InformationTypeForum];
            commentDetailVC.questDetailId = self.questionID;
            [self.navigationController pushViewController:commentDetailVC animated:YES];
        }
        
    }
}

#pragma mark - OSCCommetCellDelegate
- (void)commetCellDidClickUserPortrait:(OSCCommetCell *)commetCell
{
    if (commetCell.commentItem.author.id > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:commetCell.commentItem.author.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

#pragma mark - WebView delegate
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height{
    _hud.hidden = YES;
    [self hideHubView];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headerView.frame = CGRectMake(0, 0, kScreenSize.width, height);
        self.tableView.tableHeaderView = self.headerView;
        [self.tableView reloadData];
    });
}

#pragma mark -- DIY_headerView
- (UIView*)headerViewWithSectionTitle:(NSString*)title {
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf9f9f9];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
    topLineView.backgroundColor = [UIColor separatorColor];
    [headerView addSubview:topLineView];
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 31, CGRectGetWidth([[UIScreen mainScreen]bounds]), 1)];
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

#pragma mark - 右导航栏按钮
- (void)rightBarButtonClicked
{
	
	if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
		return;
	} else {
        
        __block UITextField *repTextFieldText = [UITextField new];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"举报"
                                                                                 message:[NSString stringWithFormat:@"链接地址：%@", _questionDetail.href]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"举报原因";
            repTextFieldText = textField;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            return ;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            /* 新举报接口 */
            AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
            [manger POST:[NSString stringWithFormat:@"%@report", OSCAPI_V2_PREFIX]
              parameters:@{
                           @"sourceId"   : @(self.questionID),
                           @"type"       : @(2),
                           @"href"       : _questionDetail.href,//举报的文章地址
                           @"reason"     : @(1), //0 其他原因 1 广告 2 色情 3 翻墙 4 非IT话题
                           @"memo"		 : repTextFieldText.text,
                           }
                 success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                     if ([responseObject[@"code"]integerValue] == 1) {
                         MBProgressHUD *HUD = [Utils createHUD];
                         HUD.mode = MBProgressHUDModeCustomView;
                         HUD.label.text = @"举报完成，感谢亲~";
                         [HUD hideAnimated:YES afterDelay:1];
                     } else {
                         MBProgressHUD *HUD = [Utils createHUD];
                         HUD.mode = MBProgressHUDModeCustomView;
                         HUD.label.text = @"其他未知错误，请稍后再试~";
                         [HUD hideAnimated:YES afterDelay:1];
                     }
                 }
                 failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                     MBProgressHUD *HUD = [Utils createHUD];
                     HUD.mode = MBProgressHUDModeCustomView;
                     HUD.label.text = @"网络请求失败，请稍后再试~~";
                     [HUD hideAnimated:YES afterDelay:1];
                 }];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
	}//end of if
}


- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
//    _bottomLayoutConstraint.constant = _keyboardHeight;
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - sendMessage
- (void)sendMessageWithString:(NSString *)commentStr
{
    [NSObject updateToRecentlyContacterList:_questionDetail.author];
    
    //本地数据
    OSCCommentItem *locationCommentItem = [OSCCommentItem new];
    OSCUserItem *author = [Config myNewProfile];
    locationCommentItem.author = author;
    locationCommentItem.content = commentStr;
    locationCommentItem.pubDate = [Utils getCurrentTimeString];
    [_comments insertObject:locationCommentItem atIndex:0];
    _commendTextView.text = @"";
    _commendTextView.placeholder = @"发表评论";
    [self.tableView reloadData];
    
    //网络请求
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENT_PUSH]
      parameters:@{
                   @"sourceId"   : @(self.questionID),
                   @"type"       : @(2),
                   @"content"    : commentStr,
                   //                  @"replyId"    : @(0),
                   //                  @"reAuthorId" : @(0),
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if ([responseObject[@"code"]integerValue] == 1) {
                 stauts.textLabel.text = @"评论成功";
                 [JDStatusBarNotification dismissAfter:2];
                 
                 //更新单条数据 评论
                 __weak typeof (self)weakSelf = self;
                 self.readInfoM.is_comment = 1;
                 NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET comment = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_comment, (long)weakSelf.readInfoM.operate_time];
                 [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];

                 
             } else {
                 stauts.textLabel.text = @"发送失败";
                 [JDStatusBarNotification dismissAfter:2];
                 [_comments removeObjectAtIndex:0];
                 [_commendTextView handleAttributeWithString:locationCommentItem.content];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             stauts.textLabel.text = @"网络异常，评论发送失败";
             [JDStatusBarNotification dismissAfter:2];
             [_comments removeObjectAtIndex:0];
             [_commendTextView handleAttributeWithString:locationCommentItem.content];
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self.tableView reloadData];
             });
         }];
}

#pragma mark --- 转发
- (void)forwardTweetWithContent:(NSString *)contentText{
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"转发中.."];
    NSDictionary *parameDic = @{
                                @"content":contentText,
                                @"aboutId":@(_questionID),
                                @"aboutType":@(2)
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

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [_commendTextView resignFirstResponder];
    [self.view removeGestureRecognizer:_tap];
}

#pragma mark - 按钮功能
- (IBAction)buttonClick:(UIButton *)sender {
    
    if (sender.tag == 2) {
        [self shareForOthers];
    }
    //先判断是否登录
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        if (sender.tag == 1) {
            [self favOrNoFavType];
        }
    }
    
}

- (void)favOrNoFavType
{
    //收藏
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_FAVORITE_REVERSE];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger POST:blogDetailUrlStr
     parameters:@{
                  @"id"  : @(self.questionID),
                  @"type"      : @(2),
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue]== 1) {
                _questionDetail.favorite = [responseObject[@"result"][@"favorite"] boolValue];
                
                //更新单条数据 收藏
                __weak typeof (self)weakSelf = self;
                self.readInfoM.is_collect = _questionDetail.favorite ? 1 : 0;
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET collected = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_collect, (long)weakSelf.readInfoM.operate_time];
                [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                
                MBProgressHUD *HUD = [Utils createHUD];
                HUD.mode = MBProgressHUDModeCustomView;
                HUD.label.text = _questionDetail.favorite? @"收藏成功": @"取消收藏";
                
                [HUD hideAnimated:YES afterDelay:1];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setFavButtonImage:_questionDetail.favorite];

                [self.tableView reloadData];
            });
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

- (void)setFavButtonImage:(BOOL)isFav
{
    if (isFav) {
        [_favButton setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    } else {
        [_favButton setImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

- (void)shareForOthers
{
    //分享
    [_commendTextView resignFirstResponder];
    
    //搜集分享信息
    //更新单条数据 收藏
    __weak typeof (self)weakSelf = self;
    self.readInfoM.is_share = 1;
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET share = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_share, (long)weakSelf.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
    
    OSCShareManager *shareManeger = [OSCShareManager shareManager];
    [shareManeger showShareBoardWithShareType:InformationTypeForum withModel:_questionDetail];
}
#pragma mark --- HUD setting
- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    [self.view addSubview:coverView];
    _hud = [[MBProgressHUD alloc] initWithView:coverView];
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

#pragma CommentTextViewDelegate
- (void)ClickTextViewWithString:(NSString *)string
{
    [self showEditView];
}

#pragma --mark OSCPopInputViewDelegate

- (void)popInputViewDidDismiss:(OSCPopInputView *)popInputView
            draftNoteAttribute:(NSAttributedString *)draftNoteAttribute
{
    [_commendTextView handleAttributeWithAttribute:draftNoteAttribute];
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
        [self sendMessageWithString:textView.text];
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

- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Forwarding;
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld_%ld",InformationTypeForum,(long)self.questionID];
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
        self.readInfoM.operate_type = OperateTypeQuestion;
        
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
