//
//  TweetDetailsWithBottomBarViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/14/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "TweetDetailsWithBottomBarViewController.h"
#import "CommentsViewController.h"
#import "OSCUserHomePageController.h"
#import "ImageViewerController.h"
#import "OSCTweet.h"
#import "OSCListItem.h"
#import "OSCCommentItem.h"
#import "OSCAbout.h"
#import "Config.h"
#import "Utils.h"

#import "JDStatusBarNotification.h"
#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "EmojiPageVC.h"
#import "NewLoginViewController.h"
#import "OSCTweetItem.h"
#import "TweetEditingVC.h"
#import "AsyncDisplayTableViewCell.h"

#import "NSObject+Comment.h"

#import "TweetDetailNewTableViewController.h"
#import <objc/runtime.h>
#import <MBProgressHUD.h>
#import <YYKit.h>


#define backViewHeight 46

@interface TweetDetailsWithBottomBarViewController () <UIWebViewDelegate,OSCPopInputViewDelegate,CommentTextViewDelegate,TweetDetailDelegate,OSCTweetEditDelegate>

@property (nonatomic, strong) TweetDetailNewTableViewController *tweetDetailsNewVC;
@property (nonatomic, assign) int64_t tweetID;
@property (nonatomic, assign) BOOL isReply;

@property (nonatomic,strong) CommentTextView *commentTextView;
@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIView *tapView;

@property (nonatomic,assign) BOOL isEmojiPageOnScreen;
@property (nonatomic,strong) EmojiPageVC *emojiVC;

@property (nonatomic,strong) OSCTweetItem *tweetItem;

@property (nonatomic,strong) NSAttributedString *needSengAttr;   //储存发送成功之前的attribute

@end

@implementation TweetDetailsWithBottomBarViewController

- (instancetype)initWithTweetItem:(OSCTweetItem *)tweetItem{
    _tweetItem = tweetItem;
    if (_tweetItem.about) {
        if (_tweetItem.about.type == InformationTypeTweet) {
            NSString *string = [_tweetItem.about.content substringWithRange:NSMakeRange(_tweetItem.about.title.length + 1, _tweetItem.about.content.length - _tweetItem.about.title.length - 1)];
            _tweetItem.about.content = string;
        }
        [_tweetItem.about calculateLayoutWithForwardViewWidth:[UIScreen mainScreen].bounds.size.width - padding_left - padding_right];
    }
    return [self initWithTweetID:tweetItem.id];
}

- (instancetype)initWithTweetID:(NSInteger)tweetID
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        _tweetID = tweetID;
        _tweetDetailsNewVC = [[TweetDetailNewTableViewController alloc] init];
        _tweetDetailsNewVC.tweetID = _tweetID;
        if (_tweetItem) {
            _tweetDetailsNewVC.item = _tweetItem;
        }
        _tweetDetailsNewVC.detailDelegate = self;
        [self addChildViewController:_tweetDetailsNewVC];
        _tweetItem = _tweetDetailsNewVC.item;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [self setUpBlock];
    }
    
    return self;
}

