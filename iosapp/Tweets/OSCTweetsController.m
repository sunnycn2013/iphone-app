//
//  OSCTweetsController.m
//  iosapp
//
//  Created by 王恒 on 16/12/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetsController.h"
#import "TweetTableViewController.h"
#import "OSCTweetRecommendCollectionController.h"
#import "TitleBarView.h"
#import "OSCPopInputView.h"
#import "EmojiPageVC.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "Config.h"
#import "NewLoginViewController.h"
#import "JDStatusBarNotification.h"
#import "OSCTweetBlogListViewController.h"

#import "OSCTweetItem.h"
#import "OSCAbout.h"
#import "OSCStatistics.h"
#import "OSCNetImage.h"

#import <MBProgressHUD.h>
#import <YYKit.h>

@interface OSCTweetsController ()<UIScrollViewDelegate,TweetTableViewControllerDelegate,OSCPopInputViewDelegate>

@property (nonatomic,strong) NSArray *controllers;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,weak) TitleBarView *titleBar;
@property (nonatomic,weak) UIScrollView *scrollView;
@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) NSAttributedString *beforeATStr;   //储存@人之前的string

@property (nonatomic,assign) BOOL isEmojiPageOnScreen;
@property (nonatomic,strong) EmojiPageVC *emojiVC;

@property (nonatomic,assign) OSCTweetItem* forwardItem;

@end

@implementation OSCTweetsController

- (instancetype)init{
    self = [super init];
    if (self) {
        TweetTableViewController *newTweetViewCtl = [[TweetTableViewController alloc] initTweetListWithType:NewTweetsTypeAllTweets];
        newTweetViewCtl.delegate = self;
        TweetTableViewController *hotTweetViewCtl = [[TweetTableViewController alloc] initTweetListWithType:NewTweetsTypeHotestTweets];
        hotTweetViewCtl.delegate = self;
        
        OSCTweetBlogListViewController *newTweetBlogListCtl = [OSCTweetBlogListViewController new];
        
        TweetTableViewController *myFriendTweetViewCtl = [[TweetTableViewController alloc] initTweetListWithType:NewTweetsTypeOwnTweets];
        myFriendTweetViewCtl.delegate = self;
        _titles = @[@"最新动弹", @"热门动弹",@"每日乱弹", @"我的动弹"];
        _controllers = @[newTweetViewCtl, hotTweetViewCtl, newTweetBlogListCtl, myFriendTweetViewCtl];
        for (TweetTableViewController *childVC in _controllers) {
            [self addChildViewController:childVC];
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.translucent = YES;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setSelf];
    [self addContentView];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setSelf{
    self.navigationItem.title = @"动弹";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addContentView{
    TitleBarView *titleBar = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, 36) andTitles:_titles];
    titleBar.backgroundColor = [UIColor titleBarColor];
    titleBar.titleButtonClicked = ^(NSUInteger index){
        [_scrollView setContentOffset:CGPointMake(kScreenSize.width * index, 0) animated:YES];
    };
    _titleBar = titleBar;
    [self.view addSubview:_titleBar];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_titleBar.frame), kScreenSize.width, kScreenSize.height - CGRectGetMaxY(_titleBar.frame) - 49)];
    scrollView.contentSize = CGSizeMake(kScreenSize.width * _controllers.count, 0);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView = scrollView;
    [self.view addSubview:_scrollView];
    
    for (UIViewController *childVC in _controllers) {
        NSInteger index = [_controllers indexOfObject:childVC];
        childVC.view.frame = CGRectMake(kScreenSize.width * index, 0, kScreenSize.width, CGRectGetHeight(_scrollView.frame));
        [_scrollView addSubview:childVC.view];
    }
}

#pragma mark --- Method

- (void)refreshCurrentViewController{
    NSInteger index = [self.titleBar currentIndex];
    UIViewController *vc = self.childViewControllers[index];
    if ([vc isKindOfClass:[TweetTableViewController class]]) {
        TweetTableViewController *objsViewController = (TweetTableViewController *)vc;
        [objsViewController.tableView.mj_header beginRefreshing];
    }else if([vc isKindOfClass:[OSCTweetRecommendCollectionController class]]){
        OSCTweetRecommendCollectionController *recommendVC = (OSCTweetRecommendCollectionController *)vc;
        [recommendVC.collectionView.mj_header beginRefreshing];
    }else if ([vc isKindOfClass:[OSCTweetBlogListViewController class]]){
        OSCTweetBlogListViewController *objsViewController = (OSCTweetBlogListViewController *)vc;
        [objsViewController.tableView.mj_header beginRefreshing];
    }
}

