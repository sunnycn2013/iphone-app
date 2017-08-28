//
//  OSCCustomAnimationViewController.m
//  iosapp
//
//  Created by Graphic-one on 16/11/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCustomAnimationViewController.h"

@interface OSCCustomAnimationViewController () <UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong,readwrite)UIPercentDrivenInteractiveTransition *interactivePopTransition;

@end

@implementation OSCCustomAnimationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.delegate = self;
    
    if (self.navigationController && self != [self.navigationController.viewControllers firstObject]) {
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
//    NSLog(@"progress---%.2f",progress);
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

#pragma mark --- UINavigation Delegate
- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                                   interactionControllerForAnimationController:(OSCNaviBarAnimationComment* ) animationController
{
    return animationController.interactivePopTransition;
}

//- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                            animationControllerForOperation:(UINavigationControllerOperation)operation
//                                                         fromViewController:(OSCCustomAnimationViewController *)fromVC
//                                                           toViewController:(UIViewController *)toVC
//{
//    if (fromVC.interactivePopTransition)
//    {
//        OSCCustomAnimationViewController *animation = [[OSCCustomAnimationViewController alloc]initWithType:operation Duration:0.6 animateType:self.animationType];
//        animation.interactivePopTransition = fromVC.interactivePopTransition;
//        return animation; //手势
//    }
//    else
//    {
//        WTKBaseAnimation *animation = [[WTKBaseAnimation alloc]initWithType:operation Duration:0.6 animateType:self.animationType];
//        return animation;//非手势
//    }
//}


@end
