//
//  MyActivityListViewController.h
//  iosapp
//
//  Created by 李萍 on 2017/1/19.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyActivityListViewController : UITableViewController

- (instancetype)initWithAuthorID:(long)userID authorName:(NSString *)authorName;

@end
