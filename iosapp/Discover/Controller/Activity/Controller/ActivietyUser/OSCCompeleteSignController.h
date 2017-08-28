//
//  OSCCompeleteSignController.h
//  iosapp
//
//  Created by 王恒 on 17/4/14.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCCompeleteSignController : UIViewController

- (instancetype)initWithSignInResult:(NSDictionary *)result
                    withActivityName:(NSString *)title;

@end
