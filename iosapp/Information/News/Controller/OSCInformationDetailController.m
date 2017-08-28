//
//  OSCInformationDetailController.m
//  iosapp
//
//  Created by Graphic-one on 16/9/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCInformationDetailController.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "OSCAPI.h"
#import "OSCInformationDetails.h"
#import "OSCModelHandler.h"
#import "OSCBlogDetail.h"
#import "OSCListItem.h"
#import "Utils.h"
#import "OSCInformationHeaderView.h"
#import "RelatedSoftWareCell.h"
#import "RecommandBlogTableViewCell.h"
#import "OSCUserHomePageController.h"
#import "OSCCommetCell.h"
#import "OSCCommentItem.h"
#import "NewLoginViewController.h"
#import "Config.h"
#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "JDStatusBarNotification.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "SoftWareViewController.h"
#import "NewCommentListViewController.h"
#import "QuesAnsDetailViewController.h"
#import "TranslationViewController.h"
#import "ActivityDetailViewController.h"
#import "OSCPushTypeControllerHelper.h"
#import "OSCShareManager.h"
#import "OSCPhotoGroupView.h"
#import "enumList.h"
#import "NSObject+Comment.h"
#import "UIView+Common.h"
#import "OSCReadingInfoManager.h"
#import "UINavigationController+Comment.h"
#import "UIViewController+Segue.h"


#import "ShareCommentView.h"
#import "ShareView.h"
#import "OSCShareInvitation.h"
#import "OSCReadingInfoManager.h"
#import "ReadingInfoModel.h"

#import <UMSocial.h>
#import <MBProgressHUD.h>

#define Large_Frame  (CGRect){{0,0},{40,25}}
#define Medium_Frame (CGRect){{0,0},{30,25}}
#define Small_Frame  (CGRect){{0,0},{25,25}}
#define kBottomHeight 46

static NSString *relatedSoftWareReuseIdentifier = @"RelatedSoftWareCell";
static NSString *recommandBlogReuseIdentifier = @"RecommandBlogTableViewCell";

@interface OSCInformationDetailController () <UITableViewDelegate,UITableViewDataSource,OSCInformationHeaderViewDelegate,CommentTextViewDelegate,OSCPopInputViewDelegate, OSCCommetCellDelegate,SelectBoardViewDelegate>

@property (nonatomic,assign) NSInteger informationID;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) OSCListItem *newsDetail;
@property (nonatomic,strong) NSMutableArray *newsDetailRecommends;
@property (nonatomic,strong) NSMutableArray *newsDetailHotComments;
@property (nonatomic,strong) OSCInformationHeaderView *headerView;
@property (nonatomic,strong) UIButton *rightBarBtn;
@property (nonatomic,strong) MBProgressHUD *hud;

//被评论的某条评论的信息
@property (nonatomic) NSInteger beRepliedCommentAuthorId;
@property (nonatomic) NSInteger beRepliedCommentId;
@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, strong) NSString *titleStr;//资讯文章标题
@property (nonatomic, assign) NSInteger selectIndexPath;

@property (nonatomic, strong) UIButton *favButton;
@property (nonatomic, strong) UIImage *shareImg;//分享的图片
@property (nonatomic, strong) ShareView *shareV;//蒙板

@property (nonatomic, strong) CommentTextView *commentTextView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *tapView;

@property (nonatomic, strong) OSCPopInputView *inputView;
@property (nonatomic, assign) BOOL isShowEditView;
@property (nonatomic, assign) BOOL webViewComplete;

@property (nonatomic, strong) ReadingInfoModel *readInfoM;//用户阅读习惯
@property (nonatomic, strong) NSDate *startRead;//开始阅读
@property (nonatomic, strong) NSDate *endRead;//结束阅读

@end

@implementation OSCInformationDetailController
{
    NSString* _HtmlBody;
    NSString* _requestUrl ;
    NSDictionary* _parameter;
}

