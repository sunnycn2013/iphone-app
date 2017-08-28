//
//  TweetTableViewController.m
//  iosapp
//
//  Created by 李萍 on 16/5/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "TweetTableViewController.h"
#import "OSCTweetItem.h"
#import "OSCAbout.h"
#import "OSCNetImage.h"
#import "OSCStatistics.h"
#import "OSCExtra.h"
#import "OSCPhotoGroupView.h"
#import "OSCForwardView.h"
#import "Config.h"
#import "OSCUser.h"
#import "OSCPushTypeControllerHelper.h"
#import "ImageDownloadHandle.h"

#import "TweetEditingVC.h"
#import "ImageViewerController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import "OSCUserHomePageController.h"
#import "TweetDetailNewTableViewController.h"
#import "NewLoginViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <UIImage+GIF.h>
#import <MBProgressHUD.h>
#import <YYKit.h>


#import "OSCModelHandler.h"
#import "UIView+Common.h"
#import "NSObject+Comment.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import "AsyncDisplayTableViewCell.h"
#import "OSCTextTweetCell.h"
#import "OSCImageTweetCell.h"
#import "OSCMultipleTweetCell.h"
#import "OSCForwardTweetCell.h"
static NSString* const reuseTextTweetCell = @"OSCTextTweetCell";
static NSString* const reuseImageTweetCell = @"OSCImageTweetCell";
static NSString* const reuseMultipleTweetCell = @"OSCMultipleTweetCell";

@interface TweetTableViewController () <UITextViewDelegate,AsyncDisplayTableViewCellDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NewTweetsType _tweetsType;
}
@property (nonatomic,strong) NSString* requestUrl;
@property (nonatomic,strong) NSMutableDictionary* parametersDic;
@property (nonatomic,strong) NSMutableArray* dataModels;
@property (nonatomic, copy) NSString *nextToken;

@property (nonatomic, assign) int64_t uid;
@property (nonatomic, copy) NSString *topic;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation TweetTableViewController

#pragma mark - init method
-(instancetype)initTweetListWithType:(NewTweetsType)type {
    self = [super init];
    if (self) {
        _tweetsType = type;
        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS];
        NSDictionary *para;
        switch (type) {
            case NewTweetsTypeAllTweets:
                para = @{ @"type":@(1) };
                break;
                
            case NewTweetsTypeHotestTweets:
                para = @{ @"type":@(2) };
                break;
                
            case NewTweetsTypeOwnTweets:
                para = @{ @"authorId":@( [Config getOwnID]) };
                break;
        }
        self.parametersDic = para.mutableCopy;
        [self getCacheDataWithRequestUrl:_requestUrl paraDescription:self.parametersDic.description];
    }
    return self;
}

-(instancetype)initTweetListWithTopic:(NSString *)topicTag
{
	return [self initWithTag:topicTag order:1];
}



#pragma mark - init method 
- (instancetype)initWithTag:(NSString* )tag
                      order:(TweetListOrder)order
{
    self = [super init];
    if (self) {
        _topic = tag;
        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS_LIST];
        self.parametersDic = @{
                               @"tag"        : tag,
                               @"order"      : @(order),
                               }.mutableCopy;

        [self getCacheDataWithRequestUrl:_requestUrl paraDescription:self.parametersDic.description];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(topicEditing)];
    }
    return self;
}

//这个方法专门给软件详情使用，其他地方请勿使用
- (instancetype)initWithTag:(NSString* )tag
					   withName:(NSString *)name
					  withOrder:(TweetListOrder)order
{
	self = [super init];
	if (self) {
		_topic = name; //因为发布对软件详情的评论是，必须带name，这是接口约定
		_requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS_LIST];
		self.parametersDic = @{
							   @"tag"        : [tag stringByRemovingPercentEncoding],
							   @"order"      : @(order),
							   }.mutableCopy;
		
		[self getCacheDataWithRequestUrl:_requestUrl paraDescription:self.parametersDic.description];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(topicEditing)];
	}
	return self;
}


