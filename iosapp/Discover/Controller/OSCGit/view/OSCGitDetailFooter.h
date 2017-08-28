//
//  OSCGitDetailFooter.h
//  iosapp
//
//  Created by 王恒 on 17/3/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IMYWebView.h"

@protocol OSCGitFooterViewDelegate <NSObject>

@required
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request;

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height;

@end

@interface OSCGitDetailFooter : UIView

@property (nonatomic,assign) id<OSCGitFooterViewDelegate> delegate;

- (instancetype)initWithHTMLString:(NSString *)HTMLString;

@end
