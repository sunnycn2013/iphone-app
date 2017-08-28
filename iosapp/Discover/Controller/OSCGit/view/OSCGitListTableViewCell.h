//
//  OSCGitListTableViewCell.h
//  iosapp
//
//  Created by 王恒 on 17/3/3.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCGitListModel.h"

@interface OSCGitListTableViewCell : UITableViewCell

@property (nonatomic,strong) OSCGitListModel *model;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
