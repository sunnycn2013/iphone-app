//
//  OSCCodeSnippetDetailController.m
//  iosapp
//
//  Created by wupei on 2017/5/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCCodeSnippetDetailController.h"
#import "OSCModelHandler.h"
#import "OSCAPI.h"
#import "OSCGitDetailModel.h"
#import "OSCGitDetailHeader.h"
#import "IMYWebView.h"
#import "OSCPhotoGroupView.h"
#import "OSCGitDetailFooter.h"
#import "Utils.h"
#import "Config.h"
#import "OSCShareManager.h"
#import "OSCBranchListController.h"
#import "OSCGitCommentViewController.h"
#import "OSCCodeCommentViewController.h"
#import "NewLoginViewController.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIColor+Util.h"
#import "UINavigationController+Comment.h"
#import "GLBlob.h"
#import "OSCCodeDetailHeadView.h"
#import <Masonry.h>

#import <MBProgressHUD/MBProgressHUD.h>

#define kBottomBarHeight 44
#define kHeadViewHeigth 86
@interface UIView (HideToastActivity)
- (void)hideToastActivity ;
@end

@interface OSCCodeSnippetDetailController ()<UIWebViewDelegate>
{
    UIButton *_commentBtn;
    UITableView *_tableView;
    MBProgressHUD *_waitHud;
}

@property (nonatomic, strong) OSCCodeDetailHeadView *headerView;


@property (nonatomic, strong) UIButton *rightBarBtn;

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *commentUrl;
@property (nonatomic, strong) NSDictionary *paraDic;
@property (nonatomic, strong) OSCCodeSnippetListModel *model;

@end

@implementation OSCCodeSnippetDetailController

- (instancetype)initWithContentIdStr:(NSString *)idStr {
    self = [super init];
    if (self) {
        self.idStr = idStr;
        _url = [NSString stringWithFormat:@"%@%@%@",OSCAPI_GIT_PREFIX,OSCAPI_GISTS,idStr];
        _commentUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_GISTS_COMMENTS_COUNT];
    }
    return  self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self fetchFileContent];
    [self getCommentCount];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelf];
    [self addContentView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)orientChange:(NSNotification *)noti {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation)
    {
        case UIDeviceOrientationPortrait: {
            [UIView animateWithDuration:0.25 animations:^{
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                [UIApplication sharedApplication].statusBarHidden = NO;
                self.webView.transform = CGAffineTransformMakeRotation(0);
                self.webView.frame = CGRectMake(0, 64 + self.headerView.height, kScreenSize.width, kScreenSize.height - 44 - 64 - self.headerView.height);
               
            }];
        }
            break;
        case UIDeviceOrientationLandscapeLeft: {
            [UIView animateWithDuration:0.25 animations:^{
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                [UIApplication sharedApplication].statusBarHidden = YES;
                self.webView.transform = CGAffineTransformMakeRotation(M_PI*0.5);
                self.webView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height);
            }];
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            [UIView animateWithDuration:0.25 animations:^{
                [self.navigationController setNavigationBarHidden:YES animated:YES];
                [UIApplication sharedApplication].statusBarHidden = YES;
                self.webView.transform = CGAffineTransformMakeRotation(-M_PI*0.5);
                self.webView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height);
            }];
        }
            break;
        default:
            break;
    }
}

- (void)configSelf{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addContentView {
    [self addBottomBar];
    _rightBarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBarBtn.userInteractionEnabled = YES;
    [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_fav_light_normall"] forState:UIControlStateNormal];
//    [_rightBarBtn setImage:[UIImage imageNamed:@"ic_faved_pressed"] forState:UIControlStateNormal];
    _rightBarBtn.frame = CGRectMake(0, 0, 19, 20);
    [_rightBarBtn addTarget:self action:@selector(favClick) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBarBtn];
}

- (void)changCellected {
    
}

#pragma mark - 更新收藏状态   需要有返回是否收藏的字段。
- (void)updateFavButtonWithIsCollected:(BOOL)isCollected
{
    if (isCollected) {
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_fav_normal"] forState:UIControlStateNormal];
    }else {
        [_rightBarBtn setBackgroundImage:[UIImage imageNamed:@"ic_fav_pressed"] forState:UIControlStateNormal];
    }
}

#pragma mark - 收藏
- (void)favClick{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        
    } else {
        
#warning 接口
        
        NSDictionary *parameterDic =@{@"id"     : @"_informationID",//@(_informationID),
                                      @"type"   : @(6)};
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        
        [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_FAVORITE_REVERSE]
          parameters:parameterDic
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 
                 BOOL isCollected = NO;
                 if ([responseObject[@"code"] integerValue]== 1) {
                     isCollected = [responseObject[@"result"][@"favorite"] boolValue];
                 }
                 
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = isCollected? @"收藏成功": @"取消收藏";
                 [HUD hideAnimated:YES afterDelay:1];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self updateFavButtonWithIsCollected:isCollected];
                 });
             }
             failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，操作失败";
                 [HUD hideAnimated:YES afterDelay:1];
             }];
    }
}

