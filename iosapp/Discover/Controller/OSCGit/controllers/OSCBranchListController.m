//
//  OSCBranchListController.m
//  iosapp
//
//  Created by Graphic-one on 17/3/13.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCBranchListController.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "FileContentView.h"
#import "OSCBranchListModel.h"
#import "OSCBranhListCell.h"
#import "OSCModelHandler.h"
#import "OSCBranchView.h"

#import <Masonry.h>
#import <MBProgressHUD.h>

#import "UIColor+Util.h"

@interface OSCBranchListController () <UITableViewDataSource,UITableViewDelegate,OSCBranchViewDelegate>
@property (nonatomic,strong) NSString* url;
@property (nonatomic,assign) NSUInteger projectID;
@property (nonatomic,strong) NSDictionary* paraDic;
@property (nonatomic,strong) NSArray* dataSource;

@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) UIView* headerView;
@property (nonatomic,strong) UITableView* tableView;

@property (nonatomic,strong) NSArray* branchs;
@property (nonatomic,strong) OSCBranchView* branchView;
@end

@implementation OSCBranchListController

- (instancetype)initWithPath:(NSString* )path
                     refName:(NSString* )refName
                   projectId:(NSUInteger)id
{
    self = [super init];
    if(self){
        _projectID = id;
        _url = [NSString stringWithFormat:@"http://git.oschina.net/api/v3/projects/%lu/repository/tree",(unsigned long)id];
        _paraDic = @{
                     @"path"    : path.length > 0 ? path : @"/",
                     @"ref_name": refName,
                     };
        _dataSource = @[];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回详情" style:UIBarButtonItemStylePlain target:self action:@selector(backToDetail)];
    
    [self.view addSubview:({
        UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 56;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerNib:[UINib nibWithNibName:@"OSCBranhListCell" bundle:nil] forCellReuseIdentifier:@"OSCBranhListCellResueIdentifier"];
        _tableView;
    })];
    _tableView.hidden = YES;
    
    [self _sendRequest];
    [self _getAllBranchs];
}

#pragma mark - 
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void)_sendRequest{
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger GET:_url
     parameters:_paraDic
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [_hud hide:YES afterDelay:1];
            NSArray* codeFiles = responseObject;
            _dataSource = [NSArray osc_modelArrayWithClass:[OSCBranchListModel class] json:codeFiles];
            if (_dataSource && _dataSource != (id)kCFNull) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _tableView.hidden = NO;
                    [self updateHeaderView];
                    [_tableView reloadData];
                });
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

- (void)_getAllBranchs{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger GET:[NSString stringWithFormat:@"https://git.oschina.net/api/v3/projects/%lu/repository/branches",(unsigned long)self.projectID]
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSArray* arr = (NSArray* )responseObject;
                NSMutableArray* mArr = [NSMutableArray arrayWithCapacity:arr.count];
                for (NSDictionary* dic in arr) {
                    NSString* branchName = dic[@"name"];
                    [mArr addObject:branchName];
                }
                self.branchs = mArr.copy;
            }else if ([responseObject isKindOfClass:[NSDictionary class]]){
                NSDictionary* dic = (NSDictionary* )responseObject;
                NSString* branchName = dic[@"name"];
                self.branchs = @[branchName];
            }
            
            if (self.branchs) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.branchView = [OSCBranchView BranchViewWithDataSource:self.branchs];
                    self.branchView.frame = (CGRect){{0,44 + 64},{self.view.bounds.size.width,self.view.bounds.size.height - 44 - 64}};
                    self.branchView.delegate = self;
                    self.branchView.hidden = YES;
                    [self.view addSubview:self.branchView];
                });
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            
        }];
}

#pragma mark - 
- (void)branchView:(OSCBranchView *)OSCBranchView didSelectedIndex:(NSUInteger)index{
    NSString* branch = self.branchs[index];
    if (branch && branch != (id)kCFNull) {
        NSMutableDictionary* mDic = _paraDic.mutableCopy;
        mDic[@"ref_name"] = branch;
        _paraDic = mDic.copy;
        self.branchView.alpha = 0.99;
        [UIView animateWithDuration:0.3 animations:^{
            self.branchView.alpha = 0.3;
            self.branchView.transform = CGAffineTransformMakeTranslation(0.0, self.branchView.bounds.size.height);
        } completion:^(BOOL finished) {
            self.branchView.hidden = YES;
            [self _sendRequest];
        }];
    }
}

