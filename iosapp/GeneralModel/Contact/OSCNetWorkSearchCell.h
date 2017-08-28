//
//  OSCNetWorkSearchCell.h
//  iosapp
//
//  Created by Graphic-one on 16/12/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OSCNetWorkSearchCellReuseIdentifier  @"OSCNetWorkSearchCellReuseIdentifier"

@class OSCAuthor;
@interface OSCNetWorkSearchCell : UITableViewCell

@property (nonatomic,strong) OSCAuthor* author;

@end
