//
//  OSCTweetFriendsViewController.h
//  iosapp
//
//  Created by 李萍 on 2016/12/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCTweetFriendsViewController : UITableViewController

@property (nonatomic,weak) id delegate;

@property (nonatomic, copy) void (^selectDone)(NSString *result);

@end
