//
//  TweetDetailNewTableViewController.m
//  iosapp
//
//  Created by Holden on 16/6/12.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetDetailNewTableViewController.h"
#import "UIColor+Util.h"
#import "ImageViewerController.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCUserItem.h"
#import "OSCCommentItem.h"
#import "OSCTweetItem.h"
#import "OSCStatistics.h"
#import "OSCNetImage.h"
#import "OSCAbout.h"
#import "OSCPhotoGroupView.h"
#import "TweetEditingVC.h"
#import "OSCUserHomePageController.h"
#import "NSString+FontAwesome.h"
#import "UIImage+Comment.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "UINavigationController+Comment.h"
#import "ImageDownloadHandle.h"
#import "TweetLikeNewCell.h"
#import "TweetCommentNewCell.h"
#import "OSCTweetMultipleDetailTableViewCell.h"
#import "OSCTweetForwardDetailTableViewCell.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import "UMSocial.h"
#import "OSCShareManager.h" //分享工具栏
#import "OSCPushTypeControllerHelper.h"
#import "AsyncDisplayTableViewCell.h"
#import "JDStatusBarNotification.h"
#import "NewLoginViewController.h"

#import <AFNetworking.h>
#import <MJRefresh.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>
#import <SDImageCache.h>
#import <SDWebImageDownloader.h>
#import <UIImage+GIF.h>
#import <YYKit.h>
#import "OSCModelHandler.h"
#import "OSCTweetDetailTableViewCell.h"
#import "OSCTweetDetailContentCell.h"

#import "UIView+Common.h"


@import SafariServices ;

static NSString * const tDetailReuseIdentifier = @"TweetDetailCell";
static NSString * const tLikeReuseIdentifier = @"TweetLikeTableViewCell";
static NSString * const tCommentReuseIdentifier = @"TweetCommentTableViewCell";
static NSString * const tMultipleDetailReuseIdentifier = @"OSCTweetMultipleDetailTableViewCell";

@interface TweetDetailNewTableViewController ()<UITextViewDelegate,OSCTweetDetailPageDelegate,OSCShareManagerDelegate>
@property (nonatomic, strong)UIView *headerView;
@property (nonatomic)BOOL isShowCommentList;
@property (nonatomic, strong)NSMutableArray *tweetLikeList;
@property (nonatomic, strong)NSMutableArray *tweetCommentList;
@property (nonatomic)NSInteger likeListPage;
@property (nonatomic)NSInteger commentListPage;
@property (nonatomic, copy)NSString *TweetLikesPageToken;
@property (nonatomic, copy)NSString *TweetCommentsPageToken;

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, strong) OSCTweetItem *tweetDetail;
@property (nonatomic, assign) CGFloat webViewHeight;
@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, weak) UITableViewCell *lastSelectedCell;
@property (nonatomic, strong) MBProgressHUD *hud;
@end

@implementation TweetDetailNewTableViewController

- (void)showHubView {
    UIView *coverView = [[UIView alloc]initWithFrame:self.view.bounds];
    coverView.backgroundColor = [UIColor whiteColor];
    coverView.tag = 10;
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    _hud = [[MBProgressHUD alloc] initWithView:window];
    _hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    [window addSubview:_hud];
    [self.tableView addSubview:coverView];
    [_hud showAnimated:YES];
    _hud.removeFromSuperViewOnHide = YES;
    _hud.userInteractionEnabled = NO;
}

- (void)hideHubView {
    [_hud hideAnimated:YES];
    [[self.tableView viewWithTag:10] removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideHubView];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_item) {
        _tweetDetail = _item;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetLikeNewCell" bundle:nil] forCellReuseIdentifier:tLikeReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCommentNewCell" bundle:nil] forCellReuseIdentifier:tCommentReuseIdentifier];
    [self.tableView registerClass:[OSCTweetDetailTableViewCell class] forCellReuseIdentifier:tDetailReuseIdentifier];
    [self.tableView registerClass:[OSCTweetMultipleDetailTableViewCell class] forCellReuseIdentifier:tMultipleDetailReuseIdentifier];
    [self.tableView registerClass:[OSCTweetForwardDetailTableViewCell class] forCellReuseIdentifier:OSCTweetForwardDetailTableViewCellReuseIdentifier];
    self.tableView.estimatedRowHeight = 250;
    self.tableView.tableFooterView = [UIView new];
	
    _tweetLikeList = [NSMutableArray new];
    _tweetCommentList = [NSMutableArray new];
    UILabel* weakLabel  = [[UILabel alloc]init];
    _label = weakLabel;
    _label.numberOfLines = 0;
    _isShowCommentList = YES;       //默认展示评论列表
	
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadTweetLikesIsRefresh:NO];
        [self loadTweetCommentsIsRefresh:NO];
    }];
    
    if (!_tweetDetail) {
        [self showHubView];
        [self loadTweetDetails];
    }
    [self loadTweetLikesIsRefresh:YES];
    [self loadTweetCommentsIsRefresh:YES];
	
	self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_share_black_pressed"]
																			  style:UIBarButtonItemStylePlain
																			 target:self
																			 action:@selector(shareForActivity:)];
	
	self.navigationItem.title = @"hello";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - right BarButton
