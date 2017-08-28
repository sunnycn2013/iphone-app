//
//  OSCEventSignInViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/12/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCEventSignInViewController.h"
#import "ActivityHeadCell.h"
#import "OSCEventSignInCell.h"
#import "ActivityDetailViewController.h"

#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCActivities.h"
#import "OSCModelHandler.h"
#import "UIView+Common.h"

#import <MBProgressHUD.h>

#define MAX_PHONENUMBER_LENGTH 11
#define viewHeight [UIScreen mainScreen].bounds.size.height
#define navBarHeight 108
#define textToTop 150
#define headViewHeight 210

static NSString * const activityHeadDetailReuseIdentifier = @"ActivityHeadCell";
static NSString * const activitySiginInReuseIdentifier = @"OSCEventSignInCell";

@interface OSCEventSignInViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    CGFloat maxY;
    BOOL isShowKeyboard;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@property (nonatomic, assign) NSInteger eventId;
@property (nonatomic, strong) OSCActivities *activity;
@property (nonatomic, strong) NSMutableDictionary *eventApplyInfos;

@property (nonatomic, copy) NSString *phoneNumberString;
@property (nonatomic, copy) NSString *resultMessage;
@property (nonatomic, copy) NSString *costMessage;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, assign) BOOL isGetApplyInfoDic;

@end

@implementation OSCEventSignInViewController

- (instancetype)initWithActivityModelID:(NSInteger)eventId
{
    self = [super init];
    if (self) {
        //        self.eventId = 2193632;
        _eventApplyInfos = [NSMutableDictionary dictionary];
        
        self.eventId = eventId;
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([Config getOwnID] == 0) {
        _isGetApplyInfoDic = NO;
        [self buttonStyle:NO];
    }
    
    [self getActivityDetail];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.hidden = YES;
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _signInButton.layer.cornerRadius = 24;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityHeadCell" bundle:nil] forCellReuseIdentifier:activityHeadDetailReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCEventSignInCell" bundle:nil] forCellReuseIdentifier:activitySiginInReuseIdentifier];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard)]];
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    __weak typeof(self) weakSelf = self;
    [weakSelf.view configReloadAction:^{
        __strong typeof(self) strongSelf = weakSelf;
        [self.view hideAllGeneralPage];
        
        [strongSelf getActivityDetail];
    }];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self hideHubView:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

#pragma mark - siginIn Button style
- (void)buttonStyle:(BOOL)isEnable
{
    _signInButton.enabled = isEnable;
    if (isEnable) { //可点击
        _signInButton.backgroundColor = [UIColor navigationbarColor];
        [_signInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        _signInButton.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        [_signInButton setTitleColor:[UIColor colorWithHex:0xd5d5d5] forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [Utils setButtonBorder:textField isFail:NO isEditing:YES];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [Utils setButtonBorder:textField isFail:NO isEditing:NO];
    if ([Utils validateMobile:textField.text]) {
        [self buttonStyle:YES];
    } else {
        MBProgressHUD *HUD = [MBProgressHUD new];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"不是匹配的手机号码";
        
        [HUD hideAnimated:YES afterDelay:2];
        
        [self buttonStyle:NO];
    }
    _phoneNumberString = textField.text;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length == MAX_PHONENUMBER_LENGTH - 1) {
        [self buttonStyle:YES];
    } else {
        [self buttonStyle:NO];
    }
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length == MAX_PHONENUMBER_LENGTH - 1) {
        [self buttonStyle:YES];
    } else if (textField.text.length > 11) {
        [self buttonStyle:NO];
        textField.text = [textField.text substringToIndex:11];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self buttonStyle:NO];
    
    return YES;
}

#pragma mark - hiddenKeyboard
- (void)hiddenKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [self.tableView reloadData];
    
    [self.view removeGestureRecognizer:_tap];
}

