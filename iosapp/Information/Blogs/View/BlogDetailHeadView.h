//
//  BlogDetailHeadView.h
//  iosapp
//
//  Created by 李萍 on 2016/11/4.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IMYWebView,OSCListItem;
@interface BlogDetailHeadView : UIView

@property (nonatomic, strong) UIButton *relationButton;
@property (nonatomic, strong) IMYWebView *webView;
@property (nonatomic, strong) UIImageView *portraitView;

@property (nonatomic, strong) OSCListItem *blogDetail;

@end
