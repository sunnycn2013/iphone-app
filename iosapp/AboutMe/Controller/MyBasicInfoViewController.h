//
//  MyBasicInfoViewController.h
//  iosapp
//
//  Created by 李萍 on 15/2/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCUserItem;
@interface MyBasicInfoViewController : UITableViewController

- (instancetype)initWithUserItem:(OSCUserItem *)userItem
              isNeedShowIdendity:(BOOL)isShowIdendity;

@end
