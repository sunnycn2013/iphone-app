//
//  OSCActivityCell.h
//  iosapp
//
//  Created by 王恒 on 17/4/11.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCActivityUserModel.h"

@interface OSCActivityNormalCell : UITableViewCell

@property (nonatomic,strong) NSString *detail;
@property (nonatomic,strong) NSString *info;
@property (nonatomic,assign) BOOL isStauts;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end


@interface OSCActivityRemarkCell : UITableViewCell

@property (nonatomic,strong) NSString *detail;
@property (nonatomic,assign) CGFloat textHeight;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
