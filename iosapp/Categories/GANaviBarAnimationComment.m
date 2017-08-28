//
//  GANaviBarAnimationComment.m
//  iosapp
//
//  Created by Graphic-one on 16/12/1.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "GANaviBarAnimationComment.h"

@interface GANaviBarAnimationComment ()
@property(nonatomic,assign)NSTimeInterval duration;
@property(nonatomic,assign,readwrite)UINavigationControllerOperation transitionType;
@end

@implementation GANaviBarAnimationComment

- (__kindof GANaviBarAnimationComment* )initWithTransitionType:(UINavigationControllerOperation)transitionType
                                                      duration:(NSTimeInterval)duration
                                                   animateType:(GANaviBarAnimationType)animationType
{
    switch (animationType) {
        case GANaviBarAnimationType_System:{
            self = [GANaviBarAnimation_System new];
            break;
        }
            
        case GANaviBarAnimationType_Default:{
            self = [GANaviBarAnimation_Default new];
            break;
        }
            
        default:{
            break;
        }
    }
    if (self) {
        self.duration = duration;
        self.transitionType = transitionType;
    }
    return self;
}

#pragma mark - UIViewController Animation Transition

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.transitionType == UINavigationControllerOperationPush)
    {
        [self push:transitionContext];
    }
    else if (self.transitionType == UINavigationControllerOperationPop)
    {
        [self pop:transitionContext];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    if (!transitionCompleted)
    {
        return;
    }
    if (self.transitionType == UINavigationControllerOperationPush)
    {
        [self pushEnded];
    }
    else if (self.transitionType == UINavigationControllerOperationPop)
    {
        [self popEnded];
    }
}

- (void)push:(id<UIViewControllerContextTransitioning>)transitionContext{
    ///Covered by the subclass
}
- (void)pop:(id<UIViewControllerContextTransitioning>)transitionContext{
    ///Covered by the subclass
}
- (void)pushEnded {
    ///Covered by the subclass
}
- (void)popEnded {
    ///Covered by the subclass
}

@end



/** GANaviBarAnimation_System 使用系统的push pop动画 */
@implementation GANaviBarAnimation_System


@end


/** GANaviBarAnimation_Default 整体进行移动进行push pop动画*/
@implementation GANaviBarAnimation_Default


@end








