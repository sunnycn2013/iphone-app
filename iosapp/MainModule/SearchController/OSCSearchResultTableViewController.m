//
//  OSCSearchResultTableViewController.m
//  iosapp
//
//  Created by 王恒 on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCSearchResultTableViewController.h"

#import "OSCAPI.h"
#import "OSCSearchItem.h"
#import "OSCModelHandler.h"
#import "OSCResultTableViewCell.h"

#import "OSCPushTypeControllerHelper.h"
#import "UINavigationController+Comment.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "UIView+Common.h"
#import "NSObject+Comment.h"

#import <MJRefresh.h>
#import <AFNetworking.h>

@interface OSCSearchResultTableViewController () <UIScrollViewDelegate>

@property (nonatomic,assign)TableViewType tableViewType;
@property (nonatomic,strong,readwrite)NSArray *requestType;
@property (nonatomic,strong)NSString *nextPageToken;
@property (nonatomic,strong)NSString *prevPageToken;
@property (nonatomic,strong)NSMutableArray *dataArray;

@property (nonatomic,strong) UIView* cacheTipHeaderView;

@property (nonatomic,assign)BOOL isNeedRefresh;
@end

@implementation OSCSearchResultTableViewController
{
    NSString* _requestUrl ;
    NSDictionary* _parameter;
    
    BOOL _isFromCache;
}

-(instancetype)initWithStyle:(UITableViewStyle)style withType:(TableViewType)type{
    self = [super initWithStyle:style];
    if(self){
        _requestType = @[@(1),@(3),@(6),@(2),@(11)];
        self.tableViewType = type;

        _requestUrl = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_SEARCH];
        _parameter = @{
                       @"catalog" : _requestType[type],
                      };
        self.tableView.tableFooterView = [[UIView alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addContentView];
}


- (void)dealloc{
    [self.tableView configReloadAction:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addContentView{
    __weak typeof(self) weakSelf = self;
    [weakSelf.tableView configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf getDataWithisRefresh:YES];
    }];
}

-(void)setKeyWord:(NSString *)keyWord{
    if (![_keyWord isEqualToString:keyWord]) {
        _isNeedRefresh = YES;
    }
    _keyWord = keyWord;
    [self.tableView hideBlankPageView];
}

#pragma mark 数据处理
- (void)assemblyCacheDataSource:(NSDictionary* )cacheResponse
{
    _isFromCache = YES;
    
    _nextPageToken = cacheResponse[@"nextPageToken"];
    _prevPageToken = cacheResponse[@"prevPageToken"];
    
    if (self.tableViewType == TableViewTypePerson) {
        _dataArray = [[NSArray modelArrayWithClass:[OSCSearchPeopleItem class]
                                              json:cacheResponse[@"items"]] mutableCopy];
    }else{
        _dataArray = [[NSArray modelArrayWithClass:[OSCSearchItem class]
                                              json:cacheResponse[@"items"]] mutableCopy];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_dataArray && _dataArray.count > 0) {
            self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                [self getDataWithisRefresh:NO];
            }];
        }else{
            self.tableView.mj_footer = nil;
        }
        
        if(_dataArray.count == 0){
            [self.tableView showBlankPageView];
            self.tableView.bounces = NO;
        }else{
            [self.tableView hideBlankPageView];
            self.tableView.bounces = YES;
        }
        [self.tableView reloadData];
        if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
            [_resultDelegate resultVCCompleteRequest];
        }
    });
    
}