- (instancetype)initWithInformationID:(NSInteger)informationID {
    self = [super init];
    if (self) {
        _informationID = informationID;
        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX, OSCAPI_DETAIL];
        _parameter = @{ @"id"   : @(_informationID),
                        @"type" : @(InformationTypeInfo)};
        
        /** 缓存读取 */
        _HtmlBody = @"";
        NSString* resourceName = [NSObject cacheResourceNameWithURL:_requestUrl parameterDictionaryDesc:_parameter.description];
        NSDictionary* response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_temporary];
        if (response && response[@"body"]) {
            _newsDetail = [OSCListItem osc_modelWithJSON:response];
            _newsDetailRecommends= _newsDetail.abouts.mutableCopy;
            NSDictionary *data = @{@"content":  _newsDetail.body?:@""};
            _newsDetail.body = [Utils HTMLWithData:data
                                     usingTemplate:@"blog"];
        }else{
            response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_detail];
            if (response && response[@"body"]) {
                _newsDetail = [OSCListItem osc_modelWithJSON:response];
                _newsDetailRecommends= _newsDetail.abouts.mutableCopy;
                NSDictionary *data = @{@"content":  _newsDetail.body?:@""};
                _newsDetail.body = [Utils HTMLWithData:data
                                         usingTemplate:@"blog"];
            }
        }

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self insertNewReadInfo];
    
    _newsDetailHotComments = [NSMutableArray new];
    
    [self setSelf];
    [self addContentView];
    [self addBottmView];
    
    [self getCommentDetail];
    [self getNewsData];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
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
}


- (void)didReceiveMemoryWarning {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [super didReceiveMemoryWarning];
}

- (void)setSelf{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"资讯详情";
}

- (void)addContentView{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64 - kBottomHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.sectionHeaderHeight = 32;
    [self.tableView registerNib:[UINib nibWithNibName:@"RecommandBlogTableViewCell" bundle:nil] forCellReuseIdentifier:recommandBlogReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"RelatedSoftWareCell" bundle:nil] forCellReuseIdentifier:relatedSoftWareReuseIdentifier];
    [self.tableView registerClass:[OSCCommetCell class] forCellReuseIdentifier:OSCCommetCellIdentifier];
    
    [self updateRightButton:0];
    if (_newsDetail) {
        [self updateUIWithRequestSuccess];
    }
}

- (void)addBottmView{
    UIView *bottomBackView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenSize.height - kBottomHeight, kScreenSize.width, kBottomHeight)];
    bottomBackView.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
    lineView.backgroundColor = [UIColor colorWithHex:0xd8d8d8];
    [bottomBackView addSubview:lineView];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake( kScreenSize.width - 40, 6, 30, 30);
    [shareButton setImage:[UIImage imageNamed:@"ic_share_black_pressed"] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackView addSubview:shareButton];
    
    _favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _favButton.frame = CGRectMake( kScreenSize.width - 75, 6, 30, 30);
    [_favButton setImage:[UIImage imageNamed:@"ic_fav_normal"] forState:UIControlStateNormal];
    [_favButton addTarget:self action:@selector(favClick) forControlEvents:UIControlEventTouchUpInside];
    [bottomBackView addSubview:_favButton];
    
    _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(8, 8,CGRectGetMinX(_favButton.frame) - 20, 30) WithPlaceholder:@"发表评论" WithFont:[UIFont systemFontOfSize:14.0]];
    _commentTextView.commentTextViewDelegate = self;
    [_commentTextView handleAttributeWithAttribute:[OSCPopInputView getDraftNoteById:[NSString stringWithFormat:@"%ld_%ld",(unsigned long)InformationTypeLinkNews,(long)(long)_informationID]]];
    [bottomBackView addSubview:_commentTextView];
    
    [self.view addSubview:bottomBackView];
}

#pragma --mark 网络请求
-(void)getNewsData{
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:_requestUrl
     parameters:_parameter
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                _newsDetail = [OSCListItem osc_modelWithJSON:responseObject[@"result"]];
                _newsDetailRecommends= _newsDetail.abouts.mutableCopy;
                self.titleStr = _newsDetail.title;
                NSDictionary *data = @{@"content":  _newsDetail.body?:@""};
                _newsDetail.body = [Utils HTMLWithData:data
                                          usingTemplate:@"blog"];
                
                //用户阅读信息
                self.readInfoM.url =  _newsDetail.href;//地址
                self.readInfoM.is_collect = _newsDetail.favorite;//收藏
                NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET url = '%@', collected = %@  WHERE start_time = '%ld'",self.readInfoM.url, @(self.readInfoM.is_collect), (long)self.readInfoM.operate_time];
                [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
                
                
                /** cacahe handle */
                NSString* resourcName = [NSObject cacheResourceNameWithURL:_requestUrl parameterDictionaryDesc:_parameter.description];
                [NSObject handleResponseObject:responseObject[@"result"] resource:resourcName cacheType:SandboxCacheType_temporary];
                if (_newsDetail.favorite) {
                    [NSObject handleResponseObject:responseObject[@"result"] resource:resourcName cacheType:SandboxCacheType_detail];
                }
                /** cacahe handle */
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateUIWithRequestSuccess];
                });
            } else {
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
    [self updateFavButtonWithIsCollected:_newsDetail.favorite];
    [self updateRightButton:_newsDetail.statistics.comment];
    
    _rightBarBtn.enabled = _webViewComplete;
    self.navigationItem.rightBarButtonItem.enabled = _webViewComplete;

    if (![_HtmlBody isEqualToString:_newsDetail.body]) {
        self.headerView.newsModel = _newsDetail;
        _HtmlBody = _newsDetail.body;
    }
}

