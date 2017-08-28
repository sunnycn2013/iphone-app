//
//  OSCTweetAtMeCell.h
//  iosapp
//
//  Created by 王恒 on 16/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCMessageCenter.h"
#import "OSCAtMeCell.h"

@interface OSCTweetAtMeCell : UITableViewCell

@property (nonatomic,strong) AtMeItem *item;
@property (nonatomic,assign) id<OSCAtMeCellDelegate> delegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
