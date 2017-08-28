//
//  UINavigationController+Comment.h
//  iosapp
//
//  Created by Graphic-one on 16/11/30.
//  Copyright © 2016年 oschina. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface UINavigationController (Comment)

@end




/** 路由跳转 */
@interface UINavigationController (Router)

- (void)handleURL:(NSURL *)url
             name:(NSString* )name;

@end



/** using Runtime hock system push & pop action */
/** push pop 动画 */
typedef NS_ENUM(NSInteger,NaviAnimationPushType){
    NaviAnimationPushType_System  = NSNotFound,
    NaviAnimationPushType_Default = 1,
};
typedef NS_ENUM(NSInteger,NaviAnimationPopType){
    NaviAnimationPopType_System     = NSNotFound,
    NaviAnimationPopType_Default    = 1,
};
@interface UINavigationController (Animation)

@property (nonatomic,strong,readonly) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@property (nonatomic,assign) NaviAnimationPushType customPushType;

@property (nonatomic,assign) NaviAnimationPopType customPopType;

- (void)keepBackGestureRecognizer;

@end










@interface UINavigationControllerDelegate : NSObject


@end