- (void)setUpBlock
{
    __weak TweetDetailsWithBottomBarViewController *weakSelf = self;
    _tweetDetailsNewVC.didTweetCommentSelected = ^(OSCCommentItem *comment) {
        [weakSelf showEditView];
        [weakSelf.inputView insertAtrributeString2TextView:[Utils handle_TagString:[NSString stringWithFormat:@"@%@ ", comment.author.name] fontSize:14]];
    };
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"动弹详情";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
	[self addCommentTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setLayout
{
    [self.view addSubview:_tweetDetailsNewVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    _tweetDetailsNewVC.view.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - backViewHeight);
}

- (void)addCommentTextView{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake( 0, kScreenSize.height - 64 - backViewHeight, kScreenSize.width, backViewHeight)];
    bottomView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
    lineView.backgroundColor = [UIColor colorWithHex:0xd8d8d8];
    [bottomView addSubview:lineView];
    _commentTextView = [[CommentTextView alloc] initWithFrame:CGRectMake(8, 9, kScreenSize.width - 16, backViewHeight - 16) WithPlaceholder:@"发表评论" WithFont:[UIFont systemFontOfSize:15.0]];
    _commentTextView.commentTextViewDelegate = self;
    [_commentTextView handleAttributeWithAttribute:[OSCPopInputView getDraftNoteById:[NSString stringWithFormat:@"%ld_%lld",InformationTypeTweet,_tweetID]]];
    [bottomView addSubview:_commentTextView];
    [self.view addSubview:bottomView];
}


- (void)sendContentWithView:(__kindof UIScrollView* )inputView
{
    OSCAuthor* authorContacter = [OSCAuthor new];
    authorContacter.id = _tweetItem.author.id;
    authorContacter.name = _tweetItem.author.name;
    authorContacter.portrait = _tweetItem.author.portrait;
    [NSObject updateToRecentlyContacterList:authorContacter];
    
    NSString* sendStr ;
    if ([inputView isKindOfClass:[UITextView class]]) {
        UITextView* curTextView = (UITextView* )inputView;
        _needSengAttr = curTextView.attributedText;
        sendStr = [Utils convertRichTextToRawText:curTextView];
    }else if ([inputView isKindOfClass:[YYTextView class]]){
        YYTextView* curYYTextView = (YYTextView* )inputView;
        _needSengAttr = curYYTextView.attributedText;
        sendStr = [Utils convertRichTextToRawYYTextView:curYYTextView];
    }
    
    //本地数据
    OSCCommentItem *locationCommentItem = [OSCCommentItem new];
    OSCUserItem *author = [Config myNewProfile];
    locationCommentItem.author = author;
    locationCommentItem.content = [Utils convertRichTextIndexToNameWithYYTV:inputView];;
    locationCommentItem.pubDate = [Utils getCurrentTimeString];
    [_tweetDetailsNewVC reloadCommentListWithLocationData:locationCommentItem isSuccess:YES];
    _commentTextView.text = @"";
    _commentTextView.placeholder = @"发表评论";
    
    if (!sendStr || [sendStr isEqual:[NSNull null]] || sendStr.length < 1) { return; }
    
    //网络请求
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中.."];
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_COMMENTS_LIST_TWEET]
      parameters:@{
                   @"sourceId"  : @(_tweetID),
                   @"content"   : sendStr,
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             BOOL isSuccess = [responseObject[@"code"] integerValue] == 1;
             if (isSuccess) {
                 stauts.textLabel.text = @"评论发表成功";
                 _needSengAttr = nil;
             }else{
                 stauts.textLabel.text = @"内容无效，评论失败";
                 [_tweetDetailsNewVC reloadCommentListWithLocationData:locationCommentItem isSuccess:NO];
                 [_commentTextView handleAttributeWithAttribute:_needSengAttr];
            }
             [JDStatusBarNotification dismissAfter:2];
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             stauts.textLabel.text = @"网络异常，评论发送失败";
             [JDStatusBarNotification dismissAfter:2];
             [_tweetDetailsNewVC reloadCommentListWithLocationData:locationCommentItem isSuccess:NO];
             [_commentTextView handleAttributeWithAttribute:_needSengAttr];
    }];
}

- (void)keyboardWillShow:(NSNotification *)nsNotification {
    
    //获取键盘的高度
    
    self.emojiVC.view.hidden = YES;
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    float keyboardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
         _tapView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardRect.size.height);
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    if (!_isEmojiPageOnScreen) {
        [self hideEditView];
    }
}

#pragma mark --- editDelegate
- (void)sendCommentOfForwardWithTextView:(__kindof UIScrollView *)textView{
    NSAttributedString* attStr = [NSAttributedString new];
    if ([textView isKindOfClass:[UITextView class]]) {
        UITextView* curTextView = (UITextView* )textView;
        attStr = curTextView.attributedText;
    }else if ([textView isKindOfClass:[YYTextView class]]){
        YYTextView* curYYTextView = (YYTextView* )textView;
        attStr = curYYTextView.attributedText;
    }
    
    if (attStr.length != 0) {
        [self sendContentWithView:textView];
    }else{
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"转发不能为空";
        [HUD hideAnimated:YES afterDelay:1];
    }
}

#pragma mark --- CommentTextViewDelegate
- (void)ClickTextViewWithAttribute:(NSAttributedString *)attribute{
    [self showEditView];
}