- (void)shareForActivity:(UIBarButtonItem *)barButton
{
    OSCShareManager *shareManeger = [OSCShareManager shareManager];
    shareManeger.delegate = self;
    [shareManeger showShareBoardWithShareType:InformationTypeTweet withModel:_tweetDetail];
}

- (void)shareManagerCustomShareModeWithManager:(OSCShareManager *)shareManager
                         shareBoardIndexButton:(NSInteger)buttonTag
{
    if (buttonTag == 8) {
        OSCAbout* forwardInfo;
        TweetEditingVC *tweetEditingVC;
        if (_tweetDetail.about) {
            if (_tweetDetail.about.id <= 0) {
                [JDStatusBarNotification showWithStatus:@"该内容不存在，无法转发"];
                [JDStatusBarNotification dismissAfter:2];
                return;
            }
            NSString *string = [_tweetDetail.about.content substringWithRange:NSMakeRange(_tweetDetail.about.title.length + 1, _tweetDetail.about.content.length - _tweetDetail.about.title.length - 1)];
            forwardInfo = [OSCAbout forwardInfoModelWithTitle:_tweetDetail.about.title content:string type:_tweetDetail.about.type fullWidth:[UIScreen mainScreen].bounds.size.width - 32];
            NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"//@%@:",_tweetDetail.author.name]];
            [att appendAttributedString:[Utils contentStringFromRawString:_tweetDetail.content]];
            [att addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x087221]} range:NSMakeRange(2, _tweetDetail.author.name.length + 1)];
            tweetEditingVC = [[TweetEditingVC alloc] initWithAboutID:_tweetDetail.about.id fromTweetID:_tweetDetail.id aboutType:_tweetDetail.about.type forwardItem:forwardInfo string:[att copy] isShowComment:YES];
        }else{
            forwardInfo= [OSCAbout forwardInfoModelWithTitle:_tweetDetail.author.name content:_tweetDetail.content type:InformationTypeTweet fullWidth:[UIScreen mainScreen].bounds.size.width - 32];
            tweetEditingVC = [[TweetEditingVC alloc] initWithAboutID:_tweetDetail.id fromTweetID:_tweetDetail.id aboutType:InformationTypeTweet forwardItem:forwardInfo string:nil isShowComment:YES];
        }
        
        UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
        [self presentViewController:tweetEditingNav animated:YES completion:nil];
    }
}

#pragma mark -- headerView
- (UIView*) headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,40}}];
        _headerView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
        
        for (int k=0; k<2; k++) {
            UIButton* subBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            subBtn.tag = k+1;
            NSString* likeBtnTitle = subBtn.tag==1?@"赞":@"评论";
            BOOL isSelected = subBtn.tag==2;
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:likeBtnTitle isSelected:isSelected];
            [subBtn setAttributedTitle:att forState:UIControlStateNormal];
            
            [subBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
            CGFloat btnWidth = _headerView.bounds.size.width/2;
            subBtn.frame = (CGRect){{btnWidth*k,0},{btnWidth,40}};
            [_headerView addSubview:subBtn];
        }

    } else {
        if (_tweetDetail.statistics.like > 0) {
            UIButton *likeBtn = [(UIButton*)_headerView viewWithTag:1];
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:[NSString stringWithFormat:@"赞 (%ld)", (long)_tweetDetail.statistics.like] isSelected:!_isShowCommentList];
            [likeBtn setAttributedTitle:att forState:UIControlStateNormal];
        }
        if (self.tweetCommentList.count > 0) {
            UIButton *commentBtn = [(UIButton*)_headerView viewWithTag:2];
            NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:[NSString stringWithFormat:@"评论 (%ld)", (long)_item.statistics.comment] isSelected:_isShowCommentList];
            [commentBtn setAttributedTitle:att forState:UIControlStateNormal];
        }

    }
    
    return _headerView;
}

