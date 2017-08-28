//
//  OSCActivityHeaderView.h
//  iosapp
//
//  Created by 王恒 on 16/12/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCListItem.h"

#define kHeaderImageW_H 1.5
#define kPaddindLeft 16
#define kPaddingRight kPaddindLeft
#define kPaddingBottom 8
#define kHeaderImage_space_titleLabel 12
#define kTitleLabel_space_userImageView 7
#define kUserImage_space_nameLabel 8
#define kUserImage_W 26

@interface OSCActivityHeaderView : UIView

@property (nonatomic,strong) OSCListItem *model;

- (instancetype)init;

- (float)getHeaderViewHeight;

@end
