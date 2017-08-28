//
//  OSCAttendantListViewController.h
//  iosapp
//
//  Created by 李萍 on 2016/12/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCAttendantListViewController : UITableViewController

- (instancetype)initWithSourceId:(NSInteger)sourceID filterText:(NSString *)filterText;

@end