- (instancetype)initWithAuthorId:(NSString* )authorId
                           order:(TweetListOrder)order
{
    self = [super init];
    if (self) {
        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS_LIST];
        self.parametersDic = @{
                               @"authorId"   : authorId,
                               @"order"      : @(order),
                               }.mutableCopy;

        [self getCacheDataWithRequestUrl:_requestUrl paraDescription:self.parametersDic.description];
    }
    return self;
}
- (instancetype)initWithTweetListType:(TweetListType)tweetListType
                                order:(TweetListOrder)order
{
    self = [super init];
    if (self) {
        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_TWEETS_LIST];
        self.parametersDic = @{
                               @"type"       : @(tweetListType),
                               @"order"      : @(order),
                               }.mutableCopy;
        [self getCacheDataWithRequestUrl:_requestUrl paraDescription:self.parametersDic.description];
    }
    return self;
}

#pragma mark - Cache plist
- (void)getCacheDataWithRequestUrl:(NSString* )requestUrl
                   paraDescription:(NSString* )paraDesc
{
    NSString* resourceName = [NSObject cacheResourceNameWithURL:requestUrl parameterDictionaryDesc:paraDesc];
    NSDictionary* response = [NSObject responseObjectWithResource:resourceName cacheType:SandboxCacheType_list];
    NSArray* items = response[@"items"];
    NSString* pageToken = response[@"nextPageToken"];
    if (items && items.count > 0) {
        NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCTweetItem class] json:items];
        for (OSCTweetItem* tweetItem in modelArray) {
            [tweetItem calculateLayoutWithCurTweetCellWidth:self.tableView.bounds.size.width forwardViewCurWidth:forwardView_FullWidth_list];
        }
        self.dataModels = modelArray.mutableCopy;
    }
    if (pageToken && pageToken.length > 0) {
        self.nextToken = pageToken;
    }
}

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self layoutUI];
}

#pragma mark --- layout UI
- (void)layoutUI{
    self.navigationItem.title = @"动弹";
    self.tableView.backgroundColor = [UIColor colorWithHex:0xfcfcfc];
    self.tableView.separatorColor = [UIColor separatorColor];
    self.tableView.tableFooterView = [UIView new];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf sendRequestWithRequest:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf sendRequestWithRequest:NO];
    }];
    
    if (_tweetsType != NewTweetsTypeOwnTweets) {
        [self.tableView.mj_header beginRefreshing];
    }else{
        if ([self loginCheck]) {
            [self.tableView.mj_header beginRefreshing];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if (_tweetsType == NewTweetsTypeOwnTweets) {
        if ([Config getOwnID] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataModels removeAllObjects];
                [self.tableView reloadData];
                [self.tableView showLoginPageView];
                __weak typeof(self) weakSelf = self;
                self.tableView.loginPageView.didClickLogInBlock = ^(){
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
                    NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
                    [weakSelf.navigationController presentViewController:loginVC animated:YES completion:nil];
                };
            });
        }else{
            if (self.tableView.loginPageView) {
                [self.tableView.mj_header beginRefreshing];
            }
            [self.tableView hideAllGeneralPage];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (BOOL)loginCheck{
    if ([Config getOwnID] == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataModels removeAllObjects];
            [self.tableView reloadData];
            [self.tableView showLoginPageView];
            __weak typeof(self) weakSelf = self;
            self.tableView.loginPageView.didClickLogInBlock = ^(){
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
                NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
                [weakSelf.navigationController presentViewController:loginVC animated:YES completion:nil];
            };
        });
        return NO;
    }else{
        [self.tableView hideAllGeneralPage];
        return YES;
    }
}

