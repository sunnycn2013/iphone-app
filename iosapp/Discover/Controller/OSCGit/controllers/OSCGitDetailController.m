//
//  OSCGitDetailController.m
//  iosapp
//
//  Created by 王恒 on 17/3/3.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCGitDetailController.h"
#import "OSCModelHandler.h"
#import "OSCAPI.h"
#import "OSCGitDetailModel.h"
#import "OSCGitDetailHeader.h"
#import "IMYWebView.h"
#import "OSCPhotoGroupView.h"
#import "OSCGitDetailFooter.h"
#import "Utils.h"
#import "OSCShareManager.h"
#import "OSCBranchListController.h"
#import "OSCGitCommentViewController.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "UIColor+Util.h"
#import "UINavigationController+Comment.h"

#import <MBProgressHUD/MBProgressHUD.h>

#define kBottomBarHeight 44

@interface OSCGitDetailController ()<UITableViewDelegate,UITableViewDataSource,OSCGitFooterViewDelegate,OSCGitDetailHeaderDelegate>

{
    UIButton *_commentBtn;
    UITableView *_tableView;
    MBProgressHUD *_waitHud;
}

@property (nonatomic,assign) NSInteger projectID;
@property (nonatomic,strong) NSString *requestURL;
@property (nonatomic,strong) OSCGitDetailModel *detailModel;
@property (nonatomic,strong) OSCGitDetailHeader *tableViewHeader;
@property (nonatomic,strong) OSCGitDetailFooter *tableViewFooter;

@end

@implementation OSCGitDetailController

- (instancetype)initWithProjectID:(NSInteger)projectID{
    self = [super init];
    if (self) {
        _projectID = projectID;
        _requestURL = [NSString stringWithFormat:@"%@projects/%ld/osc",OSCAPI_GIT_PREFIX,projectID];
    }
    return self;
}

- (instancetype)initWithProjectNameSpace:(NSString *)pathWithNameSpace{
    self = [super init];
    if (self) {
        _requestURL = [NSString stringWithFormat:@"%@projects/%@/osc",OSCAPI_GIT_PREFIX,pathWithNameSpace];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configSelf];
    [self addContentView];
    if (_projectID != 0) {
        [self getCommentCountWithSouceID:_projectID];
    }
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configSelf{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)addContentView{
    [self addBottomBar];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64 - kBottomBarHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(0, 0, kScreenSize.width, 60);
    [activityView startAnimating];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 1)];
    lineView.backgroundColor = [UIColor separatorColor];
    [activityView addSubview:lineView];
    _tableView.tableFooterView = activityView;
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
    [_commentBtn addTarget:self action:@selector(gitCommentVC) forControlEvents:UIControlEventTouchUpInside];
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

- (void)updateCommentBtnWithNumber:(NSInteger)number{
    [_commentBtn setTitle:[NSString stringWithFormat:@"评论（%ld）",number] forState:UIControlStateNormal];
}

- (void)getData{
    _waitHud = [self getHUDWithView:self.view withString:@"" withMBPMode:MBProgressHUDModeIndeterminate];
    [self.view addSubview:_waitHud];
    
    __weak typeof(self) weakSelf = self;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:_requestURL parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            _detailModel = [OSCGitDetailModel osc_modelWithJSON:responseObject[@"result"]];
            if (_projectID == 0) {
                [self getCommentCountWithSouceID:_detailModel.id];
            }
            _tableViewHeader = [[OSCGitDetailHeader alloc] initWithModel:_detailModel];
            _tableViewHeader.delegate = self;
            
            NSDictionary *data = @{@"content":  _detailModel.readme?:@""};
            _detailModel.readme = [Utils HTMLWithData:data
                                     usingTemplate:@"git_project"];
            _tableViewFooter = [[OSCGitDetailFooter alloc] initWithHTMLString:_detailModel.readme];
            _tableViewFooter.delegate = self;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_waitHud hideAnimated:YES];
                [weakSelf reloadTableView];
                [self.view addSubview:_tableView];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [weakSelf getHUDWithView:self.view withString:@"网络连接失败" withMBPMode:MBProgressHUDModeText];
                [hud hideAnimated:YES afterDelay:2.0];
                [weakSelf.view addSubview:hud];
            });
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_waitHud hideAnimated:YES];
            MBProgressHUD *hud = [weakSelf getHUDWithView:self.view withString:@"网络连接失败" withMBPMode:MBProgressHUDModeText];
            [hud hideAnimated:YES afterDelay:2.0];
            [weakSelf.view addSubview:hud];
        });
    }];
}