-(NSMutableAttributedString*)getSubBtnAttributedStringWithTitle:(NSString*)title isSelected:(BOOL)isSelected {
    NSMutableAttributedString* attributedStrNormal = [[NSMutableAttributedString alloc]initWithString:title];
    UIFont *font = [UIFont systemFontOfSize:15];
    UIColor *currentColor = isSelected?[UIColor colorWithHex:0x24cf5f]:[UIColor colorWithHex:0x6a6a6a];
    [attributedStrNormal setAttributes:@{NSForegroundColorAttributeName:currentColor,NSFontAttributeName:font} range:(NSRange){0,title.length}];
    return attributedStrNormal;
}

-(void)clickBtn:(UIButton*)btn {
    if (btn.tag == 1) { //赞
        _isShowCommentList = NO;
        NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:@"赞" isSelected:YES];
        [btn setAttributedTitle:att forState:UIControlStateNormal];
        
        NSMutableAttributedString *attr = [self getSubBtnAttributedStringWithTitle:@"评论" isSelected:NO];
        [((UIButton*)[_headerView viewWithTag:2]) setAttributedTitle:attr forState:UIControlStateNormal];
    }else if (btn.tag == 2) {     //评论
        _isShowCommentList = YES;
        NSMutableAttributedString *att = [self getSubBtnAttributedStringWithTitle:@"评论" isSelected:YES];
        [btn setAttributedTitle:att forState:UIControlStateNormal];
        
        NSMutableAttributedString *attr = [self getSubBtnAttributedStringWithTitle:@"赞" isSelected:NO];
        [((UIButton*)[_headerView viewWithTag:1]) setAttributedTitle:attr forState:UIControlStateNormal];
    }    
    [self.tableView reloadData];
}

#pragma mark - 获取动弹详情数据
- (void)loadTweetDetails {
    NSString *tweetDetailUrlStr = [NSString stringWithFormat:@"%@tweet?id=%ld", OSCAPI_V2_PREFIX, (long)self.tweetID];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:tweetDetailUrlStr
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"]integerValue] == 1) {
                _tweetDetail = [OSCTweetItem osc_modelWithJSON:responseObject[@"result"]];
                _item = _tweetDetail;
                if (_tweetDetail.about) {
                    [_tweetDetail.about calculateLayoutWithForwardViewWidth:kScreenSize.width - padding_left - padding_right];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideHubView];
                    [self.tableView reloadData];
                });
            }else{
                [self.navigationController popViewControllerAnimated:YES];
                
                [self hideHubView];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    MBProgressHUD *HUD = [Utils createHUD];
                    HUD.mode = MBProgressHUDModeCustomView;
                    HUD.label.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
                    [HUD hideAnimated:YES afterDelay:1];
                });
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
    
}

#pragma mark - 获取点赞列表数据
-(void)loadTweetLikesIsRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        _TweetLikesPageToken = @"";
    }
    NSDictionary *paraDic = @{@"sourceId":@(_tweetID),
                              @"pageToken":_TweetLikesPageToken
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_LIKES]
      parameters:paraDic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if([responseObject[@"code"]integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray* items = resultDic[@"items"];
                 if (isRefresh && items.count > 0) {//下拉得到的数据
                     [self.tweetLikeList removeAllObjects];
                 }
                 for(int k=0;k<items.count;k++) {
                     NSDictionary *userDic =[items objectAtIndex:k][@"author"];
                     OSCUserItem *user = [OSCUserItem osc_modelWithJSON:userDic];
                     if (user) {
                         [self.tweetLikeList addObject:user];
                     }
                 }
                 _TweetLikesPageToken = resultDic[@"nextPageToken"];
             }
             
             if (self.tableView.mj_footer.isRefreshing) {
                 [self.tableView.mj_footer endRefreshing];
             }
             if (!_isShowCommentList) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self networkingError:error];
         }
     ];
}

#pragma mark - 评论时本地添加数据
-(void)reloadCommentListWithLocationData:(OSCCommentItem *)newCommentItem isSuccess:(BOOL)isSuccessful
{
    if (isSuccessful) {
        _tweetDetail.statistics.comment++;
        [self.tweetCommentList insertObject:newCommentItem atIndex:0];
    } else {
        _tweetDetail.statistics.comment--;
        [self.tweetCommentList removeObjectAtIndex:0];
    }
    
    [self.tableView reloadData];
}

