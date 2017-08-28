//
//  OSCActivityUserController.h
//  iosapp
//
//  Created by 王恒 on 17/4/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , ActivityUserType){
    ActivityUserTypeNormal = 1,
    ActivityUserTypeSign,
};

@interface OSCActivityUserController : UIViewController

- (instancetype)initWithType:(ActivityUserType)type
              withActivityID:(NSInteger)activityID
                        isQR:(BOOL)isQR;

@end
