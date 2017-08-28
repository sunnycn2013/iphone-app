//
//  OSCActivityUserController.m
//  iosapp
//
//  Created by 王恒 on 17/4/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCActivityUserController.h"
#import "ActivityDetailViewController.h"
#import "OSCModelHandler.h"
#import "OSCActivityCell.h"
#import "OSCAPI.h"
#import "OSCActivities.h"
#import "OSCActivityUserHeader.h"
#import "OSCActivityUserQRController.h"
#import "OSCCompeleteSignController.h"
#import "Utils.h"
#import "OSCListItem.h"

#import "UIView+Common.h"
#import "UIColor+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <MBProgressHUD.h>

#define kButtonHeight 44
#define kButtonFontSize 16

//测试Git 流程

@interface OSCActivityUserController ()<UITableViewDataSource,UITableViewDelegate>

{
    ActivityUserType _type;
    NSInteger _activityID;
    UITableView *_tableView;
    NSArray *_keyArray;
    NSArray *_infoArray;
    NSDictionary *_resultDic;
    CGFloat _remarkHeight;
    MBProgressHUD *_hud;
    NSString *_activityName;
}

@property (nonatomic, assign) ActivityType activityType ;//活动类型
@property (nonatomic, assign) BOOL isQR;//是否是二维码进入的
@property (nonatomic, strong) UIButton *invitationBtn;//邀请按钮
@property (nonatomic, strong) UIButton *cancleBtn;
@property (nonatomic, strong) UIView *lineView;
@end

@implementation OSCActivityUserController

- (instancetype)initWithType:(ActivityUserType)type withActivityID:(NSInteger)activityID activityType:(NSInteger)activityType{
    self = [super init];
    if (self) {
        _type = type;
        _activityID = activityID;
        _keyArray = @[@"姓名",@"职位",@"报名时间",@"手机号码",@"公司",@"状态"];
        _infoArray = @[@"姓名",@"职位",@"报名时间",@"手机",@"公司",@"报名状态"];
    }
    return self;
}

- (instancetype)initWithType:(ActivityUserType)type withActivityID:(NSInteger)activityID isQR:(BOOL)isQR {
    self = [super init];
    if (self) {
        _isQR = isQR;
        _type = type;
        _activityID = activityID;
        _keyArray = @[@"姓名",@"职位",@"报名时间",@"手机号码",@"公司",@"状态"];
        _infoArray = @[@"姓名",@"职位",@"报名时间",@"手机",@"公司",@"报名状态"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configSelf];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    _hud.removeFromSuperViewOnHide = YES;
    [_hud showAnimated:YES];
    [self.view addSubview:_hud];
    
    [self getActivityInfo];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configSelf{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"我的报名信息";
}


/**
 添加btn，
 */
- (void)addBtn {
    
    //默认一个btn
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, kScreenSize.height - kButtonHeight, kScreenSize.width, kButtonHeight);
    btn.backgroundColor = [UIColor navigationbarColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //如果是 二维码进入的
    if (self.isQR) {
        [btn setTitle:@"立即签到" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(signBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithHex:0x188E50]] forState:UIControlStateHighlighted];
        
        [self.view addSubview:btn];
    }else{//正常活动报名进入
    
    //判断是否是源创会
    switch (self.activityType) {
            
        case ActivityTypeOSChinaMeeting: //源创汇
        {
            [self addTwoBtn];
            break;
        }
        default:
        {
            switch (_type) {
                case ActivityUserTypeNormal:
                {
                    [btn setTitle:@"取消报名" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                    [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithHex:0x188E50]] forState:UIControlStateHighlighted];
                    break;
                }
                case ActivityUserTypeSign:
                {
                    [btn setTitle:@"立即签到" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(signBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                    [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithHex:0x188E50]] forState:UIControlStateHighlighted];
                    break;
                }
                default:
                    break;
            }
            [self.view addSubview:btn];
            break;
        }
    }
        
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64 - kButtonHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    [self.view addSubview:_tableView];
    _tableView.hidden = YES;
}

#pragma mark --- Method

/**
 邀请函
 */
- (void)invitionBtnClick {
    
    OSCActivityUserQRController *qrVC = [[OSCActivityUserQRController alloc] initWithQRImage:_resultDic[@"invitationImg"]];
    [self.navigationController pushViewController:qrVC animated:YES];
}

/**
 点击签到
 */
- (void)signBtnClick:(UIButton*)sender{
        __weak typeof(self) weakSelf = self;

        sender.backgroundColor = [UIColor navigationbarColor];

            _hud = [[MBProgressHUD alloc] initWithView:self.view];
            _hud.removeFromSuperViewOnHide = YES;
            [_hud showAnimated:YES];
            AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
            NSString *activityDetailUrlStr= [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_SIGNIN];
            
            [manager POST:activityDetailUrlStr
               parameters:@{
                            @"sourceId" : @(_activityID),
                            @"phone"    : @"",
                            }
                  success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                      
                      if ([responseObject[@"code"] integerValue] == 1) {
                          NSDictionary *result = responseObject[@"result"];
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [_hud hideAnimated:YES];
                              OSCCompeleteSignController *signVC = [[OSCCompeleteSignController alloc] initWithSignInResult:result withActivityName:_activityName];
                              [weakSelf.navigationController pushViewController:signVC animated:YES];
                          });
                      } else {
                          [_hud hideAnimated:YES];
                          MBProgressHUD *HUD = [Utils createHUD];
                          HUD.mode = MBProgressHUDModeCustomView;
                          HUD.label.text = @"这个活动找不到了(不存在/已删除)";
                          [HUD hideAnimated:YES afterDelay:1];
                      }
                  } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                      [_hud hideAnimated:YES];
                      MBProgressHUD *HUD = [MBProgressHUD new];
                      HUD.mode = MBProgressHUDModeCustomView;
                      HUD.label.text = @"网络异常，加载失败";
                      
                      [HUD hideAnimated:YES afterDelay:1];
                  }];
}