//发表评论后，为了更新总的评论数
-(void)reloadCommentList {
    _tweetDetail.statistics.comment++;
    [self loadTweetCommentsIsRefresh:YES];
}

#pragma mark - 获取评论列表数据
-(void)loadTweetCommentsIsRefresh:(BOOL)isRefresh {
    if (isRefresh) {
        _TweetCommentsPageToken = @"";
    }
    NSDictionary *paraDic = @{@"sourceId":@(_tweetID),
                              @"pageToken":_TweetCommentsPageToken
                              };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_COMMENTS]
      parameters:paraDic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if([responseObject[@"code"]integerValue] == 1) {
                 NSDictionary* resultDic = responseObject[@"result"];
                 NSArray* items = resultDic[@"items"];
                 NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCCommentItem class] json:items];
                 
                 if (isRefresh && modelArray.count > 0) {//下拉得到的数据
                     [self.tweetCommentList removeAllObjects];
                 }
                 [self.tweetCommentList addObjectsFromArray:modelArray];

                 _TweetCommentsPageToken = resultDic[@"nextPageToken"];
             }
             if (self.tableView.mj_footer.isRefreshing) {
                 [self.tableView.mj_footer endRefreshing];
             }
             if (_isShowCommentList) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self networkingError:error];
         }
     ];
}

-(void)networkingError:(NSError*)error {
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
    [HUD hideAnimated:YES afterDelay:1];
    
    if (self.tableView.mj_footer.isRefreshing) {
        [self.tableView.mj_footer endRefreshing];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    } else if (section==1) {
        return _isShowCommentList?_tweetCommentList.count:_tweetLikeList.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?0:40;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return self.headerView;
    }else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        if (!_isShowCommentList) {
            return 56;
        }else{
            return UITableViewAutomaticDimension;
        }
    }else{
        return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (_tweetDetail.about) {
            OSCTweetForwardDetailTableViewCell* forwardCell = [tableView dequeueReusableCellWithIdentifier:OSCTweetForwardDetailTableViewCellReuseIdentifier forIndexPath:indexPath];
            forwardCell.item = _tweetDetail;
            forwardCell.delegate = self;
            return forwardCell;
        }else{
            if (_tweetDetail.images.count <= 1) {
                OSCTweetDetailTableViewCell *detailCell = [tableView dequeueReusableCellWithIdentifier:tDetailReuseIdentifier forIndexPath:indexPath];
                detailCell.item = _tweetDetail;
                detailCell.delegate = self;
                return detailCell;
            }else{
                OSCTweetMultipleDetailTableViewCell* detailCell = [tableView dequeueReusableCellWithIdentifier:tMultipleDetailReuseIdentifier forIndexPath:indexPath];
                if (_tweetDetail == nil) {return nil;}
                detailCell.item = _tweetDetail;
                detailCell.delegate = self;
                return detailCell;
            }
        }
    }else if (indexPath.section == 1) {
        if (_isShowCommentList) {
            TweetCommentNewCell *commentCell = [self.tableView dequeueReusableCellWithIdentifier:tCommentReuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < _tweetCommentList.count) {
                OSCCommentItem *commentModel = _tweetCommentList[indexPath.row];
                [commentCell setCommentModel:commentModel];
                
                [self setBlockForCommentCell:commentCell];
                
                commentCell.commentTagIv.tag = indexPath.row;
                [commentCell.commentTagIv addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replyReviewer:)]];
                
                commentCell.portraitIv.tag = commentModel.author.id;
                [commentCell.portraitIv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentItemPushUserDetails:)]];
            }
            return commentCell;
        }else {
            TweetLikeNewCell *likeCell = [self.tableView dequeueReusableCellWithIdentifier:tLikeReuseIdentifier forIndexPath:indexPath];
            if (indexPath.row < _tweetLikeList.count) {
                OSCUserItem *likedUser = [_tweetLikeList objectAtIndex:indexPath.row];
                [likeCell.portraitIv loadPortrait:[NSURL URLWithString:likedUser.portrait] userName:likedUser.name];
                likeCell.nameLabel.text = likedUser.name;
                likeCell.touchButton.tag = likedUser.id;
                
                if (likedUser.identity.officialMember) {
                    likeCell.idendityLabel.hidden = NO;
                }else{
                    likeCell.idendityLabel.hidden = YES;
                }
                
                [likeCell.touchButton addTarget:self action:@selector(likedUserDetails:) forControlEvents:UIControlEventTouchUpInside];
            }
            return likeCell;
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        if (_isShowCommentList && _tweetCommentList.count > 0) {
            OSCCommentItem *comment = _tweetCommentList[indexPath.row];
            if (self.didTweetCommentSelected) {
                self.didTweetCommentSelected(comment);
            }
        }
    }
}