#pragma mark --- OSCPopInputViewDelegate
- (void)popInputViewDidDismiss:(OSCPopInputView* )popInputView
            draftNoteAttribute:(NSAttributedString *)draftNoteAttribute
{
    if (popInputView == _inputView) {
        [_commentTextView handleAttributeWithAttribute:draftNoteAttribute];
    }
}

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView
{
    OSCTweetFriendsViewController * vc = [OSCTweetFriendsViewController new];
    [self hideEditView];
    [vc setSelectDone:^(NSString *result) {
        [self showEditView];
        NSAttributedString* resultAttStr = [Utils handle_TagString:result fontSize:14];
        [self.inputView insertAtrributeString2TextView:resultAttStr];
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
        [self hideEditView];
        return;
    }
    if (textView.attributedText.length > 0) {
        [self sendContentWithView:textView];
    }else{
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"评论不能为空";
        [HUD hideAnimated:YES afterDelay:1];
    }
    [self.inputView clearDraftNote];
    [self hideEditView];
}

- (void)popInputViewClickDidEmojiButton:(OSCPopInputView *)popInputView
{
    [self showAndHideEmoij];
}

#pragma makr --- 代理
- (void)clickForwardWithTweetItem:(OSCTweetItem *)tweetItem{
    OSCAbout* forwardInfo;
    TweetEditingVC *tweetEditingVC;
    if (tweetItem.about) {
        if (tweetItem.about.id <= 0) {
            [JDStatusBarNotification showWithStatus:@"该内容不存在，无法转发"];
            [JDStatusBarNotification dismissAfter:2];
            return;
        }
        NSString *string = [tweetItem.about.content substringWithRange:NSMakeRange(tweetItem.about.title.length + 1, tweetItem.about.content.length - tweetItem.about.title.length - 1)];
        forwardInfo = [OSCAbout forwardInfoModelWithTitle:tweetItem.about.title content:string type:tweetItem.about.type fullWidth:[UIScreen mainScreen].bounds.size.width - 32];
        NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"//@%@:",tweetItem.author.name]];
        [att appendAttributedString:[Utils contentStringFromRawString:tweetItem.content]];
        [att addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0x087221]} range:NSMakeRange(2, tweetItem.author.name.length + 1)];
        tweetEditingVC = [[TweetEditingVC alloc] initWithAboutID:tweetItem.about.id fromTweetID:tweetItem.id aboutType:tweetItem.about.type forwardItem:forwardInfo string:[att copy] isShowComment:YES];
    }else{
        forwardInfo = [OSCAbout forwardInfoModelWithTitle:tweetItem.author.name content:tweetItem.content type:InformationTypeTweet fullWidth:[UIScreen mainScreen].bounds.size.width - 32];
        tweetEditingVC = [[TweetEditingVC alloc] initWithAboutID:tweetItem.id fromTweetID:tweetItem.id aboutType:InformationTypeTweet forwardItem:forwardInfo string:nil isShowComment:YES];
    }
    
    tweetEditingVC.delegate = self;
    UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
    [self presentViewController:tweetEditingNav animated:YES completion:nil];
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

#pragma mark --- EditView status
- (void)showEditView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _backView = [[UIView alloc] initWithFrame:window.bounds];
    _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [window addSubview:_backView];

    //    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackView:)];
//    [_backView addGestureRecognizer:tapGR];
    
    
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 200)];
    tapView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackView:)];
        [tapView addGestureRecognizer:tapGR];
      [_backView addSubview:tapView];
    
// +  [_backView addGestureRecognizer:tapGR];

    
    self.emojiVC = [[EmojiPageVC alloc] initWithTextView:self.inputView];
    self.emojiVC.view.frame = CGRectMake(0, kScreenSize.height - 216, kScreenSize.width, 216);
    self.emojiVC.view.hidden = YES;
    [_backView addSubview:self.emojiVC.view];
    [_backView addSubview:self.inputView];
    
    [self.inputView activateInputView];
}
- (void)hideEditView{
    [self.inputView freezeInputView];
    [UIView animateWithDuration:0.3 animations:^{
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.inputView.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) ;
        self.emojiVC.view.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, 216);
        self.isEmojiPageOnScreen = NO;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
        _backView = nil;
    }];
}

#pragma mark --- lazy loading
- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld_%lld",InformationTypeTweet,_tweetID];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Emoji;
    }
    return _inputView;
}

@end