/**
 源创会使用两个btn
 */
- (void)addTwoBtn {
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenSize.height - kButtonHeight, kScreenWidth, 1)];
    self.view.userInteractionEnabled = YES;
    [self.view addSubview:self.lineView];
    self.lineView.backgroundColor = [UIColor colorWithHex:0xECECEC];
    
    self.cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancleBtn.frame = CGRectMake(0, kScreenSize.height - kButtonHeight - 1, kScreenSize.width / 2 , kButtonHeight - 1);

    [self.cancleBtn setTitle:@"取消报名" forState:UIControlStateNormal];
    self.cancleBtn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [self.cancleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancleBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.cancleBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithHex:0xECECEC]] forState:UIControlStateHighlighted];

    UIButton *invitationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    invitationBtn.frame = CGRectMake(kScreenSize.width / 2 , kScreenSize.height - kButtonHeight, kScreenSize.width / 2 , kButtonHeight);
    invitationBtn.backgroundColor = [UIColor navigationbarColor];

    [invitationBtn setTitle:@"邀请函" forState:UIControlStateNormal];
    invitationBtn.titleLabel.font = [UIFont systemFontOfSize:kButtonFontSize];
    [invitationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [invitationBtn addTarget:self action:@selector(invitionBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [invitationBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithHex:0x188E50]] forState:UIControlStateHighlighted];
    
    self.invitationBtn = invitationBtn;
    
    
    [self.view addSubview:self.cancleBtn];
    [self.view addSubview:invitationBtn];
}



/**
 点击取消按钮
 */