- (void)forwardTweetWithContent:(YYTextView *)contentTextView{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"转发中.."];
    NSInteger forwardID = _forwardItem.id;
    NSString *forwardStr = [Utils convertRichTextToRawYYTextView:contentTextView];
    NSInteger forwardType = 100;
    if(_forwardItem.about && _forwardItem.about.id > 0){
        forwardID = _forwardItem.about.id;
        forwardType = _forwardItem.about.type;
        NSString *parmerStr = [NSString stringWithFormat:@"//@%@:%@",_forwardItem.author.name,[Utils attributedStringFromHTML:_forwardItem.content].string];
        forwardStr= [forwardStr stringByAppendingString:parmerStr];
    }else if(_forwardItem.about && _forwardItem.about.id <= 0){
        stauts.textLabel.text = @"该内容不存在，无法转发";
        [JDStatusBarNotification dismissAfter:2];
//        [self hideEditView];
        return;
    }
    NSDictionary *parameDic = @{
                                @"content":forwardStr,
                                @"aboutId":@(forwardID),
                                @"aboutType":@(forwardType)
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

//- (void)keyboardWillShow:(NSNotification *)nsNotification {
//    
//    //获取键盘的高度
//    
//    self.emojiVC.view.hidden = YES;
//    
//    NSDictionary *userInfo = [nsNotification userInfo];
//    
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    CGRect keyboardRect = [aValue CGRectValue];
//    
//    float keyboardHeight = keyboardRect.size.height;
//    
//    [UIView animateWithDuration:1 animations:^{
//        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
//        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//    }];
//    
//}

//- (void)keyboardWillHide:(NSNotification *)aNotification {
//    if (!_isEmojiPageOnScreen) {
//        [self hideEditView];
//    }
//}

#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x / kScreenSize.width;
    [self.titleBar scrollToCenterWithIndex:index];
}

#pragma mark --- TweetTableViewControllerDelegate
- (void)tweetClickForwardWithTweetItem:(OSCTweetItem *)tweetItem{
    _forwardItem = tweetItem;
    [self showEditView];
}

#pragma mark --- OSCPopInputViewDelegate
- (void)popInputViewDidDismiss:(OSCPopInputView* )popInputView draftNoteAttribute:(NSAttributedString *)draftNoteAttribute{
    _beforeATStr = draftNoteAttribute;
}

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView{
    OSCTweetFriendsViewController * vc = [OSCTweetFriendsViewController new];
    [self hideEditView];
    [vc setSelectDone:^(NSString *result) {
        [self showEditView];
        if (!_beforeATStr || [_beforeATStr isEqual:[NSNull null]]) {
            _beforeATStr = [[NSAttributedString alloc] initWithString:@""];
        }
        NSMutableAttributedString *attribute = _beforeATStr.mutableCopy;
        [attribute appendAttributedString:[Utils handle_TagString:result fontSize:14]];
        [self.inputView restoreDraftNoteWithAttribute:attribute];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView selectedforwarding:(BOOL)isSelectedForwarding curTextView:(YYTextView *)textView{
    _beforeATStr = nil;
    if (textView.attributedText.length > 0) {
        [self forwardTweetWithContent:textView];
    } else {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"转发内容不能不能为空";
            [HUD hideAnimated:YES afterDelay:1];
        }
    [self.inputView clearDraftNote];
    [self hideEditView];
}

- (void)popInputViewClickDidEmojiButton:(OSCPopInputView *)popInputView{
    [self showAndHideEmoij];
}

- (void)showEditView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _backView = [[UIView alloc] initWithFrame:window.bounds];
    _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackView:)];
    [_backView addGestureRecognizer:tapGR];
    
    self.emojiVC = [[EmojiPageVC alloc] initWithTextView:self.inputView];
    self.emojiVC.view.frame = CGRectMake(0, kScreenSize.height - 216, kScreenSize.width, 216);
    self.emojiVC.view.hidden = YES;
    [_backView addSubview:self.emojiVC.view];
    [_backView addSubview:self.inputView];
    [self.inputView activateInputView];
    [window addSubview:_backView];
}

- (void)hideEditView{
    [self.inputView freezeInputView];
    [UIView animateWithDuration:0.3 animations:^{
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.inputView.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) ;
        self.emojiVC.view.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, 216);
        _isEmojiPageOnScreen = NO;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
        _backView = nil;
    }];
}

- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:NO];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Emoji;
    }
    return _inputView;
}

- (void)touchBackView:(UITapGestureRecognizer *)tapGR{
    CGPoint point = [tapGR locationInView:_backView];
    CGRect rect = CGRectMake(0, 0, kScreenSize.width, CGRectGetMinY(self.inputView.frame));
    if (CGRectContainsPoint(rect,point)) {
        if (_isEmojiPageOnScreen) {
            [self hideEditView];
        }else{
            [self.inputView endEditing];
        }
    }
}

- (void)showAndHideEmoij{
    if (_isEmojiPageOnScreen) {
        _isEmojiPageOnScreen = NO;
        self.emojiVC.view.hidden = YES;
        [self.inputView beginEditing];
    } else {
        _isEmojiPageOnScreen = YES;
        [self.inputView endEditing];
        [UIView animateWithDuration:0.2 animations:^{
            self.inputView.frame = CGRectMake( 0, kScreenSize.height - 216 - CGRectGetHeight(self.inputView.frame), kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        }];
        self.emojiVC.view.hidden = NO;
    }
}

@end