- (void)keyboardAction:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval timeInt;
    [animationDuration getValue:&timeInt];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGFloat keyBoradHeight = keyboardRect.size.height;
    if (keyBoradHeight <= 0) {
        return;
    }
    
    maxY = headViewHeight - (viewHeight - keyBoradHeight - textToTop) * 0.5;
    
    if (notification.name == UIKeyboardWillShowNotification) {
        if (isShowKeyboard == NO) {
            [UIView animateWithDuration:timeInt
                                  delay:0.f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 CGRect oldFrame = self.tableView.frame;
                                 oldFrame.origin.y -= maxY;
                                 self.tableView.frame = oldFrame;
                             } completion:^(BOOL finished) {
                                 isShowKeyboard = YES;
                             }];
            
            _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHiden:)];
            [self.view addGestureRecognizer:_tap];
        }
        
        
    } else if (notification.name == UIKeyboardWillHideNotification) {
        [UIView animateWithDuration:-timeInt
                              delay:0.f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             CGRect oldFrame = self.tableView.frame;
                             oldFrame.origin.y = 0;
                             self.tableView.frame = oldFrame;
                         } completion:^(BOOL finished) {
                             isShowKeyboard = NO;
                         }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - MBProgressHUD
- (void)hideHubView:(NSTimeInterval)timeInterval{
    [_hud hideAnimated:YES afterDelay:timeInterval];
    [[self.view viewWithTag:10] removeFromSuperview];
}

#pragma mark - 处理扫描我的活动签到
- (void)getActivityDetail
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSString *activityDetailUrlStr= [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT];
    
    [manager GET:activityDetailUrlStr
      parameters:@{
                   @"id" : @(_eventId),
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue] == 1) {
                 self.signInButton.hidden = NO;
                 _activity = [OSCActivities osc_modelWithDictionary:responseObject[@"result"]];
                 
                 _activity.body = [Utils HTMLWithData:@{@"content":  _activity.body}
                                        usingTemplate:@"newTweet"];
                 [self getEventApplyInfo];
             } else {
                 _hud.hidden = YES;
                 [self.view showCustomPageViewWithImage:[UIImage imageNamed:@"ic_tip_smile"] tipString:@"这个活动找不到了(不存在/已删除)"];
                 self.signInButton.hidden = YES;
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                     [self.navigationController popViewControllerAnimated:YES];
                 });
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self.tableView reloadData];
             });
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             _hud.hidden = YES;
             
             [self.view showErrorPageView];
             self.signInButton.hidden = YES;
         }];
    
}

#pragma mark - 获取报名信息
- (void)getEventApplyInfo
{
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSString *eventApplyInfoUrlStr= [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_APPLY_INFO];
    
    [manager GET:eventApplyInfoUrlStr
      parameters:@{
                   @"sourceId" : @(_eventId),
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject[@"code"] integerValue] == 1) {
                 //成功，显示报名者信息
                 NSDictionary *dic = responseObject[@"result"];
                 _eventApplyInfos = dic.mutableCopy;
                 
                 [self buttonStyle:YES];
                 
                 _isGetApplyInfoDic = YES;
                 
             } else {
                 //失败，手机号码签到
                 _isGetApplyInfoDic = NO;
                 [self buttonStyle:NO];
             }
             self.signInButton.hidden = NO;
             _hud.hidden = YES;
             self.tableView.hidden = NO;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             _hud.hidden = YES;
             _isGetApplyInfoDic = NO;
             
             [self.view showErrorPageView];
             self.signInButton.hidden = YES;
             [self buttonStyle:NO];
         }];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isGetApplyInfoDic) {
        return _eventApplyInfos.count + 1;
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ActivityHeadCell *cell = [_tableView dequeueReusableCellWithIdentifier:activityHeadDetailReuseIdentifier forIndexPath:indexPath];
        
        cell.activity = self.activity;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor = [UIColor navigationbarColor];
        cell.contentView.backgroundColor = [UIColor navigationbarColor];
        
        return cell;
    } else if (indexPath.row > 0) {
        if (_isGetApplyInfoDic) {
            UITableViewCell *cell = [UITableViewCell new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.numberOfLines = 0;
            
            NSString *key = [_eventApplyInfos allKeys][indexPath.row - 1];
            NSString *value = [_eventApplyInfos allValues][indexPath.row - 1];
            
            cell.textLabel.text = [NSString stringWithFormat:@"%@ : %@", key, (value.length ? value : @" ")];
            
            return cell;
        } else {
            OSCEventSignInCell *cell = [_tableView dequeueReusableCellWithIdentifier:activitySiginInReuseIdentifier forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.selectedButton setImage:[UIImage imageNamed:@"form_checkbox_checked"] forState:UIControlStateNormal];
            
            cell.phoneNumberTF.delegate = self;
            [cell.phoneNumberTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            
            if ([cell.phoneNumberTF isFirstResponder]) {
                [cell.phoneNumberTF resignFirstResponder];
            }
            
            if (_resultMessage.length > 0) {
                cell.messageLabel.textAlignment = NSTextAlignmentCenter;
                cell.messageLabel.hidden = NO;
                cell.phoneInfoView.hidden = YES;
                cell.messageLabel.text = _resultMessage;
                cell.costMessageLabel.text = _costMessage;
                [self buttonStyle:NO];
            } else {
                cell.messageLabel.textAlignment = NSTextAlignmentLeft;
                cell.messageLabel.hidden = YES;
                
                if (_phoneNumberString.length == 11) {
                    [self buttonStyle:YES];
                } else {
                    [self buttonStyle:NO];
                }
            }
            
            return cell;
        }
        
        
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 210;
    } else {
        if (_eventApplyInfos != nil && _eventApplyInfos.count > 0) {
            NSString *key = [_eventApplyInfos allKeys][indexPath.row - 1];
            NSString *value = [_eventApplyInfos allValues][indexPath.row - 1];
            NSString *string = [NSString stringWithFormat:@"%@ : %@", key, (value.length ? value : @" ")];
            
            CGFloat height = (CGFloat)[string boundingRectWithSize:(CGSize){(kScreenWidth - 32), 15 * 2 + [UIFont systemFontOfSize:15].lineHeight}
                                                           options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                        attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                                           context:nil].size.height;
            
            return height + 16;
        } else {
            return 150;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:_activity.id];
        activityDetailCtl.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activityDetailCtl animated:YES];
    }
}