#pragma mark -- networking Delegate
- (void)sendRequestWithRequest:(BOOL)isRefresh{//yes 下拉 no 上拉
    
    NSMutableDictionary* paraMutableDic = self.parametersDic.mutableCopy;
    //登录判断
    if (_tweetsType == NewTweetsTypeOwnTweets) {
        if ([self loginCheck]) {
            [paraMutableDic setObject:@([Config getOwnID]) forKey:@"authorId"];
        }else{
            if (self.tableView.mj_header.isRefreshing) {
                [self.tableView.mj_header endRefreshing];
            }
            if (self.tableView.mj_footer.isRefreshing) {
                [self.tableView.mj_footer endRefreshing];
            }
            return;
        }
    }
    
    if (self.tableView.blankPageView.superview) { [self.tableView.blankPageView removeFromSuperview]; }
    if (self.tableView.errorPageView.superview) { [self.tableView.errorPageView removeFromSuperview]; }
    
    if (!isRefresh && [self.nextToken length] > 0) {
        [paraMutableDic setObject:self.nextToken forKey:@"pageToken"];
    }
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger GET:_requestUrl
     parameters:paraMutableDic.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            BOOL isSuccess = [responseObject[@"code"]integerValue] == 1;
            NSDictionary* resultDic = responseObject[@"result"];
            NSArray* items = resultDic[@"items"];

            if(isSuccess) {
                /** 额外信息回传 */
                __weak typeof(self) weakSelf = self;
                if ([_delegate respondsToSelector:@selector(tweetTableViewController:passInformation:)]) {
                    [_delegate tweetTableViewController:weakSelf passInformation:resultDic];
                }
                /********************/
                
                NSArray *modelArray = [NSArray osc_modelArrayWithClass:[OSCTweetItem class] json:items];
                for (OSCTweetItem* tweetItemModel in modelArray) {
                    [tweetItemModel calculateLayoutWithCurTweetCellWidth:self.tableView.bounds.size.width forwardViewCurWidth:forwardView_FullWidth_list];
                }
                if (modelArray && modelArray.count > 0 && isRefresh) {//下拉得到的数据
                    [self.dataModels removeAllObjects];
                }
                [self.dataModels addObjectsFromArray:modelArray];
                self.nextToken = resultDic[@"nextPageToken"];
                
                /**tweet list cache**/
                if (items && items.count > 0 && isRefresh) {
                    NSString* resourceName = [NSObject cacheResourceNameWithURL:_requestUrl parameterDictionaryDesc:self.parametersDic.description];
                    [NSObject handleResponseObject:resultDic resource:resourceName cacheType:SandboxCacheType_list];
                }
                /********************/
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                }else{
                    if ( (isSuccess && !items) || (isSuccess && items.count == 0)) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }else{
                        [self.tableView.mj_footer endRefreshing];
                    }
                }
                [self.tableView hideAllGeneralPage];
                if (self.dataModels.count == 0) {
                    [self.tableView showBlankPageView];
                }
                [self.tableView reloadData];
            });
    }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.detailsLabel.text = [NSString stringWithFormat:@"%@", error.userInfo[NSLocalizedDescriptionKey]];
            [HUD hideAnimated:YES afterDelay:1];

            if (self.dataModels.count == 0) {
                [self.tableView showErrorPageView];
                __weak typeof(self) weakSelf = self;
                self.tableView.errorPageView.didClickReloadBlock = ^(){
                    [weakSelf sendRequestWithRequest:YES];
                };
            }
    }];
}