//热门评论
-(void)getCommentDetail{
    NSString *newsDetailUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENTS_LIST];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];

    [manger GET:newsDetailUrlStr
     parameters:@{
                  @"sourceId"  : @(self.informationID),
                  @"type"      : @(6),
                  @"parts"     : @"refer",
                  @"order"     : @(2),
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"]integerValue] == 1) {
                NSArray *hotComments = [NSArray osc_modelArrayWithClass:[OSCCommentItem class] json:responseObject[@"result"][@"items"]];
                for (OSCCommentItem *item in hotComments) {
                    [item calculateLayout:YES];
                }
                
                [self filtNewHotComment:hotComments];
                if(_webViewComplete){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_tableView reloadData];
                    });
                }
            } else {
                
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

- (void)filtNewHotComment:(NSArray *)hotComments
{
    [hotComments enumerateObjectsUsingBlock:^(OSCCommentItem *commentItem, NSUInteger idx, BOOL * _Nonnull stop) {
        if (commentItem.vote > 0) {
            [_newsDetailHotComments addObject:commentItem];
        }
    }];
}

#pragma --mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0://与资讯有关的软件信息
        {
            NSInteger rows = 0;
            if (_newsDetail.software && _newsDetail.software.id != 0) {
                return rows = 1;
            } else if (_newsDetail.abouts.count > 0){
                return rows = _newsDetail.abouts.count;
            } else if (_newsDetailHotComments.count > 0) {
                if (_newsDetailHotComments.count <= 5) {
                    return _newsDetailHotComments.count + 1;
                } else {
                    return 6;
                }
            } else {
                return 0;
            }
            break;
        }
        case 1://相关资讯
        {
            if (_newsDetail.software && _newsDetail.abouts.count > 0) {
                return _newsDetail.abouts.count;
            } else if (_newsDetailHotComments.count > 0) {
                if (_newsDetailHotComments.count <= 5) {
                    return _newsDetailHotComments.count + 1;
                } else {
                    return 6;
                }
            } else {
                return 0;
            }
            break;
        }
        case 2://评论
        {
            if (_newsDetailHotComments.count > 0) {
                if (_newsDetailHotComments.count <= 5) {
                    return _newsDetailHotComments.count + 1;
                } else {
                    return 6;
                }
            } else {
                return 0;
            }
            break;
        }
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger sectionNumb = 0;
    if (_newsDetail.software && _newsDetail.software.id != 0) {
        sectionNumb ++;
    }
    if (_newsDetail.abouts.count > 0) {
        sectionNumb ++;
    }
    if(_newsDetailHotComments.count > 0){
        sectionNumb ++;
    }
    return sectionNumb;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0: {
            if (_newsDetail.software && _newsDetail.software.id != 0) {
                RelatedSoftWareCell *softWareCell = [tableView dequeueReusableCellWithIdentifier:relatedSoftWareReuseIdentifier forIndexPath:indexPath];
                softWareCell.titleLabel.text = _newsDetail.software.name.length ? _newsDetail.software.name : @"";
                softWareCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                return softWareCell;
            } else if (_newsDetailRecommends.count > 0){
                RecommandBlogTableViewCell *recommandNewsCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
                if (_newsDetailRecommends.count > 0) {
                    OSCAbout *about = _newsDetailRecommends[indexPath.row];
                    recommandNewsCell.abouts = about;
                    recommandNewsCell.hiddenLine = _newsDetailRecommends.count - 1 == indexPath.row ? YES : NO;
                }
                recommandNewsCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                return recommandNewsCell;
            } else if (_newsDetailHotComments.count > 0) {
                if (_newsDetailHotComments.count > 0) {
                    if (indexPath.row == _newsDetailHotComments.count) {
                        UITableViewCell *cell = [UITableViewCell new];
                        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                        cell.textLabel.text = @"更多评论";
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        cell.textLabel.font = [UIFont systemFontOfSize:14];
                        cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                        
                        return cell;
                    } else {
                        OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                        OSCCommetCell *commentCell = [OSCCommetCell commetCellWithTableView:self.tableView
                                                                                 identifier:OSCCommetCellIdentifier
                                                                                  indexPath:indexPath
                                                                                commentItem:commentItem
                                                                        commentUxiliaryNode:
                                                                        CommentUxiliaryNode_like
//                                                      |                  CommentUxiliaryNode_comment
                                                                            isNeedReference:YES];
                        commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
                        commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
                        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        commentCell.delegate = self;
                        
                        return commentCell;
                    }
                    
                } else {
                    UITableViewCell *cell = [UITableViewCell new];
                    cell.textLabel.text = @"还没有评论";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.font = [UIFont systemFontOfSize:14];
                    cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return cell;
                }
            }
        }
            break;
        case 1: {
            if (_newsDetail.software && _newsDetail.abouts.count > 0) {
                RecommandBlogTableViewCell *recommandNewsCell = [tableView dequeueReusableCellWithIdentifier:recommandBlogReuseIdentifier forIndexPath:indexPath];
                if (indexPath.row < _newsDetailRecommends.count) {
                    OSCAbout *about = _newsDetailRecommends[indexPath.row];
                    recommandNewsCell.abouts = about;
                    recommandNewsCell.hiddenLine = _newsDetailRecommends.count - 1 == indexPath.row ? YES : NO;
                    
                }
                recommandNewsCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                return recommandNewsCell;
            } else {
                if (_newsDetailHotComments.count > 0) {
                    if (_newsDetailHotComments.count <= 5) {
                        if (indexPath.row == _newsDetailHotComments.count) {
                            UITableViewCell *cell = [UITableViewCell new];
                            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                            cell.textLabel.text = @"更多评论";
                            cell.textLabel.textAlignment = NSTextAlignmentCenter;
                            cell.textLabel.font = [UIFont systemFontOfSize:14];
                            cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                            
                            return cell;
                        } else {
                            OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                            OSCCommetCell *commentCell = [OSCCommetCell commetCellWithTableView:self.tableView
                                                                                     identifier:OSCCommetCellIdentifier
                                                                                      indexPath:indexPath
                                                                                    commentItem:commentItem
                                                                            commentUxiliaryNode:CommentUxiliaryNode_like
//                                                          | CommentUxiliaryNode_comment
                                                                                isNeedReference:YES];
                            commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
                            commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
//                            commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
                            commentCell.delegate = self;
                            
                            return commentCell;
                        }
                    } else {
                        if (indexPath.row == 5) {
                            UITableViewCell *cell = [UITableViewCell new];
                            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                            cell.textLabel.text = @"更多评论";
                            cell.textLabel.textAlignment = NSTextAlignmentCenter;
                            cell.textLabel.font = [UIFont systemFontOfSize:14];
                            cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                            
                            return cell;
                        } else {
                            OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                            OSCCommetCell *commentCell = [OSCCommetCell commetCellWithTableView:self.tableView
                                                                                     identifier:OSCCommetCellIdentifier
                                                                                      indexPath:indexPath
                                                                                    commentItem:commentItem
                                                                            commentUxiliaryNode:CommentUxiliaryNode_like
//                                                          | CommentUxiliaryNode_comment
                                                                                isNeedReference:YES];
                            commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
                            commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
                            commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
                            commentCell.delegate = self;
                            
                            return commentCell;
                        }
                    }
                } else {
                    UITableViewCell *cell = [UITableViewCell new];
                    cell.textLabel.text = @"还没有评论";
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.font = [UIFont systemFontOfSize:14];
                    cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    return cell;
                }
            }
            
        }
            break;
        case 2: {
            if (_newsDetailHotComments.count > 0) {
                if (_newsDetailHotComments.count <= 5) {
                    if (indexPath.row == _newsDetailHotComments.count) {
                        UITableViewCell *cell = [UITableViewCell new];
                        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                        cell.textLabel.text = @"更多评论";
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        cell.textLabel.font = [UIFont systemFontOfSize:14];
                        cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                        
                        return cell;
                    } else {
                        OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                        OSCCommetCell *commentCell = [OSCCommetCell commetCellWithTableView:self.tableView
                                                                                 identifier:OSCCommetCellIdentifier
                                                                                  indexPath:indexPath
                                                                                commentItem:commentItem
                                                                        commentUxiliaryNode:
                                                      CommentUxiliaryNode_like
//                                                                            |CommentUxiliaryNode_comment
                                                                            isNeedReference:YES];
                        commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
                        commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
//                        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        commentCell.delegate = self;
                        
                        return commentCell;
                    }
                } else {
                    if (indexPath.row == 5) {
                        UITableViewCell *cell = [UITableViewCell new];
                        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
                        cell.textLabel.text = @"更多评论";
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        cell.textLabel.font = [UIFont systemFontOfSize:14];
                        cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                        
                        return cell;
                    } else {
                        OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                        OSCCommetCell *commentCell = [OSCCommetCell commetCellWithTableView:self.tableView
                                                                                 identifier:OSCCommetCellIdentifier
                                                                                  indexPath:indexPath
                                                                                commentItem:commentItem
                                                                        commentUxiliaryNode:CommentUxiliaryNode_like
//                                                      | CommentUxiliaryNode_comment
                                                                            isNeedReference:YES];
                        commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
                        commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
                        commentCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        commentCell.delegate = self;
                        
                        return commentCell;
                    }
                }
            } else {
                UITableViewCell *cell = [UITableViewCell new];
                cell.textLabel.text = @"还没有评论";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:14];
                cell.textLabel.textColor = [UIColor colorWithHex:0x24cf5f];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            }
            
        }
            break;
        default:
            break;
    }

    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (_newsDetail.software && _newsDetail.software.id != 0) {      //相关的软件详情
            SoftWareViewController* detailsViewController = [[SoftWareViewController alloc]initWithSoftWareID:_newsDetail.software.id];
            [detailsViewController setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:detailsViewController animated:YES];
        } else if (_newsDetail.abouts.count > 0) {     //相关推荐的资讯详情
            OSCAbout *detailRecommend = _newsDetailRecommends[indexPath.row];
            [self pushDetailsVcWithDetailModel:detailRecommend];
            
        } else if (_newsDetailHotComments.count > 0) {
            //资讯评论列表
            if (_newsDetailHotComments.count > 0 && ((_newsDetailHotComments.count <= 5 && indexPath.row == _newsDetailHotComments.count) || (_newsDetailHotComments.count > 5 && indexPath.row == 5))) {
                //TODO 新评论列表
                NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:InformationTypeInfo sourceID:self.informationID titleStr:self.titleStr];
                [self.navigationController pushViewController:newCommentVC animated:YES];
            }
        }
    } else if (indexPath.section == 1) {
        if (_newsDetail.software && _newsDetail.software.id != 0 && _newsDetail.abouts.count > 0) {
            OSCAbout *detailRecommend = _newsDetailRecommends[indexPath.row];
            [self pushDetailsVcWithDetailModel:detailRecommend];
        } else {
            
            //资讯评论列表
            if (_newsDetailHotComments.count > 0 && ((_newsDetailHotComments.count <= 5 && indexPath.row == _newsDetailHotComments.count) || (_newsDetailHotComments.count > 5 && indexPath.row == 5))) {
                // TODO 新评论列表
                NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:InformationTypeInfo sourceID:self.informationID titleStr:self.titleStr];
                [self.navigationController pushViewController:newCommentVC animated:YES];
            }
            
            
            else {
                
                //弹出蒙板
                self.shareV = [[ShareView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
                self.shareV.selV.delegate = self;
                self.shareV.selV.item = _newsDetailHotComments[indexPath.row];
                [self.shareV showView];
                
                //生成分享图片
                ShareCommentView *shareImgView = [[ShareCommentView alloc] initWithFrame:CGRectMake(0, 50, kScreenSize.width, kScreenSize.height - 50) CommentItem:_newsDetailHotComments[indexPath.row] title:self.titleStr];
                [shareImgView layoutIfNeeded];//重新绘制
                UIImage *img = [self convertViewToImage:shareImgView];
                self.shareImg = img;
               
                
            }
    
        }
    } else if (indexPath.section == 2) {
        
        if (_newsDetailHotComments.count > 0 && ((_newsDetailHotComments.count <= 5 && indexPath.row == _newsDetailHotComments.count) || (_newsDetailHotComments.count > 5 && indexPath.row == 5))) {
            //新评论列表
            NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:InformationTypeInfo sourceID:self.informationID titleStr:self.titleStr];
            [self.navigationController pushViewController:newCommentVC animated:YES];
        }
        
        else {
            
            //弹出蒙板
            self.shareV = [[ShareView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
            self.shareV.selV.delegate = self;
            self.shareV.selV.item = _newsDetailHotComments[indexPath.row];
            [self.shareV showView];
            
            //生成分享图片
            ShareCommentView *shareImgView = [[ShareCommentView alloc] initWithFrame:CGRectMake(0, 50, kScreenSize.width, kScreenSize.height - 50) CommentItem:_newsDetailHotComments[indexPath.row] title:self.titleStr];
            [shareImgView layoutIfNeeded];//重新绘制
            UIImage *img = [self convertViewToImage:shareImgView];
            self.shareImg = img;
            
        }
        
    }
}

#pragma --mark tableViewDelegate
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        if (_newsDetail.software && _newsDetail.software.id != 0) {
            return [self headerViewWithSectionTitle:@"相关软件"];
        } else if (_newsDetail.abouts.count > 0){
            return [self headerViewWithSectionTitle:@"相关资讯"];
        } else if (_newsDetailHotComments.count > 0) {
            return [self headerViewWithSectionTitle:@"热门评论"];
        }
    } else if (section == 1) {
        if (_newsDetail.software && _newsDetail.software.id != 0 && _newsDetail.abouts.count > 0) {
            return [self headerViewWithSectionTitle:@"相关资讯"];
        } else {
            if (_newsDetailHotComments.count > 0) {
                return [self headerViewWithSectionTitle:@"热门评论"];
            }
            return [self headerViewWithSectionTitle:@"评论"];
        }
        
    } else if (section == 2) {
        if (_newsDetailHotComments.count > 0) {
            return [self headerViewWithSectionTitle:@"热门评论"];
        }
        return [self headerViewWithSectionTitle:@"评论"];
    }
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            if (_newsDetail.software && _newsDetail.software.id != 0) {
                return 45;
            } else if (_newsDetail.abouts.count > 0){
                return indexPath.row == _newsDetail.abouts.count-1 ? 72 : 60;
            } else if (_newsDetailHotComments.count > 0) {
                
                if (_newsDetailHotComments.count <= 5) {
                    if (indexPath.row == _newsDetailHotComments.count) {
                        return 44;
                    } else {
                        OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                        return commentItem.layoutHeight;
                    }
                } else {
                    if (indexPath.row == 5) {
                        return 44;
                    } else {
                        OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                        return commentItem.layoutHeight;
                    }
                }
            }
            
            break;
        }
        case 1:
        {
            if (_newsDetail.software && _newsDetail.software.id != 0 && _newsDetail.abouts.count > 0) {
                return indexPath.row == _newsDetail.abouts.count-1 ? 72 : 60;
            } else {
                if (_newsDetailHotComments.count > 0) {
                    if (_newsDetailHotComments.count <= 5) {
                        if (indexPath.row == _newsDetailHotComments.count) {
                            return 44;
                        } else {
                            OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                            return commentItem.layoutHeight;
                        }
                    } else {
                        if (indexPath.row == 5) {
                            return 44;
                        } else {
                            OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                            return commentItem.layoutHeight;
                        }
                    }
                }
            }
            
            break;
        }
        case 2: {
            if (_newsDetailHotComments.count > 0) {
                if (_newsDetailHotComments.count <= 5) {
                    if (indexPath.row == _newsDetailHotComments.count) {
                        return 44;
                    } else {
                        OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                        return commentItem.layoutHeight;
                    }
                } else {
                    if (indexPath.row == 5) {
                        return 44;
                    } else {
                        OSCCommentItem *commentItem = _newsDetailHotComments[indexPath.row];
                        return commentItem.layoutHeight;
                    }
                }
            }
        }
        default:
            break;
    }
    return 0;
}

