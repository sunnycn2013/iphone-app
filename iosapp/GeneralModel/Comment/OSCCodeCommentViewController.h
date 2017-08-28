//
//  OSCCodeCommentViewController.h
//  iosapp
//
//  Created by 王恒 on 17/3/15.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCCodeCommentViewController : UIViewController

- (instancetype)initCodeCommentVCWithGistId:(NSString *)idStr
                                   WithName:(NSString *)name
                                    WithUrl:(NSString *)url;

@end
