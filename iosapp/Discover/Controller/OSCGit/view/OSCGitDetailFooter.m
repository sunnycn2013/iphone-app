//
//  OSCGitDetailFooter.m
//  iosapp
//
//  Created by 王恒 on 17/3/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCGitDetailFooter.h"

#import "UIColor+Util.h"

#define kPaddingLeft 16
#define kPaddingRight 16
#define kPaddingTop 16
#define kPaddingBottom 16
#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCGitDetailFooter ()<IMYWebViewDelegate>

@property (nonatomic,strong) NSString *HTMLString;
@property (nonatomic,strong) IMYWebView *webView;

@end

@implementation OSCGitDetailFooter

- (instancetype)initWithHTMLString:(NSString *)HTMLString{
    self = [super init];
    if (self) {
        _HTMLString = HTMLString;
        [self addCotentView];
    }
    return self;
}

- (void)addCotentView{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
    lineView.backgroundColor = [UIColor separatorColor];
    [self addSubview:lineView];
    
    _webView = [[IMYWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width - kPaddingLeft - kPaddingRight, 1) usingUIWebView:NO];
    _webView.delegate = self;
    _webView.scrollView.scrollEnabled = NO;
    [self addSubview:_webView];
    
    [_webView loadHTMLString:_HTMLString baseURL:[NSBundle mainBundle].resourceURL];
}

#pragma --mark IMYWebViewDelegate
- (BOOL)webView:(IMYWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL shouldStart = NO;
    if ([self.delegate respondsToSelector:@selector(contentView:shouldStart:)]) {
        shouldStart = [self.delegate contentView:webView shouldStart:request];
    }
    return shouldStart;
}

- (void)webViewDidFinishLoad:(IMYWebView *)webView{
    [webView evaluateJavaScript:@"setImageClickFunction" completionHandler:nil];
    
    [webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(NSNumber* result, NSError *err) {
        CGFloat webViewHeight = [result floatValue];
        self.frame = CGRectMake(0, 0, kScreenSize.width, webViewHeight + kPaddingTop + kPaddingBottom);
        webView.frame = CGRectMake(kPaddingLeft, kPaddingTop , kScreenSize.width - kPaddingRight - kPaddingLeft, webViewHeight);
        if ([self.delegate respondsToSelector:@selector(contentViewDidFinishLoadWithHederViewHeight:)]) {
            [self.delegate contentViewDidFinishLoadWithHederViewHeight:webViewHeight];
        }
    }];
}

- (void)webView:(IMYWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error.debugDescription);
}

@end
