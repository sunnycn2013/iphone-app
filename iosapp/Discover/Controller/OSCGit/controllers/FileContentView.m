//
//  FileContentView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-7.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "FileContentView.h"
#import "GLBlob.h"
#import "OSCShareManager.h"
#import "UIColor+Util.h"
#import <objc/runtime.h>
#import "AFHTTPRequestOperationManager+Util.h"
#import <MBProgressHUD.h>
#import <Masonry.h>
#import "AppDelegate.h"
#import <YYKit.h>

@interface UIView (HideToastActivity)
- (void)hideToastActivity ;
@end

@interface FileContentView ()

@property (nonatomic, strong) UIView* headerView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSDictionary* paraDic;

@end

@implementation FileContentView

- (instancetype)initWithProjectID:(NSUInteger)id filePath:(NSString* )filePath ref:(NSString* )refName{
    self = [super init];
    if(self){
        
        _projectID = id;
        _path = filePath;
        _fileName = filePath;
        
        _url = [NSString stringWithFormat:@"http://git.oschina.net/api/v3/projects/%lu/repository/files",(unsigned long)id];
        _paraDic = @{
                     @"file_path" : filePath.length > 0 ? filePath : @"/",
                     @"ref"       : refName.length  > 0 ? refName  : @"master",
                     };
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.headerView];
    
    self.webView = [[UIWebView alloc] initWithFrame:(CGRect){{0,64 + 44},{self.view.bounds.size.width,self.view.bounds.size.height - 64 - 44}}];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.scrollView.bounces = NO;
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.userInteractionEnabled = YES;
    self.webView.scalesPageToFit = YES;
    self.webView.multipleTouchEnabled = YES;
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    [self.view addSubview:self.webView];
    
    [self fetchFileContent];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_share_black_normal"] style:UIBarButtonItemStyleDone target:self action:@selector(shareCode)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)orientChange:(NSNotification *)noti {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait: {
            [UIView animateWithDuration:0.25 animations:^{
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                [UIApplication sharedApplication].statusBarHidden = NO;
                self.headerView.hidden = NO;
                self.webView.transform = CGAffineTransformMakeRotation(0);
                self.webView.frame = CGRectMake(0, 64 + self.headerView.height, kScreenSize.width, kScreenSize.height -  64 - self.headerView.height);
                
            }];
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            [UIView animateWithDuration:0.25 animations:^{
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                [UIApplication sharedApplication].statusBarHidden = YES;
                self.headerView.hidden = YES;
                self.webView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.webView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height);
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            [UIView animateWithDuration:0.25 animations:^{
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                [UIApplication sharedApplication].statusBarHidden = YES;
                self.headerView.hidden = YES;
                self.webView.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                self.webView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height);
            }];
        }
            break;
        default:
            break;
    }
}

- (void)shareCode{
    NSString* path = [NSString stringWithFormat:@"https://git.oschina.net/%@/blob/%@/%@",_detailModel.path_with_namespace,_paraDic[@"ref"],_fileName];
    [[OSCShareManager shareManager] showShareBoardWithGitCodeModel:_detailModel path:path];
}

- (BOOL)shouldAutomaticallyForwardRotationMethods
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - 获取文件数据
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)fetchFileContent
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger GET:_url
     parameters:_paraDic
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [_hud hide:YES afterDelay:1];
            if (responseObject == nil) { } else {
                _content = [[GLBlob alloc] initWithJSON:responseObject].content;
                [self render];
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (error != nil) {
                _hud.detailsLabelText = [NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code];
            } else {
                _hud.detailsLabelText = @"网络错误";
            }
            [_hud hide:YES afterDelay:1];
        }];
}
#pragma clang diagnostic pop

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)render
{
    NSURL *baseUrl = [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath];
	BOOL lineNumbers = YES;//[[defaults valueForKey:kLineNumbersDefaultsKey] boolValue];
    NSString *lang = [[_fileName componentsSeparatedByString:@"."] lastObject];
	NSString *theme = @"github";//@"tomorrow-night";//[defaults valueForKey:kThemeDefaultsKey];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *codeCssPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"css"];
	NSString *lineNums = lineNumbers ? @"true" : @"false";
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *escapedCode = [self escapeHTML:_content];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, codeCssPath, highlightJsPath, lineNums, lang, escapedCode];
    
	[self.webView loadHTMLString:contentHTML baseURL:baseUrl];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view hideToastActivity];
}

- (NSString *)escapeHTML:(NSString *)originalHTML
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:originalHTML];
    [result replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"'"  withString:@"&#39;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    return result;
}

#pragma mark - headerView
- (UIView* )headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){{0,64},{self.view.bounds.size.width,44}}];
        _headerView.backgroundColor = [UIColor colorWithHex:0xF9F9F9];

        UIImageView* imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"ic_file"];
        [_headerView addSubview:imageView];
        imageView.frame = (CGRect){{12,12},{20,20}};
        
        UILabel* label = [UILabel new];
        label.font = [UIFont systemFontOfSize:16];
        label.text = self.fileName;
        [_headerView addSubview:label];
        label.frame = (CGRect){{44,0},{self.view.bounds.size.width - 50,44}};

    }
    return _headerView;
}

@end



@implementation UIView (HideToastActivity)
static const NSString * CSToastActivityViewKey  = @"CSToastActivityViewKey";
- (void)hideToastActivity {
    UIView *existingActivityView = (UIView *)objc_getAssociatedObject(self, &CSToastActivityViewKey);
    if (existingActivityView != nil) {
        [UIView animateWithDuration:0.2
                              delay:0.0
                            options:(UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             existingActivityView.alpha = 0.0;
                         } completion:^(BOOL finished) {
                             [existingActivityView removeFromSuperview];
                             objc_setAssociatedObject (self, &CSToastActivityViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                         }];
    }
}
@end


