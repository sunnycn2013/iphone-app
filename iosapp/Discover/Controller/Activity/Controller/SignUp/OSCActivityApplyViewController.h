//
//  OSCActivityApplyViewController.h
//  iosapp
//
//  Created by 李萍 on 2016/12/6.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCActivityApplyModel.h"

@interface OSCActivityApplyViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;

- (instancetype)initWithActivitySourceId:(NSInteger)source;

@end