-(void)getDataWithisRefresh:(BOOL)isRefresh{
    if (isRefresh) {
        _isNeedRefresh = NO;
    }
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    if(_keyWord.length >= 5){
        manager.requestSerializer.timeoutInterval = 5.0f;
    }else{
        manager.requestSerializer.timeoutInterval = 10.0f;
    }
    if ([_resultDelegate respondsToSelector:@selector(resultVCBeginRequest)]) {
        [_resultDelegate resultVCBeginRequest];
    }
    if (isRefresh) {
        [self.tableView hideAllGeneralPage];
        
        NSMutableDictionary* parameterMutable = [_parameter mutableCopy];
        [parameterMutable setObject:_keyWord forKey:@"content"];
        
        [manager GET:_requestUrl
          parameters:parameterMutable.copy
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                if ([responseObject[@"code"] integerValue] == 1) {
                    NSDictionary *result = responseObject[@"result"];
                    
                    if (result && result.count > 0) {
                        _nextPageToken = result[@"nextPageToken"];
                        _prevPageToken = result[@"prevPageToken"];
                        if (self.tableViewType == TableViewTypePerson) {
                            _dataArray = [[NSArray modelArrayWithClass:[OSCSearchPeopleItem class] json:result[@"items"]] mutableCopy];
                        }else{
                            _dataArray = [[NSArray modelArrayWithClass:[OSCSearchItem class] json:result[@"items"]] mutableCopy];
                        }
                        
                        /** cache handle */
                        NSString* resourceName = [NSObject cacheResourceNameWithURL:_requestUrl parameterDictionaryDesc:parameterMutable.description];
                        [NSObject handleResponseObject:result resource:resourceName cacheType:SandboxCacheType_other];
                        /** cache handle */
                        
                    } else {
                        _dataArray = [NSMutableArray array];
                    }
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([responseObject[@"code"] integerValue] == 1 && ([responseObject[@"result"][@"requestCount"] intValue] <= [responseObject[@"result"][@"responseCount"] intValue])) {
                        self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                            [self getDataWithisRefresh:NO];
                        }];
                    }else{
                        self.tableView.mj_footer = nil;
                    }
                    _isFromCache = NO;
                    
                    if(_dataArray.count == 0){
                        [self.tableView showBlankPageView];
                        self.tableView.bounces = NO;
                    }else{
                        [self.tableView hideBlankPageView];
                        self.tableView.bounces = YES;
                    }
                    [self.tableView reloadData];
                    if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                        [_resultDelegate resultVCCompleteRequest];
                    }
                });
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"网络异常");
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!_dataArray || _dataArray.count == 0) {
                    [self.tableView showErrorPageView];
                }
                if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                    [_resultDelegate resultVCCompleteRequest];
                }
            });
        }];
    }else{
        NSString *urlString = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX, OSCAPI_SEARCH];
        
        NSDictionary *parameters = @{
                                     @"catalog"   : _requestType[_tableViewType],
                                     @"content"   : _keyWord,
                                     @"pageToken" : _nextPageToken,
                                     };
        
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        [manager GET:urlString
          parameters:parameters
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                if ([responseObject[@"code"] integerValue] == 1) {
                    NSDictionary *result = responseObject[@"result"];
                    
                    if (result && result.count > 0) {
                        _nextPageToken = result[@"nextPageToken"];
                        _prevPageToken = result[@"prevPageToken"];
                        NSArray *items;
                        if(self.tableViewType == TableViewTypePerson){
                            items = [NSArray modelArrayWithClass:[OSCSearchPeopleItem class] json:result[@"items"]];
                        } else {
                            items = [NSArray modelArrayWithClass:[OSCSearchItem class] json:result[@"items"]];
                        }
                        
                        if (items && items.count > 0) {
                            for (id item in items) {
                                [_dataArray addObject:item];
                            }
                            
                            if ([result[@"requestCount"] intValue] > [result[@"responseCount"] intValue]) {
                                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                            } else {
                                [self.tableView.mj_footer endRefreshing];
                            }
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _isFromCache = NO;
                                [self.tableView reloadData];
                                if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                                    [_resultDelegate resultVCCompleteRequest];
                                }
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView.mj_footer endRefreshingWithNoMoreData];
                                if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                                    [_resultDelegate resultVCCompleteRequest];
                                }
                            });
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
                            if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                                [_resultDelegate resultVCCompleteRequest];
                            }
                        });
                    }
                    
                }
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"网络异常");
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_resultDelegate respondsToSelector:@selector(resultVCCompleteRequest)]) {
                    [_resultDelegate resultVCCompleteRequest];
                }
            });
        }];
    }
}

#pragma 方法实现
-(void)controllerChanged{
    if (self.keyWord != nil && self.tableView.blankPageView == nil && _isNeedRefresh && self.keyWord.length != 0) {
        [self.tableView reloadData];
        [self getDataWithisRefresh:YES];
    }
}

- (UITableViewCell *)createCellWithSearchResult:(id)result withCellID:(NSString *)cellID{
    if(self.tableViewType == TableViewTypePerson){
        OSCResultPersonCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell){
            cell = [[[NSBundle mainBundle]loadNibNamed:@"OSCResultPersonCell" owner:nil options:nil] lastObject];
        }
        cell.model = result;
        return cell;
    }else{
        OSCSearchItem *model = result;
        OSCResultCoustomCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[OSCResultCoustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.title = model.title;
        if ([model.body isEqualToString:@""]) {
            cell.content = [NSString stringWithFormat:@"%@  发布于%@",model.title,model.pubDate];
        }else{
            cell.content = model.body;
        }
        return cell;
    }
}

#pragma mark - TableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [self createCellWithSearchResult:_dataArray[indexPath.row] withCellID:cellID];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

#pragma --mark TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *vc = [OSCPushTypeControllerHelper pushControllerWithSearchItem:_dataArray[indexPath.row]];
    if ([_resultDelegate respondsToSelector:@selector(resultClickCellWithContoller:withHref:)]) {
        if (self.tableViewType == TableViewTypePerson) {
            [_resultDelegate resultClickCellWithContoller:vc withHref:nil];
        }else{
            OSCSearchItem *model = _dataArray[indexPath.row];
            [_resultDelegate resultClickCellWithContoller:vc withHref:model.href];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (self.tableViewType == TableViewTypePerson) ? 95 : 83;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_isFromCache) {
        return 24;
    }else{
        return 0;
    }}

- (UIView* )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_isFromCache) {
        return self.cacheTipHeaderView;
    }else{
        return nil;
    }
}

#pragma --mark ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([_resultDelegate respondsToSelector:@selector(resultTableViewDidScroll)]){
        [_resultDelegate resultTableViewDidScroll];
    }
}

#pragma mark --- cacheData Tip headerView
- (UIView *)cacheTipHeaderView{
    if (_cacheTipHeaderView == nil) {
        _cacheTipHeaderView = [[UIView alloc] initWithFrame:(CGRect){{0,0},{self.view.bounds.size.width,20}}];
        _cacheTipHeaderView.backgroundColor = [UIColor whiteColor];
        [_cacheTipHeaderView addSubview:({
            UILabel* tipLabel = [[UILabel alloc] initWithFrame:(CGRect){{10,4},{self.view.bounds.size.width - 3,16}}];
            tipLabel.text = @"- 以下搜索结果读取于本地 -";
            tipLabel.font = [UIFont systemFontOfSize:14];
            tipLabel.backgroundColor = [UIColor clearColor];
            tipLabel.textColor = [UIColor grayColor];
            tipLabel;
        })];
    }
    return _cacheTipHeaderView;
}

@end