#pragma mark - SIGIN IN
- (IBAction)signInActioin:(id)sender {
    
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSString *activityDetailUrlStr= [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_SIGNIN];
    
    [manager POST:activityDetailUrlStr
       parameters:@{
                    @"sourceId" : @(_activity.id),
                    @"phone"    : _phoneNumberString.length ? _phoneNumberString : @"",
                    }
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              
              if ([responseObject[@"code"] integerValue] == 1) {
                  NSDictionary *result = responseObject[@"result"];
                  
                  [self signInResult:result];
                  dispatch_async(dispatch_get_main_queue(), ^{
                      _hud.hidden = YES;
                      [self.tableView reloadData];
                  });
              } else {
                  _hud.hidden = YES;
                  MBProgressHUD *HUD = [Utils createHUD];
                  HUD.mode = MBProgressHUDModeCustomView;
                  HUD.label.text = @"这个活动找不到了(不存在/已删除)";
                  [HUD hideAnimated:YES afterDelay:1];
              }
          } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              _hud.hidden = YES;
              MBProgressHUD *HUD = [MBProgressHUD new];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.label.text = @"网络异常，加载失败";
              
              [HUD hideAnimated:YES afterDelay:1];
          }];
}

- (void)signInResult:(NSDictionary *)result
{
    if (_eventApplyInfos != nil && _eventApplyInfos.count > 0) { [_eventApplyInfos removeAllObjects]; }
    
    int optStatus = [result[@"optStatus"] intValue];
    NSString *message = result[@"message"];
    NSString *costMessage = result[@"costMessage"];
    
    switch (optStatus) {
        case 1:
        {
            _resultMessage = message;
            _costMessage = costMessage;
            _isGetApplyInfoDic = NO;
            break;
        }
        case 2:
        {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = message;
            [HUD hideAnimated:YES afterDelay:1];
            _resultMessage = @"";
            _costMessage = @"";
            break;
        }
        case 3:
        {
            _costMessage = costMessage;
            _resultMessage = message;
            _isGetApplyInfoDic = NO;
            break;
        }
        case 4:
        {
            _costMessage = costMessage;
            _resultMessage = message;
            _isGetApplyInfoDic = NO;
            break;
        }
        default:
            break;
    }
    
    [self.tableView reloadData];
}

@end
