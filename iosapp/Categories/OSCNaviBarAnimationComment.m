//
//  OSCNaviBarAnimationComment.m
//  iosapp
//
//  Created by Graphic-one on 16/11/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNaviBarAnimationComment.h"

@interface OSCNaviBarAnimationComment ()

@end

@implementation OSCNaviBarAnimationComment


#pragma mark --- UIViewController Animated Transitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (transitionContext) {
        
    }
}

- (void)pushViewController{
    // Covered by the subclass
}
- (void)popViewController{
    // Covered by the subclass
}
@end




@implementation OSCNaviBarAnimationDefault
- (void)pushViewController{

}
- (void)popViewController{

}
@end
