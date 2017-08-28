//
//  UINavigationController+Comment.m
//  iosapp
//
//  Created by Graphic-one on 16/11/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "UINavigationController+Comment.h"
#import "OSCUserHomePageController.h"
#import "ImageViewerController.h"
#import "PostsViewController.h"
#import "TweetDetailsWithBottomBarViewController.h"
#import "TweetTableViewController.h"
#import "NewBlogDetailController.h"
#import "OSCEventSignInViewController.h"
#import "OSCGitDetailController.h"
#import "OSCActivityUserController.h"

#import "OSCNews.h"
#import "OSCPost.h"
#import "OSCTweet.h"
#import "Config.h"
#import "SoftWareViewController.h"
#import "QuesAnsDetailViewController.h"
#import "OSCInformationDetailController.h"
#import "OSCPhotoGroupView.h"
#import "UIDevice+SystemInfo.h"

#import "OSCNaviBarAnimationComment.h"
#import "GANaviBarAnimationComment.h"
#import "ActivityDetailViewController.h"
#import "OSCCodeSnippetDetailController.h"

#import <objc/runtime.h>


@implementation UINavigationController (Comment)

@end




@import SafariServices ;

/** 路由跳转 */
@implementation UINavigationController (Router)

- (void)handleURL:(NSURL *)url
             name:(NSString* )name
{
    
//  http://git.oschina.net/suu/codes/28hb3mdyurkvjwo17liet32

    
    
    NSString *urlString = url.absoluteString;
    
    //判断是否包含 oschina.net 来确定是不是站内链接
    NSRange range = [urlString rangeOfString:@"oschina.net"];
    
    if (range.length <= 0) {
        //TODO: 替换合适的webviewcontroller
        if ( [url.absoluteString hasPrefix:@"http"]) {
            url = [NSURL URLWithString:@"https://www.baidu.com/"];
            SFSafariViewController *webviewController = [[SFSafariViewController alloc] initWithURL:url];
            webviewController.hidesBottomBarWhenPushed = YES;
			[self presentViewController:webviewController animated:YES completion:^{
				//
			}];
        }else{
            [[UIApplication sharedApplication] openURL:url];
        }
    } else {
        
        //站内链接
        if ([url.absoluteString hasPrefix:@"https"]) {
            urlString = [urlString substringFromIndex:8];
        }else{
            urlString = [urlString substringFromIndex:7];
        }
        NSArray *pathComponents = [urlString pathComponents];
        NSString *prefix = [pathComponents[0] componentsSeparatedByString:@"."][0];
        UIViewController *viewController;
        
        if ([prefix isEqualToString:@"my"]) {
            if (pathComponents.count == 2) {
                if (name != nil) {
                    viewController = [[OSCUserHomePageController alloc] initWithUserName:name];
                    viewController.navigationItem.title = @"用户详情";
                }else{
                    // 个人专页 my.oschina.net/dong706
                    viewController = [[OSCUserHomePageController alloc] initWithUserHisName:pathComponents[1]];
                    viewController.navigationItem.title = @"用户详情";
                }
            } else if (pathComponents.count == 3) {
                if (name != nil) {
                    viewController = [[OSCUserHomePageController alloc] initWithUserName:name];
                    viewController.navigationItem.title = @"用户详情";
                }else{
                    // 个人专页 my.oschina.net/u/12
                    if ([pathComponents[1] isEqualToString:@"u"]) {
                        viewController= [[OSCUserHomePageController alloc] initWithUserID:[pathComponents[2] longLongValue]];
                        viewController.navigationItem.title = @"用户详情";
                    }
                }
            } else if (pathComponents.count == 4) {
                NSString *type = pathComponents[2];
                if ([type isEqualToString:@"blog"]) {
                    NSInteger blogId = [pathComponents[3] integerValue];
                    if(blogId > 0) {
                        viewController = [[NewBlogDetailController alloc] initWithDetailId:blogId];
                        viewController.hidesBottomBarWhenPushed = YES;
                    }
                    
                } else if ([type isEqualToString:@"tweet"]){
                    OSCTweet *tweet = [OSCTweet new];
                    tweet.tweetID = [pathComponents[3] longLongValue];
                    viewController = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
                    viewController.navigationItem.title = @"动弹详情";
                }
            } else if(pathComponents.count == 5) {
                NSString *type = pathComponents[3];
                if ([type isEqualToString:@"blog"]) {
                    NSInteger blogId = [pathComponents[4] integerValue];
                    if(blogId > 0) {
                        viewController = [[NewBlogDetailController alloc] initWithDetailId:blogId];
                        viewController.hidesBottomBarWhenPushed = YES;
                    }
                }else if ([type isEqualToString:@"tweet"]){
                    OSCTweet *tweet = [OSCTweet new];
                    tweet.tweetID = [pathComponents[4] longLongValue];
                    viewController = [[TweetDetailsWithBottomBarViewController alloc] initWithTweetID:tweet.tweetID];
                    viewController.navigationItem.title = @"动弹详情";
                }
            }
        } else if ([prefix isEqualToString:@"www"] || [prefix isEqualToString:@"m"]) {
            //https://www.oschina.net/event/signin?event=2192570
			//https://www.oschina.net/event/2200142 // 新活动类型
            //新闻,软件,问答
            NSArray *urlComponents = [urlString componentsSeparatedByString:@"/"];
            NSUInteger count = urlComponents.count;
            if (count >= 3) {
                NSString *type = urlComponents[1];
                if ([type isEqualToString:@"news"]) {
                    // 新闻
                    // www.oschina.net/news/27259/mobile-internet-market-is-small
                    int64_t newsID = [urlComponents[2] longLongValue];
                    //新版资讯界面
                    viewController =[[OSCInformationDetailController alloc] initWithInformationID:newsID];
                    viewController.hidesBottomBarWhenPushed = YES;
                    
                } else if ([urlString hasPrefix:@"www.oschina.net/event/signin?event="]) {//活动签到
                    NSInteger eventId = [[urlString componentsSeparatedByString:@"="][1] integerValue];
                    if ([Config getOwnID] == 0) {
                        viewController = [[OSCEventSignInViewController alloc] initWithActivityModelID:eventId];
                    }else{
                        viewController = [[OSCActivityUserController alloc] initWithType:ActivityUserTypeSign withActivityID:eventId isQR:YES];
                    }
                    
                    
                } else if ([type isEqualToString:@"p"]) {
                    // 软件 www.oschina.net/p/jx
                    OSCNews *news = [OSCNews new];
                    news.type = NewsTypeSoftWare;
                    news.attachment = urlComponents[2];
                    
                    viewController = [[SoftWareViewController alloc] initWithSoftWareIdentity:news.attachment];
                    viewController.hidesBottomBarWhenPushed = YES;
                    viewController.navigationItem.title = @"软件详情";
                    
                } else if ([type isEqualToString:@"question"]) {
                    // 问答
                    
                    if (count == 3) {
                        // 问答 www.oschina.net/question/12_45738
                        NSArray *IDs = [urlComponents[2] componentsSeparatedByString:@"_"];
                        if ([IDs count] >= 2) {
                            OSCPost *post = [OSCPost new];
                            post.postID = [IDs[1] longLongValue];
                            
                            QuesAnsDetailViewController *questionViewController = [[QuesAnsDetailViewController alloc] initWithDetailID:post.postID];
                            viewController = questionViewController;
                            viewController.hidesBottomBarWhenPushed = YES;
                            viewController.navigationItem.title = @"帖子详情";
                        }
                    } else if (count >= 4) {
                        // 问答-标签 www.oschina.net/question/tag/python
                        NSString *tag = urlComponents.lastObject;
                        
                        viewController = [PostsViewController new];
                        ((PostsViewController *)viewController).generateURL = ^NSString * (NSUInteger page) {
                            return [NSString stringWithFormat:@"%@%@?tag=%@&pageIndex=0&%@", OSCAPI_PREFIX, OSCAPI_POSTS_LIST, tag, OSCAPI_SUFFIX];
                        };
                        
                        ((PostsViewController *)viewController).objClass = [OSCPost class];
						viewController.navigationItem.title = [tag stringByRemovingPercentEncoding];
                    }
                } else if ([type isEqualToString:@"tweet-topic"]) {
                    //话题
                    urlString = [urlString stringByRemovingPercentEncoding];
                    urlComponents = [urlString componentsSeparatedByString:@"/"];
                    viewController = [[TweetTableViewController alloc] initTweetListWithTopic:urlComponents[2]];
                    viewController.title = [NSString stringWithFormat:@"#%@#", urlComponents[2]];
                    viewController.hidesBottomBarWhenPushed = YES;
				} else if([type isEqualToString:@"event"]) {
					//新版活动详情
					//https://www.oschina.net/event/2200142
					viewController = [[ActivityDetailViewController alloc] initWithActivityID:[urlComponents[2] integerValue]];
					viewController.hidesBottomBarWhenPushed = YES;
					viewController.navigationItem.title = @"活动详情";
				}
            }
        } else if ([prefix isEqualToString:@"static"]) {
            ImageViewerController *imageViewerVC = [[ImageViewerController alloc] initWithImageURL:url];
            [self presentViewController:imageViewerVC animated:YES completion:nil];
            return;
        } else if ([prefix isEqualToString:@"git"]){
            
            NSString *nameWithSpace = [[url.absoluteString componentsSeparatedByString:@"git.oschina.net/"] lastObject];
            
            //三个特殊链接
            NSString *path = pathComponents[1];//
            if (![path isEqualToString:@"enterprises"] && ![path isEqualToString:@"gists"]&& ![path isEqualToString:@"explore"] ) {
                
                nameWithSpace = [nameWithSpace stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
                nameWithSpace = [nameWithSpace stringByReplacingOccurrencesOfString:@"." withString:@"+"];
                viewController = [[OSCGitDetailController alloc] initWithProjectNameSpace:nameWithSpace];
                viewController.hidesBottomBarWhenPushed = YES;
            }
            
            //处理代码片段详情跳转  (有三段、且尾部有)
            if (pathComponents.count == 3 && [pathComponents[2] hasSuffix:@".code"]) {
                NSArray *arr = [pathComponents[2] componentsSeparatedByString:@"."];
                NSString *idStr = arr[0];
                viewController = [[OSCCodeSnippetDetailController alloc] initWithContentIdStr:idStr];
                viewController.hidesBottomBarWhenPushed = YES;
            }
            
        }
        
        if (viewController) {
            [self pushViewController:viewController animated:YES];
        } else {
            SFSafariViewController *webviewController = [[SFSafariViewController alloc] initWithURL:url];
            webviewController.hidesBottomBarWhenPushed = YES;
			[self presentViewController:webviewController animated:YES completion:^{
				//
			}];
        }
    }
}


@end




/** push pop 动画 */
@interface UINavigationController () <UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong,readwrite)UIPercentDrivenInteractiveTransition *interactivePopTransition;
@end