#pragma mark - 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataSource.count) {
        return self.dataSource.count;
    }else{
        return 0;
    }
}

- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.dataSource.count) {
        OSCBranhListCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OSCBranhListCellResueIdentifier" forIndexPath:indexPath];
        cell.model = self.dataSource[indexPath.row];
        return cell;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // push to C ...
    
    OSCBranchListModel* model = self.dataSource[indexPath.row];
    NSString *path = @"";
    if ([self.paraDic[@"path"] isEqualToString:@"/"]) {
        path = model.name;
    }else{
        path = [NSString stringWithFormat:@"%@/%@",self.paraDic[@"path"],model.name];
    }
    if ([model.type isEqualToString:@"tree"]) {//wenjianjia
        OSCBranchListController* banrhList = [[OSCBranchListController alloc] initWithPath:path refName:self.paraDic[@"ref_name"] projectId:_projectID];
        banrhList.detailModel = _detailModel;
        [self.navigationController pushViewController:banrhList animated:YES];
    }else if ([model.type isEqualToString:@"blob"]){//wenjian
        FileContentView* fileController = [[FileContentView alloc] initWithProjectID:self.projectID filePath:path  ref:self.paraDic[@"ref_name"]];
        fileController.detailModel = _detailModel;
        [self.navigationController pushViewController:fileController animated:YES];
    }
}

- (UIView* )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (void)updateHeaderView{
    UILabel* label = (UILabel* )[self.headerView viewWithTag:1002];
    
    label.text = [NSString stringWithFormat:@"分支：%@",self.paraDic[@"ref_name"]];
}

#pragma mark - 
- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,44}}];
        _headerView.backgroundColor = [UIColor colorWithHex:0xF9F9F9];
        
        UIImageView* imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:@"ic_branch"];
        imageView.tag = 1001;
        imageView.contentMode = UIViewContentModeCenter;
        [_headerView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.equalTo(@20);
            make.centerY.equalTo(_headerView).offset(0);
            make.left.equalTo(_headerView).offset(12);
        }];

        UILabel* label = [UILabel new];
        label.font = [UIFont systemFontOfSize:15];
        label.backgroundColor = [UIColor clearColor];
        label.text = @"";
        label.tag = 1002;
        [_headerView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_headerView).offset(0);
            make.height.equalTo(@20);
            make.left.equalTo(imageView.mas_right).offset(12);
        }];
        
        UIImageView* downTip = [UIImageView new];
        downTip.image = [UIImage imageNamed:@"ic_arrow_right"];
        downTip.transform = CGAffineTransformMakeRotation(M_PI/2);
        [_headerView addSubview:downTip];
        [downTip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(7));
            make.centerY.equalTo(_headerView);
            make.right.equalTo(_headerView).offset(-16);
            make.height.equalTo(@(14));
        }];
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = _headerView.bounds;
        btn.backgroundColor = [UIColor clearColor];
        [btn addTarget:self action:@selector(_popBranchsView:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:btn];
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerView.bounds) - 0.5, kScreenSize.width, 0.5)];
        lineView.backgroundColor = [UIColor separatorColor];
        [btn addSubview:lineView];
    }
    return _headerView;
}

- (void)_popBranchsView:(UIButton* )btn{
    if (!self.branchView){
        _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
        _hud.detailsLabelText = @"没有更多分支";
        [_hud hideAnimated:YES afterDelay:1.0];
        return ;
    }
    
    btn.enabled = NO;
    if (self.branchView.hidden) { // pop
        self.branchView.hidden = NO;
        self.branchView.transform = CGAffineTransformMakeTranslation(0.0, -self.branchView.bounds.size.height);
        self.branchView.alpha = 0.3;
        [UIView animateWithDuration:0.3 animations:^{
            self.branchView.transform = CGAffineTransformIdentity;
            self.branchView.alpha = 0.99;
        } completion:^(BOOL finished) {
            btn.enabled = YES;
        }];
    }else{ // back
        self.branchView.transform = CGAffineTransformIdentity;
        self.branchView.alpha = 0.99;
        [UIView animateWithDuration:0.3 animations:^{
            self.branchView.alpha = 0.3;
            self.branchView.transform = CGAffineTransformMakeTranslation(0.0, -self.branchView.bounds.size.height);
        } completion:^(BOOL finished) {
            self.branchView.hidden = YES;
            btn.enabled = YES;
        }];
    }
}

- (void)backToDetail{
    [self.navigationController popToViewController:self.navigationController.viewControllers[2] animated:YES];
}

@end