#pragma mark --- OSCInformationHeaderViewDelegate
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request{
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

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height{
    if (!_tableView.superview) {
        [self.view addSubview:_tableView];
    }
    _webViewComplete = YES;
    _hud.hidden = YES;
    _rightBarBtn.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.headerView.frame = CGRectMake(0, 0, kScreenSize.width - 16 * 2, height);
        self.tableView.tableHeaderView = self.headerView;
        [self.tableView reloadData];
    });
}

#pragma --mark 方法实现
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

#pragma mark --- update RightButton
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
    if (_newsDetail.statistics.comment > 0) {
        NewCommentListViewController *newCommentVC = [[NewCommentListViewController alloc] initWithCommentType:InformationTypeInfo sourceID:self.informationID titleStr:self.titleStr];
        
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

- (void)commetCellDidClickLikeButton:(OSCCommetCell* )commetCell
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        if (commetCell.commentItem.voteState != CommentStatusType_Like) {
            
            commetCell.commentItem.vote++;
            commetCell.commentItem.voteState = CommentStatusType_Like;
            
            [commetCell setVoteStatus:commetCell.commentItem animation:YES];
            
            AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
            JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论点赞中..."];
            [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENT_VOTE_REVERSE]
              parameters:@{
                           @"commentId"       : @(commetCell.commentItem.id),
                           @"commentAuthorId" : @(commetCell.commentItem.author.id),
                           @"sourceType"      : @(InformationTypeInfo),
                           @"voteOpt"         : @(1),
                           }
                 success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                     if ([responseObject[@"code"] integerValue] == 1) {
                         stauts.textLabel.text = @"点赞成功";
                         [JDStatusBarNotification dismissAfter:2];
                         
                         NSDictionary *result = responseObject[@"result"];
                         NSInteger vote = [result[@"vote"] integerValue];
                         NSInteger voteSate = [result[@"voteState"] integerValue];
                         
                         commetCell.commentItem.vote = vote;
                         commetCell.commentItem.voteState = voteSate;
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [commetCell setVoteStatus:commetCell.commentItem animation:NO];
                         });
                         
                     } else {
                         commetCell.commentItem.vote--;
                         commetCell.commentItem.voteState = CommentStatusType_None;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [commetCell setVoteStatus:commetCell.commentItem animation:NO];
                         });
                         stauts.textLabel.text = responseObject[@"message"];
                         [JDStatusBarNotification dismissAfter:2];
                     }
                 }
                 failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                     stauts.textLabel.text = @"网络错误，点赞失败";
                     [JDStatusBarNotification dismissAfter:2];
                     
                     commetCell.commentItem.vote--;
                     commetCell.commentItem.voteState = CommentStatusType_None;
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [commetCell setVoteStatus:commetCell.commentItem animation:NO];
                     });
                     
                 }];
        } else if (commetCell.commentItem.voteState == CommentStatusType_Like) {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"不支持取消点赞喔！";
            [hud hideAnimated:YES afterDelay:2];
        }
        
    }
}

