//
//  OSCMessageCenterController.m
//  iosapp
//
//  Created by Graphic-one on 16/8/23.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCMessageCenterController.h"

#import "OSCAtMeController.h"
#import "OSCCommentsController.h"
#import "OSCMessageController.h"

#import "Config.h"
#import "OSCObjsViewController.h"
#import "FriendsViewController.h"
#import "OSCMessageController.h"
#import "OSCModelHandler.h"
#import "OSCMsgCount.h"
#import "TitleBarView.h"

#import "NSObject+Comment.h"
#import "UIButton+Badge.h"

#import <AFNetworking.h>

@interface OSCMessageCenterController ()<UIScrollViewDelegate>

@property (nonatomic,strong) NSArray* titles;
@property (nonatomic,strong) NSArray* controllers;

@property (nonatomic,weak) TitleBarView *titleBar;
@property (nonatomic,weak) UIScrollView *scrollView;

@end

@implementation OSCMessageCenterController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        NSMutableArray* mutableControllers = @[[NSNull null],[NSNull null],[NSNull null]].mutableCopy;
        OSCMsgCount* shareMsgCount = [OSCMsgCount currentMsgCount];
        
        if (shareMsgCount.mention > 0) {
            [mutableControllers replaceObjectAtIndex:0 withObject:[[OSCAtMeController alloc] init]];
        }else if (shareMsgCount.review > 0){
            [mutableControllers replaceObjectAtIndex:1 withObject:[[OSCCommentsController alloc] init]];
        }else if (shareMsgCount.letter > 0){
            [mutableControllers replaceObjectAtIndex:2 withObject:[[OSCMessageController alloc] init]];
        }else{
            [mutableControllers replaceObjectAtIndex:0 withObject:[[OSCAtMeController alloc] init]];
        }
        
        _controllers = mutableControllers.copy;
    }
    return self;
}


#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"消息中心";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    TitleBarView* titleBar = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, 36) andTitles:self.titles andNeedScroll:NO];
    _titleBar = titleBar;
    _titleBar.backgroundColor = [UIColor titleBarColor];
    __weak typeof(self) weakSelf = self;
    _titleBar.titleButtonClicked = ^(NSUInteger index){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf.scrollView setContentOffset:CGPointMake(index * kScreenSize.width, 0) animated:NO];
        [strongSelf scrollViewDidEndDecelerating:strongSelf.scrollView];
    };
    [self.view addSubview:_titleBar];
    
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:(CGRect){{0,CGRectGetMaxY(_titleBar.frame)},{self.view.bounds.size.width,self.view.bounds.size.height - CGRectGetMaxY(_titleBar.frame)}}];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView = scrollView;
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * _controllers.count, _scrollView.frame.size.height);
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
        
    ///< setting nomal controller
    [self updateTitleText:[OSCMsgCount currentMsgCount]];
    [self updateSubControllersWithArr:_controllers];
    for (NSUInteger i = 0; i < _controllers.count; i++) {
        if (_controllers[i] != [NSNull null] && [_controllers[i] isKindOfClass:[UIViewController class]]) {
            [_titleBar scrollToCenterWithIndex:i];
            [_scrollView setContentOffset:(CGPoint){i * _scrollView.frame.size.width,0} animated:YES];
            break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateTitleTextNotication:)
                                                 name:MsgCount_Notification_Key
                                               object:nil];
    
}

- (void)updateTitleTextNotication:(NSNotification* )noti{
    OSCMsgCount *messageCount = (OSCMsgCount *)noti.object;
    [self updateTitleText:messageCount];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark --- UIScroll delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = round([scrollView contentOffset].x / kScreenSize.width);
    [_titleBar scrollToCenterWithIndex:index];
    [self handleContentView:index];
}

- (void)handleContentView:(NSUInteger)index{
    if (!_controllers[index] || _controllers[index] == [NSNull null]) {
        NSMutableArray* muatbleControllers = _controllers.mutableCopy;
        
        switch (index) {
            case 0:{
                [muatbleControllers replaceObjectAtIndex:0 withObject:[[OSCAtMeController alloc] init]];
                break;
            }
            case 1:{
                [muatbleControllers replaceObjectAtIndex:1 withObject:[[OSCCommentsController alloc] init]];
                break;
            }
            case 2:{
                [muatbleControllers replaceObjectAtIndex:2 withObject:[[OSCMessageController alloc] init]];
                break;
            }
    
            default:
                break;
        }
        
        _controllers = muatbleControllers.copy;
    }
    [self updateSubControllersWithArr:_controllers];
}

#pragma mark - update scrollView content view
- (void)updateSubControllersWithArr:(NSArray* )arr{
    for (NSUInteger i = 0; i < arr.count; i++) {
        id curObj = arr[i];
        if (curObj != [NSNull null] && [curObj isKindOfClass:[UIViewController class]]) {
            UIViewController* curController = (UIViewController* )curObj;
            UIView* curController_View = curController.view;
            if (curController_View.superview) {
                continue;
            }else{
                [self addChildViewController:curController];
                curController_View.frame = (CGRect){{i * _scrollView.frame.size.width,0},_scrollView.frame.size};
                [_scrollView addSubview:curController_View];
                
                UIView* placeholderView = [_scrollView viewWithTag:(i + 1000)];
                if (placeholderView) { [placeholderView removeFromSuperview]; }
            }
        }else{
            UIView* placeholderView_GA = [_scrollView viewWithTag:(i + 1000)];
            if (placeholderView_GA) { continue; }
            
            UIView* placeholderView = [[UIView alloc] initWithFrame:(CGRect){{i * _scrollView.frame.size.width,0},_scrollView.frame.size}];
            placeholderView.backgroundColor = [UIColor whiteColor];
            placeholderView.tag = i + 1000;
            
            [placeholderView addSubview:({
                UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                activity.center = placeholderView.center;
                [activity startAnimating];
                activity;
            })];
            [_scrollView addSubview:placeholderView];
        }
    }
}


#pragma mark - update titleBar text
- (void)updateTitleText:(OSCMsgCount* )curMsgCount{
    NSArray* count = @[@(curMsgCount.mention),@(curMsgCount.review),@(curMsgCount.letter)];
    for (NSUInteger i = 0; i < _titleBar.titleButtons.count; i++) {
        UIButton* btn = _titleBar.titleButtons[i];
        NSString* curTitle = [count[i] integerValue] == 0 ? _titles[i] : [NSString stringWithFormat:@"%@(%ld)",_titles[i],[count[i] integerValue]];
        [btn setTitle:curTitle forState:UIControlStateNormal];
    }
}


#pragma mark --- lazy loading
- (NSArray *)titles {
    if(_titles == nil) {
        _titles = @[@"@我",@"评论",@"私信"];
    }
    return _titles;
}

@end