@implementation UINavigationController (Animation)

- (void)setCustomPopType:(NaviAnimationPopType)customPopType{
    objc_setAssociatedObject(self, _cmd, @(customPopType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NaviAnimationPopType)customPopType{
    return [objc_getAssociatedObject(self, @selector(setCustomPopType:)) integerValue];
}

- (void)setCustomPushType:(NaviAnimationPushType)customPushType{
    objc_setAssociatedObject(self, _cmd, @(customPushType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NaviAnimationPushType)customPushType{
    return [objc_getAssociatedObject(self, @selector(setCustomPushType:)) integerValue];
}


+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL sel_system_push = @selector(pushViewController:animated:);
        Method method_system_push = class_getInstanceMethod(self, sel_system_push);
        SEL sel_custom_push = @selector(customPushViewController:animated:);
        Method method_custom_push = class_getInstanceMethod(self, sel_custom_push);
        BOOL isAdd_push = class_addMethod(self, sel_system_push, method_getImplementation(method_custom_push), method_getTypeEncoding(method_custom_push));
        if (isAdd_push) {
            class_replaceMethod(self, sel_custom_push, method_getImplementation(method_system_push), method_getTypeEncoding(method_system_push));
        }else{
            method_exchangeImplementations(method_system_push, method_custom_push);
        }
        
        SEL sel_system_pop = @selector(popViewControllerAnimated:);
        Method method_system_pop = class_getInstanceMethod(self, sel_system_pop);
        SEL sel_custom_pop = @selector(customPopViewControllerAnimated:);
        Method method_custom_pop = class_getInstanceMethod(self, sel_custom_pop);
        BOOL isAdd_pop = class_addMethod(self, sel_system_pop, method_getImplementation(method_custom_pop), method_getTypeEncoding(method_custom_pop));
        if (isAdd_pop) {
            class_replaceMethod(self, sel_custom_pop, method_getImplementation(method_system_pop), method_getTypeEncoding(method_system_pop));
        }else{
            method_exchangeImplementations(method_system_pop, method_custom_pop);
        }
    });
}

- (void)customPushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    switch (self.customPushType) {
        case NaviAnimationPushType_System:
//            self.delegate = self;
            [self customPushViewController:viewController animated:YES];
            break;
        case NaviAnimationPushType_Default:
//            self.delegate = self;
            [self customPushViewController:viewController animated:YES];
            break;
            
        default:
//            self.delegate = self;
            [self customPushViewController:viewController animated:YES];
            break;
    }
}
- (UIViewController *)customPopViewControllerAnimated:(BOOL)animated{
    switch (self.customPopType) {
        case NaviAnimationPopType_System:

            [self customPopViewControllerAnimated:YES];
            break;
        case NaviAnimationPopType_Default:

            [self customPopViewControllerAnimated:YES];
            break;
            
        default:
            [self customPopViewControllerAnimated:YES];
            break;
    }
    return nil;
}


