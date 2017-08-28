//
//  UIViewController+Comment.m
//  iosapp
//
//  Created by Graphic-one on 17/2/23.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "UIViewController+Comment.h"

@implementation UIViewController (Comment)

+ (UIViewController *)topViewControllerForViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerForViewController:navigationController.visibleViewController];
    }
    
    if (rootViewController.presentedViewController) {
        return [self topViewControllerForViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}

@end
