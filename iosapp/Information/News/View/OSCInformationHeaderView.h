//
//  OSCInformationHeaderView.h
//  iosapp
//
//  Created by 王恒 on 16/11/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMYWebView.h"

@protocol OSCInformationHeaderViewDelegate <NSObject>

@required
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request;

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height;

@end

@class OSCListItem;
@interface OSCInformationHeaderView : UIView

@property (nonatomic,strong) OSCListItem* newsModel;

@property (nonatomic,assign) id<OSCInformationHeaderViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end




@interface OSCInformationTitleView : UIView

@property (nonatomic,strong) OSCListItem* newsModel;

- (instancetype)initWithFrame:(CGRect)frame;

@end
