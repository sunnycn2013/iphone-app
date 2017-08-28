//
//  OSCCodeSnippetListTableViewCell.h
//  iosapp
//
//  Created by wupei on 2017/5/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCCodeSnippetListModel.h"

@interface OSCCodeSnippetListTableViewCell : UITableViewCell

@property (nonatomic,strong) OSCCodeSnippetListModel *model;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
