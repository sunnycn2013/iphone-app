//
//  OSCNearbyPeopleViewController.h
//  iosapp
//
//  Created by 王恒 on 16/12/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OSCNearbyPeopleViewCDelegate <NSObject>

- (void)completeUpdateUserLocationIsUpload:(BOOL)isUpload;

@end

@interface OSCNearbyPeopleViewController : UIViewController

@property (nonatomic,weak) id<OSCNearbyPeopleViewCDelegate> delegate;

- (instancetype)init;

@end