#pragma mark --- OSCTweetDetailPage Delegate 
- (void)userPortraitDidClick:(__kindof OSCTweetDetailContentCell *)tweetDetailCell
{
    if (_tweetDetail.author.id) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:_tweetDetail.author.id] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (void)commentButtonDidClick:(__kindof OSCTweetDetailContentCell *)tweetDetailCell
{
    [self commentTweet];
}

- (void)forwardButtonDidClick:(__kindof OSCTweetDetailContentCell *)tweetDetailCell
{
    [self forwardTweet];
}

-(void)likeButtonDidClick:(__kindof OSCTweetDetailContentCell *)tweetDetailCell

              tapGestures:(UITapGestureRecognizer *)tap
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    [self likeOrCancelLikeTweetAndUpdateTagIv:(UIImageView* )tap.view];
}

- (void) loadLargeImageDidFinsh:(__kindof OSCTweetDetailContentCell* )tweetDetailCell
                 photoGroupView:(OSCPhotoGroupView* )groupView
                       fromView:(UIImageView* )fromView
{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    if ([tweetDetailCell isKindOfClass:[OSCTweetForwardDetailTableViewCell class]]) {
        [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:nil];
    }else{
        /** 点开拿到大图之后 用大图更新update缩略图 提高清晰度 */
        [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:^{
            OSCTweetItem* tweetItem = [tweetDetailCell valueForKey:@"item"];
            OSCNetImage* currentImageItem = tweetItem.images[groupView.currentPage];
            UIImage* image = [[YYWebImageManager sharedManager].cache getImageForKey:currentImageItem.href withType:YYImageCacheTypeMemory];
            if (image) { fromView.image = image; }
        }];
    }
}

- (void) forwardViewDidClick:(__kindof OSCTweetDetailContentCell* )tweetDetailCell
{
    OSCTweetForwardDetailTableViewCell* forwardCell = (OSCTweetForwardDetailTableViewCell* )tweetDetailCell;
    OSCAbout* forwardItem = forwardCell.item.about;
    UIViewController* curVC = [OSCPushTypeControllerHelper pushControllerGeneralWithType:forwardItem.type detailContentID:forwardItem.id];
    if (curVC) {
        [self.navigationController pushViewController:curVC animated:YES];
    }else{
        [curVC.navigationController handleURL:[NSURL URLWithString:forwardItem.href] name:nil];
    }
}

- (void) shouldInteract:(__kindof OSCTweetDetailContentCell* )tweetDetailCell
               TextView:(UITextView* )textView
                    URL:(NSURL *)URL
                inRange:(NSRange)characterRange
{
    [self.navigationController handleURL:URL name:nil];
}

#pragma mark -- Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    _lastSelectedCell.backgroundColor = [UIColor whiteColor];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor selectCellSColor];
    _lastSelectedCell = cell;
    return indexPath.section != 0;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender {

}

#pragma  mark -- 用户详情界面
-(void)pushUserDetails:(UITapGestureRecognizer*)tap {
    if (tap.view.tag > 0) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:tap.view.tag] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