- (void)getCommentCountWithSouceID:(NSInteger)souceID{
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager GET:[NSString stringWithFormat:@"%@git_comments_count",OSCAPI_V2_PREFIX] parameters:@{@"projectId":@(souceID)} success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            NSInteger commentCount = [responseObject[@"result"][@"commentCount"] integerValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf reloadCommentBtnWithInteger:commentCount];
            });
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_waitHud hideAnimated:YES];
            MBProgressHUD *hud = [weakSelf getHUDWithView:self.view withString:@"获取评论数失败" withMBPMode:MBProgressHUDModeText];
            [hud hideAnimated:YES afterDelay:2.0];
            [weakSelf.view addSubview:hud];
        });
    }];
}

- (MBProgressHUD *)getHUDWithView:(__kindof UIView *)view
                       withString:(NSString *)string withMBPMode:(MBProgressHUDMode)MBPMode{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
    hud.mode = MBPMode;
    hud.label.text = string;
    [hud showAnimated:YES];
    hud.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

- (void)reloadTableView{
    _tableView.tableHeaderView = _tableViewHeader;
}

- (void)share{
    [[OSCShareManager shareManager] showShareBoardWithGitModel:_detailModel];
}

- (void)gitCommentVC{
    OSCGitCommentViewController *gitCommentVC = [[OSCGitCommentViewController alloc] initGitCommentVCWithSourceID:_detailModel.id WithName:_detailModel.name WithNameSpace:_detailModel.path_with_namespace];
    [self.navigationController pushViewController:gitCommentVC animated:YES];
}

- (void)reloadCommentBtnWithInteger:(NSInteger)commentCount{
    [_commentBtn setTitle:[NSString stringWithFormat:@" 评论（%ld）",commentCount] forState:UIControlStateNormal];
}

#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 32;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake( 0, 0, kScreenSize.width, 32)];
    label.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"     README";
    label.textColor = [UIColor colorWithHex:0x6A6A6A];
    return label;
}

#pragma mark --- OSCInformationHeaderViewDelegate
- (BOOL)contentView:(IMYWebView *)webView
        shouldStart:(NSURLRequest *)request{
    if ([request.URL.absoluteString hasPrefix:@"file"]) {return YES;}
    
    NSString* absoluteUrl = [[request URL]absoluteString];
    if ([absoluteUrl rangeOfString:@"jpg"].location  != NSNotFound ||
        [absoluteUrl rangeOfString:@"png"].location  != NSNotFound ||
        [absoluteUrl rangeOfString:@"jepg"].location != NSNotFound ||
        [absoluteUrl rangeOfString:@"gif"].location  != NSNotFound)
    {
        OSCPhotoGroupItem* item = [OSCPhotoGroupItem new];
        item.largeImageURL = [NSURL URLWithString:absoluteUrl];
        
        OSCPhotoGroupView* groupView = [[OSCPhotoGroupView alloc] initWithGroupItems:@[item]];
        UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
        
        [groupView presentFromImageView:nil toContainer:currentWindow animated:NO completion:nil];
        return NO;
    }
    
    [self.navigationController handleURL:request.URL name:nil];
    return [request.URL.absoluteString isEqualToString:@"about:blank"];
}

-(void)contentViewDidFinishLoadWithHederViewHeight:(float)height{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        _tableView.tableFooterView = _tableViewFooter;
    });
}

#pragma mark - 查看源代码
- (void)codeClickWithModel:(OSCGitDetailModel *)detailModel{
    OSCBranchListController *branchListVC = [[OSCBranchListController alloc] initWithPath:nil refName:detailModel.default_branch projectId:detailModel.id];
    branchListVC.detailModel = _detailModel;
    [self.navigationController pushViewController:branchListVC animated:YES];
}

@end
