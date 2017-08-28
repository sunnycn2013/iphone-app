//
//  OSCGitDetailHeader.h
//  iosapp
//
//  Created by 王恒 on 17/3/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCGitDetailModel.h"

@protocol OSCGitDetailHeaderDelegate <NSObject>

- (void)codeClickWithModel:(OSCGitDetailModel *)detailModel;

@end

@interface OSCGitDetailHeader : UIView

@property (nonatomic,weak) id<OSCGitDetailHeaderDelegate> delegate;

- (instancetype)initWithModel:(OSCGitDetailModel *)model;

@end