- (void)commetCellDidClickCommentButton:(OSCCommetCell* )commetCell
{
    if (commetCell.commentItem.author.id > 0) {
        [self showEditView];
        _beRepliedCommentId = commetCell.commentItem.id;
        _beRepliedCommentAuthorId = commetCell.commentItem.author.id;
        [self.inputView insertAtrributeString2TextView:[Utils handle_TagString:[NSString stringWithFormat:@"@%@ ",commetCell.commentItem.author.name] fontSize:14]];
        
    } else {
        MBProgressHUD *hud = [Utils createHUD];
        hud.mode = MBProgressHUDModeCustomView;
        hud.label.text = @"该用户不存在，不可引用回复";
        [hud hideAnimated:YES afterDelay:1];
    }
}

#pragma mark - 回复某条评论
- (void)selectedToComment:(UIButton *)button
{
    OSCCommentItem *comment = _newsDetailHotComments[button.tag];
    
    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;
    
    if (_isReply) {
        if (comment.author.id > 0) {
            _commentTextView.placeholder = [NSString stringWithFormat:@"@%@ ", comment.author.name];
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
- (void)sendCommentWithString:(NSString *)commmentStr
{
    JDStatusBarView *staute = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
    //新 发评论
    NSInteger sourceId = _newsDetail.id;
    NSInteger type = 6;
    NSMutableDictionary *paraDic = [NSMutableDictionary dictionaryWithDictionary:
                                    @{
                                      @"sourceId":@(sourceId),
                                      @"type":@(type),
                                      @"content":commmentStr,
                                      @"reAuthorId": @(_beRepliedCommentAuthorId),
                                      @"replyId": @(_beRepliedCommentId)
                                      }
                                    ];
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
                 
                 _newsDetail.statistics.comment ++ ;
                 _commentTextView.text = @"";
                 _commentTextView.placeholder = @"发表评论";
             } else {
                 staute.textLabel.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
                 [JDStatusBarNotification dismissAfter:2];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self updateRightButton:(_newsDetail.statistics.comment)];
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             staute.textLabel.text = @"网络异常，评论发送失败";
             [JDStatusBarNotification dismissAfter:2];
             [_commentTextView handleAttributeWithString:commmentStr];
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
- (void)favClick{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        
        NSDictionary *parameterDic =@{@"id"     : @(_informationID),
                                      @"type"   : @(6)};
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

#pragma mark --- 转发
- (void)forwardTweetWithContent:(NSString *)contentText{
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"转发中.."];
    NSDictionary *parameDic = @{
                                @"content":contentText,
                                @"aboutId":@(_informationID),
                                @"aboutType":@(6)
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

#pragma --mark 分享
- (void)share{
    //搜集分享信息
    //更新单条数据 收藏
    __weak typeof (self)weakSelf = self;
    self.readInfoM.is_share = 1;
    NSString *updateSql = [NSString stringWithFormat:@"UPDATE readinginfo SET share = '%ld' WHERE start_time = '%ld'",self.readInfoM.is_share, (long)weakSelf.readInfoM.operate_time];
    [[OSCReadingInfoManager shareManager] updateInfoWithSql:updateSql];
    
    OSCShareManager *shareManeger = [OSCShareManager shareManager];
    [shareManeger showShareBoardWithShareType:InformationTypeInfo withModel:_newsDetail];
}

#pragma mark - keyboard

- (void)keyboardDidShow:(NSNotification *)nsNotification {
    
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

- (void)keyboardWillHide:(NSNotification *)aNotification {
    [self hideEditView];
}

#pragma mark - push action
-(void)pushDetailsVcWithDetailModel:(OSCAbout*)detailModel {
    NSInteger pushType = detailModel.type;
    if (pushType == 0) {
        pushType = 6;
    }
    UIViewController *targetVc =[OSCPushTypeControllerHelper pushControllerGeneralWithType:pushType detailContentID:detailModel.id];
    [self.navigationController pushViewController:targetVc animated:YES];
}

#pragma mark - CommentTextViewDelegate
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
    [window makeKeyAndVisible];
    _backView = [[UIView alloc] initWithFrame:window.bounds];
    _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [window addSubview:_backView];
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
//    [_backView addGestureRecognizer:tapGR];

    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 200 )];
    
    _tapView = tapView;
    tapView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
    [tapView addGestureRecognizer:tapGR];
    
    [_backView addSubview:tapView];

    
    
    [_backView addSubview:self.inputView];
    
    [self.inputView activateInputView];
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

#pragma mark --- lazy Load
- (OSCInformationHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[OSCInformationHeaderView alloc] init];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Forwarding;
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld_%ld",InformationTypeLinkNews,(long)(long)_informationID];
    }
    return _inputView;
}


#pragma - mark SelectBoardViewDelegate

- (void)copyClickBtn:(OSCCommentItem *)item {
    //复制到剪切板
    [self.shareV dismissContactView];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = item.content;
    //提示复制成功
    MBProgressHUD *hud = [Utils createHUD];
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = @"已经复制到剪切板";
    [hud hideAnimated:YES afterDelay:1];
    
}

- (void)commentClickBtn:(OSCCommentItem *)item {
   
    //弹出评论框
    [self.shareV dismissContactView];
    
    if (item.author.id > 0) {
        [self showEditView];
        _beRepliedCommentId = item.id;
        _beRepliedCommentAuthorId = item.author.id;
        [self.inputView insertAtrributeString2TextView:[Utils handle_TagString:[NSString stringWithFormat:@"@%@ ",item.author.name] fontSize:14]];
        
    } else {
        MBProgressHUD *hud = [Utils createHUD];
        hud.mode = MBProgressHUDModeCustomView;
        hud.label.text = @"该用户不存在，不可引用回复";
        [hud hideAnimated:YES afterDelay:1];
    }
    
}

- (void)shareClickBtn:(OSCCommentItem *)item{
    [self.shareV dismissContactView];
    //弹出图片分享界面
    [[OSCShareInvitation shareManager] showShareBoardWithImage:self.shareImg];
    
}

#pragma mark - share image

-(UIImage *)convertViewToImage:(UIView *)view{
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
        self.readInfoM.operate_type = OperateTypeNews;
        
        NSDate *datenow =[NSDate date];//现在时间
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        NSInteger interval = [zone secondsFromGMTForDate:datenow];
        NSDate *localeDate = [datenow  dateByAddingTimeInterval:interval];
        
        NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[localeDate timeIntervalSince1970]];
        NSLog(@"时间戳%@",timeSp);
        
        self.readInfoM.operate_time = [localeDate timeIntervalSince1970];
        self.readInfoM.stay = 0;
//            [[OSCReadingInfoManager shareManager] deleteTable];
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
