//
//  GANaviBarAnimationComment.h
//  iosapp
//
//  Created by Graphic-one on 16/12/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,GANaviBarAnimationType){
    GANaviBarAnimationType_System  = NSNotFound,
    GANaviBarAnimationType_Default = 1,
};

@interface GANaviBarAnimationComment : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign,readonly)  UINavigationControllerOperation transitionType;

@property (nonatomic,strong,readwrite) UIPercentDrivenInteractiveTransition *interactivePopTransition;

- (__kindof GANaviBarAnimationComment* )initWithTransitionType:(UINavigationControllerOperation)transitionType
                                                      duration:(NSTimeInterval)duration
                                                   animateType:(GANaviBarAnimationType)animationType;

/** Covered by the subclass */
- (void)push:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)pop:(id<UIViewControllerContextTransitioning>)transitionContext;
- (void)pushEnded;
- (void)popEnded;

@end



/** GANaviBarAnimation_System 使用系统的push pop动画 */
@interface GANaviBarAnimation_System : GANaviBarAnimationComment

@end


/** GANaviBarAnimation_Default 整体进行移动进行push pop动画*/
@interface GANaviBarAnimation_Default : GANaviBarAnimationComment

@end

























