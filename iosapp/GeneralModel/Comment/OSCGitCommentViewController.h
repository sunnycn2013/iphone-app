//
//  OSCGitCommentViewController.h
//  iosapp
//
//  Created by 王恒 on 17/3/15.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCGitCommentViewController : UIViewController

- (instancetype)initGitCommentVCWithSourceID:(NSInteger)sourceID
                                    WithName:(NSString *)name
                               WithNameSpace:(NSString *)nameSpace;

@end