- (void)addBottomBar{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenSize.height - kBottomBarHeight, kScreenSize.width, kBottomBarHeight)];
    bottomView.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
    lineView.backgroundColor = [UIColor separatorColor];
    [bottomView addSubview:lineView];
    
    _commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentBtn.frame = CGRectMake(0, 0, kScreenSize.width / 2, kBottomBarHeight);
    [_commentBtn setImage:[UIImage imageNamed:@"ic_comment_40"] forState:UIControlStateNormal];
    [_commentBtn setTitle:@" 评论（0）" forState:UIControlStateNormal];
    [_commentBtn setTitleColor:[UIColor colorWithHex:0x9D9D9D] forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [_commentBtn addTarget:self action:@selector(CodeSnippetCommentVC) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:_commentBtn];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shareBtn.frame = CGRectMake(CGRectGetMaxX(_commentBtn.frame), 0, kScreenSize.width / 2, kBottomBarHeight);
    [shareBtn setImage:[UIImage imageNamed:@"ic_share_black_normal"] forState:UIControlStateNormal];
    [shareBtn setTitle:@" 分享" forState:UIControlStateNormal];
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [shareBtn setTitleColor:[UIColor colorWithHex:0x9D9D9D] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:shareBtn];
    
    [self.view addSubview:bottomView];
}

- (void)addHeaderViewAndWeb {
    
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.opaque = NO;
    self.webView.scalesPageToFit=YES;
    self.webView.multipleTouchEnabled=YES;
    self.webView.userInteractionEnabled=YES;
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), kScreenWidth + 10, kScreenHeight - CGRectGetMaxY(self.headerView.frame) - 44);
    
    [self.view addSubview:self.webView];
    
}


/** 跳转到代码片段评论界面 */
- (void)CodeSnippetCommentVC{
    OSCCodeCommentViewController *codeVc = [[OSCCodeCommentViewController alloc] initCodeCommentVCWithGistId:self.idStr WithName:_model.name WithUrl:_model.url];
    [self.navigationController pushViewController:codeVc animated:YES];

}

- (void)share{
    [[OSCShareManager shareManager] showShareBoardWithCodeModel:self.model];
}

#pragma mark - 获取文件数据

#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)fetchFileContent
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger GET:_url
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [_hud hide:YES afterDelay:1];
            
            
            if (responseObject == nil) {
            
            } else {
                
                _content = [[GLBlob alloc] initWithJSON:responseObject].content;
                _model = [OSCCodeSnippetListModel osc_modelWithJSON:responseObject];
                
                self.headerView = [[OSCCodeDetailHeadView alloc] initWithModel:_model];
                self.headerView.backgroundColor = [UIColor colorWithHex:0xF8F8F8];

                [self.view addSubview:self.headerView];
                
                [self addHeaderViewAndWeb];
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

- (void)getCommentCount {

    NSDictionary *dic = @{@"gistId":self.idStr};
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:_commentUrl
      parameters:dic
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        if ([responseObject[@"code"] integerValue] == 1) {
            
            NSInteger commentCount = [responseObject[@"result"][@"commentCount"] integerValue];

            dispatch_async(dispatch_get_main_queue(), ^{
            
                  [_commentBtn setTitle:[NSString stringWithFormat:@" 评论（%ld）",commentCount] forState:UIControlStateNormal];
 
            });
    
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
    }];
    
}


#pragma clang diagnostic pop

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma -- UIWebViewDelegate
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