- (void)cancelBtnClick:(UIButton *)sender {
    
   UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"确定要取消报名么？" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof (self)weakself = self;
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        
        //取消请求
        
        _hud = [[MBProgressHUD alloc] initWithView:weakself.view];
        _hud.removeFromSuperViewOnHide = YES;
        [_hud showAnimated:YES];
        AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
        NSString *applyCancelUrlStr= [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_APPLY_CANCEL];
        
        [manager POST:applyCancelUrlStr
           parameters:@{
                        @"sourceId" : @(_activityID),
                        }
              success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                  
                  if ([responseObject[@"code"] integerValue] == 1) {
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [_hud hideAnimated:YES];
                          MBProgressHUD *HUD = [Utils createHUD];
                          HUD.mode = MBProgressHUDModeCustomView;
                          HUD.label.text = responseObject[@"message"];
                          
                          [HUD hideAnimated:YES afterDelay:1];
                          for (UIViewController *controller in weakself.navigationController.viewControllers) {
                              if ([controller isKindOfClass:[ActivityDetailViewController class]]) {
                                  [weakself.navigationController popToViewController:controller animated:YES];
                              }
                          }
                      });
                  } else {
                      [_hud hideAnimated:YES];
                      
                      MBProgressHUD *HUD = [Utils createHUD];
                      HUD.mode = MBProgressHUDModeCustomView;
                      HUD.label.text = @"这个活动找不到了(不存在/已删除)";
                      [HUD hideAnimated:YES afterDelay:1];
                  }
              } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                  [_hud hideAnimated:YES];
                  MBProgressHUD *HUD = [MBProgressHUD new];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = @"网络异常，加载失败";
                  
                  [HUD hideAnimated:YES afterDelay:1];
              }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
  
    [self presentViewController:
     alertController animated:YES completion:nil];
}

- (void)getActivityInfo{
    __weak typeof(self) weakSelf = self;

    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSString *activityDetailUrlStr= [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_DETAIL];
    
    [manager GET:activityDetailUrlStr
      parameters:@{
                   @"id" : @(_activityID),
                   @"type" : @(InformationTypeActivity),
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue] == 1) {

                 OSCListItem *activityDetail = [OSCListItem osc_modelWithDictionary:responseObject[@"result"]];
                 _activityName = activityDetail.title;
                 weakSelf.activityType = activityDetail.extra.eventType;
        
                 dispatch_async(dispatch_get_main_queue(), ^{
                     _tableView.tableHeaderView = [[OSCActivityUserHeader alloc] initWithTitle:_activityName];
                     [weakSelf addBtn];

                 });
                 

                 [weakSelf getUserApplyInfo];
             } else {
                 [weakSelf.view showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"这个活动找不到了(不存在/已删除)"];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [weakSelf.navigationController popViewControllerAnimated:YES];
                 });
             }
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             [_hud hideAnimated:YES];
             [weakSelf.view showErrorPageView];
         }];
}

- (void)getUserApplyInfo{
    __weak typeof(self) weakSelf = self;
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSString *eventApplyInfoUrlStr= [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_APPLY_INFO];
    
    [manager GET:eventApplyInfoUrlStr
      parameters:@{
                   @"sourceId" : @(_activityID),
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue] == 1) {
                 _resultDic = responseObject[@"result"];
                 [weakSelf getTextHeightWithString:_resultDic[@"备注"]];
             }
             _tableView.hidden = NO;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_tableView reloadData];
                 [_hud hideAnimated:YES];
             });
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_hud hideAnimated:YES];
                 [weakSelf.view showErrorPageView];
             });
         }];
}

- (void)getTextHeightWithString:(NSString *)string{
    CGRect textFrame = [string boundingRectWithSize:CGSizeMake(kScreenSize.width - 32, MAX_CANON) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} context:nil];
    _remarkHeight = textFrame.size.height;
}

//颜色转为图片
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark --- UITableViewDateSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //return 7;
    return 6;//隐藏备注
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *noramlCellID = @"NormalCell";
    static NSString *remarkCellID = @"RemarkCell";
    if (indexPath.row < 6) {
        OSCActivityNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:noramlCellID];
        if (!cell) {
            cell = [[OSCActivityNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noramlCellID];
        }
        cell.detail = _resultDic[_keyArray[indexPath.row]];
        cell.info = _infoArray[indexPath.row];
        cell.isStauts = NO;
        if(indexPath.row == 5){
            cell.detail = _resultDic[_keyArray[indexPath.row]];
            cell.isStauts = YES;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
    }else{
        OSCActivityRemarkCell *cell = [tableView dequeueReusableCellWithIdentifier:remarkCellID];
        if(!cell){
            cell = [[OSCActivityRemarkCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:remarkCellID];
        }
        cell.detail = _resultDic[@"备注"];
        cell.textHeight = _remarkHeight;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row < 8){
        return 56;
    }
    return _remarkHeight + 8 + 30;
}

@end