#pragma mark --- UINavigationController Delegate
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(OSCNaviBarAnimationComment* ) animationController
{
    return animationController.interactivePopTransition;
}
- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                            animationControllerForOperation:(UINavigationControllerOperation)operation
                                                         fromViewController:(UIViewController *)fromVC
                                                           toViewController:(UIViewController *)toVC
{
    if (fromVC.navigationController.interactivePopTransition) {
        GANaviBarAnimationComment* animation = [self distributionAnimationWithOperation:operation];
        if (animation) {
            animation.interactivePopTransition = fromVC.navigationController.interactivePopTransition;
        }
        return animation;
    }else{
        GANaviBarAnimationComment* animation = [self distributionAnimationWithOperation:operation];
        return animation;
    }
}

#pragma mark --- 动画分发
- (nullable GANaviBarAnimationComment* )distributionAnimationWithOperation:(UINavigationControllerOperation)operation
{
    GANaviBarAnimationComment* animation = [GANaviBarAnimationComment new];
    
    if (operation == UINavigationControllerOperationPush) {
        switch (self.customPushType) {
            case NaviAnimationPushType_Default:{
                animation = [[GANaviBarAnimationComment alloc] initWithTransitionType:operation duration:0.6 animateType:GANaviBarAnimationType_Default];
                break;
            }
            case NaviAnimationPushType_System:{
                return nil;
                break;
            }
                
            default:{
                return nil;
                break;
            }
        }
    }
    
    else if (operation == UINavigationControllerOperationPop){
        switch (self.customPopType) {
            case NaviAnimationPopType_Default:{
                animation = [[GANaviBarAnimationComment alloc] initWithTransitionType:operation duration:0.6 animateType:GANaviBarAnimationType_Default];
                break;
            }
            case NaviAnimationPopType_System:{
                return nil;
                break;
            }
                
            default:{
                return nil;
                break;
            }
        }
    
    }
    
    else{ // operation == UINavigationControllerOperationNone
        return nil;
    }
    
    return animation;
}


#pragma mark --- 保持返回手势
- (void)keepBackGestureRecognizer{
    if (self && self != [self.viewControllers firstObject]) {
        UIPanGestureRecognizer* pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        [self.view addGestureRecognizer:pan];
    }
}
#pragma mark --- UIGestureRecognizer Delegate
- (void)handlePanGesture:(UIPanGestureRecognizer* )recognizer
{
    CGFloat progress = [recognizer translationInView:self.view].x / self.view.bounds.size.width;
    progress = MIN(1.0, MAX(0.0, progress));
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc]init];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
    {
        if (progress > 0.25){
            [self.interactivePopTransition finishInteractiveTransition];
        }else{
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    return [gestureRecognizer velocityInView:self.view].x > 0;
}
@end









@implementation UINavigationControllerDelegate


@end