#pragma mark - 处理消息通知
- (void)userRefreshHandler:(NSNotification *)notification
{
    _uid = [Config getOwnID];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataModels.count > 0) {
        return self.dataModels.count;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCTweetItem* tweetItem = self.dataModels[indexPath.row];
    return tweetItem.rowHeight;
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OSCTweetItem* tweetItem = self.dataModels[indexPath.row];
    if (tweetItem.about) {
        OSCAbout* forwardItem = tweetItem.about;
        if (forwardItem.images.count > 1) {
            OSCForwardTweetCell* forwardCell = [OSCForwardTweetCell returnReuseForwardTweetCellWithTableView:tableView identifierStr:OSCForwardTweetCell_reuseStr_MultiplePIC tweetItem:tweetItem];
            forwardCell.tweetItem = tweetItem;
            forwardCell.delegate = self;
            [self setBlockForCommentCell:forwardCell];
            return forwardCell;
        }else if (forwardItem.images.count == 1){
            OSCForwardTweetCell* forwardCell = [OSCForwardTweetCell returnReuseForwardTweetCellWithTableView:tableView identifierStr:OSCForwardTweetCell_reuseStr_OnlyPIC tweetItem:tweetItem];
            forwardCell.tweetItem = tweetItem;
            forwardCell.delegate = self;
            [self setBlockForCommentCell:forwardCell];
            return forwardCell;
        }else{
            OSCForwardTweetCell* forwardCell = [OSCForwardTweetCell returnReuseForwardTweetCellWithTableView:tableView identifierStr:OSCForwardTweetCell_reuseStr_OnPIC tweetItem:tweetItem];
            forwardCell.tweetItem = tweetItem;
            forwardCell.delegate = self;
            [self setBlockForCommentCell:forwardCell];
            return forwardCell;
        }
    }else{
        if (tweetItem.images.count == 0) {
            OSCTextTweetCell* textCell = [OSCTextTweetCell returnReuseTextTweetCellWithTableView:tableView identifier:reuseTextTweetCell];
            textCell.tweetItem = tweetItem;
            textCell.delegate = self;
            [self setBlockForCommentCell:textCell];
            return textCell;
        }else if (tweetItem.images.count == 1){
            OSCImageTweetCell* imageTweetCell = [OSCImageTweetCell returnReuseImageTweetCellWithTableView:tableView identifier:reuseImageTweetCell];
            imageTweetCell.tweetItem = tweetItem;
            imageTweetCell.delegate = self;
            [self setBlockForCommentCell:imageTweetCell];
            return imageTweetCell;
        }else{
            OSCMultipleTweetCell* multipleTweetCell = [OSCMultipleTweetCell returnReuseMultipleTweetCellWithTableView:tableView identifier:reuseMultipleTweetCell];
            multipleTweetCell.tweetItem = tweetItem;
            multipleTweetCell.delegate = self;
            [self setBlockForCommentCell:multipleTweetCell];
            return multipleTweetCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCTweetItem *tweet = self.dataModels[indexPath.row];
//    OSCTweetItem *detailTweet = [tweet mutableCopy];
    TweetDetailsWithBottomBarViewController *tweetDetailsBVC = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetItem:tweet];
    [self.navigationController pushViewController:tweetDetailsBVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return action == @selector(copyText:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // required
}


#pragma mark --- AsyncDisplayTableViewCell Delegate
- (void)userPortraitDidClick:(__kindof AsyncDisplayTableViewCell *)cell{
    OSCTweetItem* tweetItem = [cell valueForKey:@"tweetItem"];
    if (tweetItem.author.id > 0) {
        OSCUserHomePageController* otherUserHomePage = [[OSCUserHomePageController alloc]initWithUserID:tweetItem.author.id];
        [self.navigationController pushViewController:otherUserHomePage animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (void)loadLargeImageDidFinsh:(__kindof AsyncDisplayTableViewCell *)cell
                photoGroupView:(OSCPhotoGroupView *)groupView
                      fromView:(UIImageView *)fromView
{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
/** 点开拿到大图之后 用大图更新update缩略图 提高清晰度 */
    BOOL isForwardCell = NO;
    if ([cell isMemberOfClass:[OSCForwardTweetCell class]]) {
        isForwardCell = YES;
    }
    
    [groupView presentFromImageView:fromView toContainer:currentWindow animated:YES completion:^{
        OSCTweetItem* tweetItem = [cell valueForKey:@"tweetItem"];
        OSCNetImage* currentImageItem ;
        if (!isForwardCell) {
            currentImageItem = tweetItem.images[groupView.currentPage];
        }else{
            currentImageItem = tweetItem.about.images[groupView.currentPage];
        }
        
        if ([currentImageItem.thumb isEqualToString:currentImageItem.href]) return ;
        
        UIImage* image = [[YYWebImageManager sharedManager].cache getImageForKey:currentImageItem.href withType:YYImageCacheTypeAll];
        if (image && !(isForwardCell && tweetItem.about.images.count == 1)){
            [[SDWebImageManager sharedManager] saveImageToCache:image forURL:[NSURL URLWithString:currentImageItem.href]];
            fromView.image = image;
            currentImageItem.thumb = currentImageItem.href;
        }
    }];
}

- (void)forwardViewDidClick:(__kindof AsyncDisplayTableViewCell *)cell
                forwardView:(OSCForwardView *)forwardView
{
    OSCAbout* forwardInfo = forwardView.forwardItem;
    UIViewController* curVC = [OSCPushTypeControllerHelper pushControllerGeneralWithType:forwardInfo.type detailContentID:forwardInfo.id];
    if (curVC) {
        [self.navigationController pushViewController:curVC animated:YES];
    }else{
        [curVC.navigationController handleURL:[NSURL URLWithString:forwardInfo.href] name:nil];
    }
}

- (void)changeTweetStausButtonDidClick:(__kindof AsyncDisplayTableViewCell *)cell{
    [self toPraise:cell];
}

- (void) shouldInteractTextView:(UITextView* )textView
                            URL:(NSURL *)URL
                        inRange:(NSRange)characterRange
{
    NSString* nameStr = [textView.text substringWithRange:characterRange];
    if ([[nameStr substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"@"]) {
        nameStr = [nameStr substringFromIndex:1];
        [self.navigationController handleURL:URL name:nameStr];
    }else{
        [self.navigationController handleURL:URL name:nil];
    }
}

- (void)forwardTweetButtonDidClick:(__kindof AsyncDisplayTableViewCell* )cell{
    if ([self.delegate respondsToSelector:@selector(tweetClickForwardWithTweetItem:)]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCTweetItem *item = _dataModels[indexPath.row];
        [self.delegate tweetClickForwardWithTweetItem:item];
    }
}

- (void)textViewTouchPointProcessing:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.tableView];
    [self tableView:self.tableView didSelectRowAtIndexPath:[self.tableView indexPathForRowAtPoint:point]];
}

- (void)setBlockForCommentCell:(__kindof AsyncDisplayTableViewCell *)cell{
    cell.canPerformAction = ^ BOOL (UITableViewCell *cell, SEL action) {
        if (action == @selector(copyText:)) {
            return YES;
        } else if (action == @selector(deleteObject:)) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            OSCTweetItem *tweet = self.dataModels[indexPath.row];
            return tweet.author.id == [Config getOwnID];
        }
        return NO;
    };
    
    cell.deleteObject = ^ (UITableViewCell *cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        OSCTweetItem *tweet = self.dataModels[indexPath.row];
        
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"正在删除动弹";
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
        
        [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_DELETE]
           parameters:@{
                        @"sourceId": @(tweet.id),
                        }
              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                  if ([responseObject[@"code"] floatValue] == 1) {
                      HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
                      HUD.label.text = @"动弹删除成功";
                      
                      [self.dataModels removeObjectAtIndex:indexPath.row];
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [self.tableView reloadData];
                      });
                  }else{
                      HUD.label.text = @"网络错误";
                  }
                  [HUD hideAnimated:YES afterDelay:1];
                  
              }
              failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.detailsLabel.text = error.userInfo[NSLocalizedDescriptionKey];
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    };
}

#pragma mark - 跳转到用户详情页
- (void)pushUserDetailsView:(UITapGestureRecognizer *)recognizer
{
    OSCTweetItem *tweet = self.dataModels[recognizer.view.tag];
    if (tweet.author.id > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:tweet.author.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

#pragma mark - 编辑话题动弹
- (void)topicEditing {
    TweetEditingVC *tweetEditingVC = [[TweetEditingVC alloc] initWithTopic:_topic];
    UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
    [self.navigationController presentViewController:tweetEditingNav animated:NO completion:nil];
    
}

#pragma mark --点赞（新接口)
- (void)toPraise:(__kindof AsyncDisplayTableViewCell*)cell{
    OSCTweetItem* tweet = [cell valueForKey:@"tweetItem"];
    if (tweet.id == 0) {
        return;
    }
/** animation hight priority hanle*/
    if (tweet.liked) {
        tweet.statistics.like -= 1;
    }else{
        tweet.statistics.like += 1;
    }
    tweet.liked = !tweet.liked;
    [cell setLikeStatus:tweet.liked animation:tweet.liked];


    NSString *postUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_TWEET_LIKE_REVERSE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:postUrl
       parameters:@{@"sourceId":@(tweet.id)}
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              
              if([responseObject[@"code"]integerValue] == 1) {
//                  tweet.liked = !tweet.liked;
                  NSDictionary* resultDic = responseObject[@"result"];
                  tweet.statistics.like = [resultDic[@"likeCount"] integerValue];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [cell setLikeStatus:tweet.liked animation:NO];
                  });
              }else {
                  NSString *message = ([Config getOwnID] == 0) ? @"用户尚未登录" : responseObject[@"message"];
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = message.length > 0 ? message :@"未知错误";
                  [HUD hideAnimated:YES afterDelay:1];
                  
                  tweet.liked = !tweet.liked;
                  if (tweet.liked) {//reset like status
                      tweet.statistics.like += 1;
                  }else{
                      tweet.statistics.like -= 1;
                  }
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [cell setLikeStatus:tweet.liked animation:NO];
                  });
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              MBProgressHUD *HUD = [Utils createHUD];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.label.text = @"网络错误";
              [HUD hideAnimated:YES afterDelay:1];
              tweet.liked = !tweet.liked;
              if (tweet.liked) {//reset like status
                  tweet.statistics.like+= 1;
              }else{
                  tweet.statistics.like -= 1;
              }
              dispatch_async(dispatch_get_main_queue(), ^{
                  [cell setLikeStatus:tweet.liked animation:NO];
              });
          }
     ];
}

#pragma mark --- lazy loading
- (NSMutableArray *)dataModels {
    if(_dataModels == nil) {
        _dataModels = [[NSMutableArray alloc] init];
    }
    return _dataModels;
}

@end
