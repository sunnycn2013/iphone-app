//
//  OSCNaviBarAnimationComment.h
//  iosapp
//
//  Created by Graphic-one on 16/11/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,OSCCustomAnimation){
    OSCCustomAnimation_OnlyPush,
    OSCCustomAnimation_OnlyPop ,
    OSCCustomAnimation_All
};

@interface OSCNaviBarAnimationComment : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic,assign) NSTimeInterval duration;

@property (nonatomic,assign) OSCCustomAnimation needAnimation;

@property(nonatomic,strong,readwrite)UIPercentDrivenInteractiveTransition *interactivePopTransition;


- (void)pushViewController;    // Covered by the subclass

- (void)popViewController;    // Covered by the subclass

@end


#pragma mark --- push pop 动画comment

/** 整体push pop */
__attribute__((objc_subclassing_restricted))
@interface OSCNaviBarAnimationDefault : OSCNaviBarAnimationComment

@end

/** 中心圆放大效果push pop*/
__attribute__((objc_subclassing_restricted))
@interface OSCNaviBarAnimationCenter : OSCNaviBarAnimationComment

@end