-(void)commentItemPushUserDetails:(UITapGestureRecognizer*)tap {
    NSInteger userId = tap.view.tag;
    if (userId > 0) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:userId] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (void)likedUserDetails:(UIButton*)btn {
    if (btn.tag > 0) {
        [self.navigationController pushViewController:[[OSCUserHomePageController alloc] initWithUserID:btn.tag] animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (void)likeThisTweet:(UITapGestureRecognizer*)tap {
    UIImageView *likeTagIv = (UIImageView*)tap.view;
    [self likeOrCancelLikeTweetAndUpdateTagIv:likeTagIv];
}

- (void)commentTweet {
    if (self.didActivatedInputBar) {
        self.didActivatedInputBar();
    }
}

- (void)replyReviewer:(UITapGestureRecognizer*)tap {
    OSCCommentItem *comment = _tweetCommentList[tap.view.tag];
    if (self.didTweetCommentSelected) {
        self.didTweetCommentSelected(comment);
    }
}

- (void)forwardTweet{
    if ([self.detailDelegate respondsToSelector:@selector(clickForwardWithTweetItem:)]) {
        [self.detailDelegate clickForwardWithTweetItem:_tweetDetail];
    }
}

#pragma mark --点赞（新接口)
-(void)likeOrCancelLikeTweetAndUpdateTagIv:(UIImageView*)likeTagIv {
    if (_tweetDetail.id == 0) {
        return;
    }
    NSString *postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_LIKE_REVERSE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:postUrl
       parameters:@{@"sourceId":@(_tweetDetail.id)}
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
             if([responseObject[@"code"]integerValue] == 1) {
                 if (_tweetDetail.liked) {
                     //取消点赞
                     _tweetDetail.statistics.like--;
                     [likeTagIv setImage:[UIImage imageNamed:@"ic_thumbup_normal"]];
                     for (OSCUserItem *likeUser in _tweetLikeList) {
                         OSCUserItem *currentUser = [OSCUserItem modelWithJSON:responseObject[@"result"][@"author"]];
                         if (currentUser.id == likeUser.id) {
                             [_tweetLikeList removeObject:likeUser];
                             break;
                         }
                     }
                     _tweetDetail.liked = NO;
                 } else {
                     //点赞
                     _tweetDetail.statistics.like++;
                     [likeTagIv setImage:[UIImage imageNamed:@"ic_thumbup_actived"]];
                     OSCUserItem *currentUser = [OSCUserItem modelWithJSON:responseObject[@"result"][@"author"]];
                     [_tweetLikeList insertObject:currentUser atIndex:0];
                     _tweetDetail.liked = YES;
                 }
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                 });
             }else {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = [NSString stringWithFormat:@"%@", responseObject[@"message"]?:@"未知错误"];
                 
                 [HUD hideAnimated:YES afterDelay:1];
             }
             
             if (self.tableView.mj_footer.isRefreshing) {
                 [self.tableView.mj_footer endRefreshing];
             }
             if (!_isShowCommentList) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             [self networkingError:error];
         }
     ];
}

#pragma mark -- 删除动弹评论
- (void)setBlockForCommentCell:(TweetCommentNewCell *)cell {
    __weak typeof(self) weakSelf = self;
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
            OSCCommentItem *comment = weakSelf.tweetCommentList[indexPath.row];
            int64_t ownID = [Config getOwnID];
            return (comment.author.id == ownID || weakSelf.tweetDetail.id == ownID);
        }
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [weakSelf.tableView indexPathForCell:cell];
        OSCCommentItem *comment = weakSelf.tweetCommentList[indexPath.row];
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.label.text = @"正在删除评论";
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
        [manager POST:[NSString stringWithFormat:@"%@%@?", OSCAPI_PREFIX, OSCAPI_COMMENT_DELETE]
           parameters:@{
                        @"catalog": @(3),
                        @"id": @(_tweetDetail.id),
                        @"replyid": @(comment.id),
                        @"authorid": @(comment.author.id)
                        }
              success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseObject) {
                  ONOXMLElement *resultXML = [responseObject.rootElement firstChildWithTag:@"result"];
                  int errorCode = [[[resultXML firstChildWithTag: @"errorCode"] numberValue] intValue];
                  NSString *errorMessage = [[resultXML firstChildWithTag:@"errorMessage"] stringValue];
                  
                  HUD.mode = MBProgressHUDModeCustomView;
                  
                  if (errorCode == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"评论删除成功";
                      
                      [self.tweetCommentList removeObjectAtIndex:indexPath.row];
                      if (self.tweetCommentList.count > 0) {
                          [self.tableView beginUpdates];
                          [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                          [self.tableView endUpdates];
                      }
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  } else {
                      HUD.label.text = [NSString stringWithFormat:@"%@", errorMessage];
                  }
                  
                  [HUD hideAnimated:YES afterDelay:1];
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = @"网络异常，操作失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}
#pragma mark - 下载图片

- (void)downloadThumbnailImageThenReload:(NSString*)urlString
{
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString:urlString]
                                                        options:SDWebImageDownloaderUseNSURLCache
                                                       progress:nil
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                          [[SDImageCache sharedImageCache] storeImage:image forKey:urlString toDisk:NO];

                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self.tableView reloadData];
                                                          });
                                                      }];
    
}

#pragma mark - scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView && self.didScroll) {
        self.didScroll();
    }
}

@end
