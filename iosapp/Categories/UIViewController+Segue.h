//
//  UIViewController+Segue.h
//  iosapp
//
//  Created by AeternChan on 7/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackButtonHandlerProtocol <NSObject>
@optional
// Override this method in UIViewController derived class to handle 'Back' button click
-(BOOL)navigationShouldPopOnBackButton;
@end

@interface UIViewController (Segue)<BackButtonHandlerProtocol>

- (IBAction)pushLoginViewController:(id)sender;
- (IBAction)pushSearchViewController:(id)sender;


@end
