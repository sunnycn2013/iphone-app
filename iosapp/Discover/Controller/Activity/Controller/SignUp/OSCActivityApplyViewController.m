//
//  OSCActivityApplyViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/12/6.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityApplyViewController.h"
#import "AppDelegate.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCActivityApplyModel.h"
#import "OSCModelHandler.h"
#import "OSCActivityUserQRController.h"

#import "textCell.h"
#import "selectedListCell.h"
#import "TextareaCell.h"
#import "selectedCell.h"
#import "ActivityDetailViewController.h" //活动详情页

#import <MBProgressHUD.h>
#import "JDStatusBarNotification.h"

#define MAX_PHONENUMBER_LENGTH 11
#define kScreen_W [UIScreen mainScreen].bounds.size.width
#define kScreen_H [UIScreen mainScreen].bounds.size.height
#define miniViewHeight 200

static NSString *TextCellReuseIdentifier = @"textCell";
static NSString *SelectedListCellReuseIdentifier = @"selectedListCell";
static NSString *TextareaCellReuseIdentifier = @"TextareaCell";
static NSString *SelectedCellReuseIdentifier = @"selectedCell";

@interface OSCActivityApplyViewController ()<UITableViewDelegate, UITableViewDataSource, selectedCellDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    BOOL isShowKeyboard;
}

@property (nonatomic, assign) NSInteger sourceId;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, strong) NSMutableDictionary *parameters;
@property (nonatomic, strong) NSMutableArray *preLoads;
@property (nonatomic, assign) BOOL hudTextBool;
@property (nonatomic, copy) NSString *selectedTextString; //下拉选择的字符串
@property (nonatomic, copy) NSString *textFieldString; //输入框字符串

@property (nonatomic, assign) BOOL isMobileError;
@property (nonatomic, assign) BOOL isEmailError;

@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, strong) NSMutableArray *allKeyParameters; //必须带参数的所有KEY
@property (nonatomic, strong) NSMutableArray *addKeyParameters; //动态添加的KEY
@property (nonatomic, strong) NSMutableDictionary *uiLocationDataDictionary;
@property (nonatomic,strong) MBProgressHUD* HUD;

@end

@implementation OSCActivityApplyViewController
{
    CGFloat _curTouchPointHeight;
    NSMutableString* _parameterMutableStr;
}

- (instancetype)initWithActivitySourceId:(NSInteger)source
{
    self = [super init];
    if (self) {
        self.sourceId = source;
        
        _preLoads = [NSMutableArray array];
        _parameters = [NSMutableDictionary new];
        
        _allKeyParameters = [NSMutableArray new];
        _addKeyParameters = [NSMutableArray new];
        _uiLocationDataDictionary = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    isShowKeyboard = NO;
    [super viewDidLoad];
    
    _parameterMutableStr = [NSMutableString stringWithFormat:@"%@=%@",
                            [@"sourceId" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
                            [[NSString stringWithFormat:@"%ld",(long)self.sourceId] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    self.navigationItem.title = @"活动报名";
    _curTouchPointHeight = 0;
    
    [self buttonStyle:NO];
    [self getApplyPreload];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"textCell" bundle:nil] forCellReuseIdentifier:TextCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"selectedListCell" bundle:nil] forCellReuseIdentifier:SelectedListCellReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"TextareaCell" bundle:nil] forCellReuseIdentifier:TextareaCellReuseIdentifier];
    [self.tableView registerClass:[selectedCell class] forCellReuseIdentifier:SelectedCellReuseIdentifier];
    
    [self.tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)]];
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAction:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - hidden Keyboard
- (void)hiddenKeyboard:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
    [self.tableView reloadData];
}

#pragma mark - 拉下预报名信息
- (void)getApplyPreload
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_EVENT_APPLY_PRELOAD];
    [manager GET:strUrl
      parameters:@{
                   @"sourceId" : @(self.sourceId),
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             NSString *message = responseObject[@"message"];
             if ([responseObject[@"code"] integerValue] == 1) {
                 
                 NSArray *models = [NSArray osc_modelArrayWithClass:[OSCActivityApplyModel class] json:responseObject[@"result"]];
                 
                 self.preLoads = models.mutableCopy;
                 
                 //TODO
                 
                 [self allParamaterNumbers];
                 
                 _uiLocationDataDictionary = [self UIDictionaryLocationData].mutableCopy;
                 [self compareObjects]; //按钮enable
             } else {
                 [JDStatusBarNotification showWithStatus:message];
                 [JDStatusBarNotification dismissAfter:2];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             [JDStatusBarNotification showWithStatus:@"网络异常，加载失败"];
             [JDStatusBarNotification dismissAfter:2];
         }];
}

//本地暂存数据
- (NSMutableDictionary *)UIDictionaryLocationData
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [_preLoads enumerateObjectsUsingBlock:^(OSCActivityApplyModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray *checkBoxStatus = [NSMutableArray new];
        if (model.formType == EventApplyPreloadFormTypeCheckbox ||
            model.formType == EventApplyPreloadFormTypeRadio) {
            //
            [self optionStatusIsNil:model];
            NSArray *array = [selectedCell dicStringToArray:model.optionStatus];
            NSArray *nameArray = [selectedCell dicStringToArray:model.option];
            int i = 0;
            
            while (array.count > i) {

                if ([array[i] isEqualToString:@"1"]) {
                    [checkBoxStatus addObject:@(-1)];
                } else {
                    if ([model.key isEqualToString:@"gender"] && [nameArray[i] isEqualToString:@"男"]) {
                        [checkBoxStatus addObject:@(1)];
                    } else {
                        [checkBoxStatus addObject:@(0)];
                    }
                    
                }
                i++;
            }
            
            [dictionary setObject:checkBoxStatus forKey:model.key];
        } else {
            [dictionary setObject:(model.defaultValue == nil ? @"" : model.defaultValue) forKey:model.key];
        }
    }];
    
    return dictionary;
}

- (void)optionStatusIsNil:(OSCActivityApplyModel *)model
{
    __block NSString *optionStatusString;
    if (model.optionStatus == nil) {
        NSArray *array = [selectedCell dicStringToArray:model.option];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                optionStatusString = @"0;";
            } else if (idx == array.count - 1) {
                optionStatusString = [NSString stringWithFormat:@"%@0", optionStatusString];
            } else {
                optionStatusString = [NSString stringWithFormat:@"%@0;", optionStatusString];
            }
            
        }];
        
        model.optionStatus = optionStatusString;
    }
}

#pragma mark - 报名请求
- (IBAction)applysAction:(id)sender {
    
    [self buttonStyle:NO];
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    _HUD.removeFromSuperViewOnHide = YES;
    [_HUD showAnimated:YES];
    [self.view addSubview:_HUD];
    _HUD.label.text = @"报名请求发送中...";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    NSMutableString* strUrl = [NSMutableString string];
    for (NSString* parametersKey in [_parameters allKeys]) {
        
        NSString* key = parametersKey;
        key = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
        id value = _parameters[parametersKey];
        if ([value isKindOfClass:[NSArray class]]) {
            NSArray* value_arr = (NSArray* )value;
            for (NSString* value_str in value_arr) {
                [strUrl appendString:@"&"];
                NSMutableString* mutablePara = value_str.mutableCopy;
                [mutablePara replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, mutablePara.length)];
                NSString* resultValue = [mutablePara.copy stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                [strUrl appendString:[NSString stringWithFormat:@"%@=%@",key,resultValue]];
            }
            
        } else if ([value isKindOfClass:[NSString class]]){
            [strUrl appendString:@"&"];
            NSString* value_str = (NSString* )value;
            NSMutableString* mutablePara = value_str.mutableCopy;
            [mutablePara replaceOccurrencesOfString:@" " withString:@"" options:0 range:NSMakeRange(0, mutablePara.length)];
            value = [mutablePara.copy stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            [strUrl appendString:[NSString stringWithFormat:@"%@=%@",key,value]];
        }
    }
    
    [_parameterMutableStr appendString:strUrl.copy];
    NSData* parameterData = [_parameterMutableStr dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_EVENT_APPLY]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:20];
    [request setAllHTTPHeaderFields:[manager.requestSerializer HTTPRequestHeaders]];
    [request setHTTPBody:parameterData];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSInteger code = [dict[@"code"] integerValue];
        NSString *message = dict[@"message"];
        _HUD.mode = MBProgressHUDModeText;

        if (code == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _HUD.label.text = @"报名成功";
                [_HUD hideAnimated:YES afterDelay:1];
                __weak typeof(self) weakSelf = self;
                _HUD.completionBlock = ^(){
                    for (UIViewController *controller in weakSelf.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[ActivityDetailViewController class]]) {
                            [weakSelf.navigationController popToViewController:controller animated:YES];
                        }
                    }


                };
            });
         } else if (code == 0) {
             [self buttonStyle:YES];
             _HUD.label.text = message;
             [_HUD hideAnimated:YES afterDelay:1];
         } else {
             [self buttonStyle:YES];
             _HUD.label.text = @"网络异常，加载失败";
             [_HUD hideAnimated:YES afterDelay:1];
         }
    }];
    [task resume];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCActivityApplyModel *model = _preLoads[indexPath.row];
    
    switch (model.formType) {
        case EventApplyPreloadFormTypeDefault:
        case EventApplyPreloadFormTypeText:
        {
            textCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TextCellReuseIdentifier forIndexPath:indexPath];
            
            [self cellChangeUI:cell model:model indexPathRow:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            
            return cell;
            break;
        }
        case EventApplyPreloadFormTypeTextarea:
        {
            TextareaCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TextareaCellReuseIdentifier forIndexPath:indexPath];
            
            cell.nameLabel.text = model.required ? [NSString stringWithFormat:@"%@:", model.label] : [NSString stringWithFormat:@"%@ (选填):", model.label];
            cell.placeholderLabel.tag = 10;
            cell.textView.delegate = self;
            cell.textView.tag = indexPath.row + 1;
            cell.textView.layer.borderWidth = 1;
            cell.textView.layer.borderColor = [UIColor colorWithHex:0xc7c7cc alpha:0.6].CGColor;
            cell.textView.layer.cornerRadius = 4;
            cell.contentView.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textView.text = [_uiLocationDataDictionary valueForKey:model.key];
            
            if (cell.textView.text.length > 0) {
                [_parameters setObject:cell.textView.text forKey:model.key];
                if (model.defaultValue) {
                    if (![_addKeyParameters containsObject:model.key]) {
                        [_addKeyParameters addObject:model.key];
                    }
                }
            }
            [self compareObjects];

//            UITableViewCell *cell = [[UITableViewCell alloc] init];
//            cell.backgroundColor = [UIColor colorWithRed:246 green:246 blue:246 alpha:0];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            break;
        }
        case EventApplyPreloadFormTypeSelect://选泽
        {
            selectedListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SelectedListCellReuseIdentifier forIndexPath:indexPath];
            
            
            cell.descTextView.layer.borderWidth = 1;
            cell.descTextView.layer.borderColor = [UIColor colorWithHex:0xc7c7cc alpha:0.6].CGColor;
            
            // 1. 创建一个点击事件，点击时触发cell方法。目前didselect无效
            UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelClick)];
            [cell addGestureRecognizer:labelTapGestureRecognizer];
            cell.userInteractionEnabled = YES;
        
            cell.descTextView.layer.cornerRadius = 4;
            cell.arrowIcon.tag = indexPath.row + 100;
            self.tag = cell.arrowIcon.tag;
            
            [cell.arrowIcon addTarget:self action:@selector(alertViewAction:) forControlEvents:UIControlEventTouchUpInside];
            
            
            cell.nameLabel.text = model.required ? [NSString stringWithFormat:@"%@:", model.label] : [NSString stringWithFormat:@"%@ (选填):", model.label];
            cell.descTextLabel.text = [_uiLocationDataDictionary valueForKey:model.key];
            
            cell.contentView.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
            
            if (cell.descTextLabel.text.length > 0) {
                [_parameters setObject:cell.descTextLabel.text forKey:model.key];
                if (model.defaultValue) {
                    if (![_addKeyParameters containsObject:model.key]) {
                        [_addKeyParameters addObject:model.key];
                    }
                }
            }
            
            [self compareObjects];
            
            return cell;
            
            break;
        }
        case EventApplyPreloadFormTypeCheckbox:
        case EventApplyPreloadFormTypeRadio:
        {
            selectedCell *cell = [[selectedCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:SelectedCellReuseIdentifier
                                                       andDictionary:model
                                                        locatoinData:[_uiLocationDataDictionary valueForKey:model.key]];
            
            cell.contentView.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            
            return cell;
            break;
        }
        default:
        {
            textCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TextCellReuseIdentifier forIndexPath:indexPath];
            
            [self cellChangeUI:cell model:model indexPathRow:indexPath.row];
            
            return cell;
            break;
        }
    }
    return [UITableViewCell new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_preLoads.count > 0) {
        return _preLoads.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCActivityApplyModel *model = _preLoads[indexPath.row];
    if (model.formType == EventApplyPreloadFormTypeText) {
        return 88;
    } else if (model.formType == EventApplyPreloadFormTypeRadio || model.formType == EventApplyPreloadFormTypeCheckbox) {
        int arrayCount = (int)[selectedCell dicStringToArray:model.option].count;
        
        return ((arrayCount-1)/4 + 1)*40 + 40;
    }
    
    else if (model.formType == EventApplyPreloadFormTypeTextarea) {
        return 200;
    }
    return 100;
}

#pragma mark - cell ui
- (void)cellChangeUI:(textCell *)cell model:(OSCActivityApplyModel *)model indexPathRow:(NSInteger)row
{
    cell.nameLabel.text = model.required ? [NSString stringWithFormat:@"%@:", model.label] : [NSString stringWithFormat:@"%@ (选填):", model.label];
    cell.textField.text = [_uiLocationDataDictionary valueForKey:model.key];
    
    if (cell.textField.text.length > 0) {
        [_parameters setObject:cell.textField.text forKey:model.key];
        if (model.defaultValue) {
            
            if (![_addKeyParameters containsObject:model.key]) {
                [_addKeyParameters addObject:model.key];
            }
            
        }
    }
    
    cell.textField.tag = row+1;
    cell.textField.delegate = self;
    cell.hudTextLabel.hidden = YES;
    [Utils setButtonBorder:cell.textField isFail:NO isEditing:NO];
    if ([model.key isEqualToString:@"mobile"]) {
        cell.textField.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
    } else if ([model.key isEqualToString:@"email"]){
        cell.textField.keyboardType = UIKeyboardTypeEmailAddress;
    } else {
        cell.textField.keyboardType = UIKeyboardTypeDefault;
    }
    [cell.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    cell.contentView.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([model.key isEqualToString:@"mobile"] && _textFieldString.length > 0) {
        cell.hudTextLabel.hidden = !_isMobileError;
        cell.hudTextLabel.text = @"手机号码格式不正确";
        [Utils setButtonBorder:cell.textField isFail:_isMobileError isEditing:NO];
    } else if ([model.key isEqualToString:@"email"] && _textFieldString.length > 0) {
        cell.hudTextLabel.hidden = !_isEmailError;
        cell.hudTextLabel.text = @"邮箱地址格式不正确";
        [Utils setButtonBorder:cell.textField isFail:_isEmailError isEditing:NO];
    }

    [self compareObjects];
}

#pragma mark - selected alertView
- (void)alertViewAction:(UIButton *)btn
{
    OSCActivityApplyModel *model = _preLoads[btn.tag - 100];
    
    [self optionStatusIsNil:model];
    
    NSArray *titleArray = [selectedCell dicStringToArray:model.option];//选择标题
    NSMutableArray *titleStatusArray = [selectedCell dicStringToArray:model.optionStatus].mutableCopy;//选择标题状态
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:model.label message:nil preferredStyle:UIAlertControllerStyleAlert];
    if (titleArray.count < 1) {
        return;
    }
    [titleArray enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            _selectedTextString = title;
            [_uiLocationDataDictionary setObject:title forKey:model.key];
            
            NSInteger row = btn.tag - 100;
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
            [_addKeyParameters addObject:model.key];
            [self compareObjects];
        }];
        alertAction.enabled = [titleStatusArray[idx] isEqualToString:@"1"] ? NO : YES;
        [alertVC addAction: alertAction];
    }];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return;
    }]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

#pragma select location
// 会场选择
- (void)labelClick {
    OSCActivityApplyModel *model = _preLoads[self.tag - 100];
    switch (model.formType) {
        case EventApplyPreloadFormTypeSelect://选泽
        {
            [self optionStatusIsNil:model];
            NSArray *titleArray = [selectedCell dicStringToArray:model.option];//选择标题
            NSMutableArray *titleStatusArray = [selectedCell dicStringToArray:model.optionStatus].mutableCopy;//选择标题状态
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:model.label message:nil preferredStyle:UIAlertControllerStyleAlert];
            if (titleArray.count < 1) {
                return;
            }
            [titleArray enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
                UIAlertAction *alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    _selectedTextString = title;
                    [_uiLocationDataDictionary setObject:title forKey:model.key];
                    
                    NSInteger row = self.tag - 100;
                    
                    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
                    [_addKeyParameters addObject:model.key];
                    [self compareObjects];
                }];
                alertAction.enabled = [titleStatusArray[idx] isEqualToString:@"1"] ? NO : YES;
                [alertVC addAction: alertAction];
            }];
            
            [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                return;
            }]];
            
            [self presentViewController:alertVC animated:YES completion:nil];
            
            break;
        }
            
        default:
        {
            
        }
    }
}


#pragma mark - selectedCellDelegate
- (void)selectedCell:(NSArray *)optionStutas
          applyModel:(OSCActivityApplyModel *)model
        locatoinData:(NSArray *)statusArray
     forSelectedCell:(selectedCell *)cell
{
    
    [_parameters setObject:optionStutas forKey:model.key];
    
    NSMutableArray *array = statusArray.mutableCopy;
    [_uiLocationDataDictionary setObject:array forKey:model.key];
    
    [self.tableView reloadData];
}

#pragma mark - UITextField
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [Utils setButtonBorder:textField isFail:NO isEditing:YES];
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [textField convertRect: textField.bounds toView:keyWindow];
    CGFloat windowPoint = CGRectGetMaxY(rect);
    _curTouchPointHeight = windowPoint;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [Utils setButtonBorder:textField isFail:NO isEditing:NO];
    _textFieldString = textField.text;
    
    
    BOOL isMobile = NO;
    BOOL isEmail = NO;
    
    OSCActivityApplyModel *model = _preLoads[textField.tag - 1];
    if ([model.key isEqualToString:@"mobile"]) {
        isMobile = YES;
    } else if ([model.key isEqualToString:@"email"] ){
        isEmail = YES;
    }
    
    if (isMobile) {
        if ([Utils validateMobile:textField.text]) {
            [textField resignFirstResponder];
            _isMobileError = NO;
        } else {
            _isMobileError = YES;
        }
    } else if (isEmail) {
        if ([Utils validateEmail:textField.text]) {
            [textField resignFirstResponder];
            _isEmailError = NO;
        } else {
            _isEmailError = YES;
        }
    }
    
    //存字典传参
    if (textField.text.length > 0) {//必带参
        [_parameters setObject:textField.text forKey:model.key];
        [self addParameterCollected:model];
    }
    if (textField.text.length == 0){
        [_parameters removeObjectForKey:model.key];
        if (_addKeyParameters != nil) {
            if ([_addKeyParameters containsObject:model.key]){
                [_addKeyParameters removeObject:model.key];
            }
        }
    }
    
    [_uiLocationDataDictionary setObject:textField.text forKey:model.key];
    
    NSInteger row = textField.tag - 1;
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    OSCActivityApplyModel *model = _preLoads[textField.tag - 1];
    
    if ([model.key isEqualToString:@"mobile"]) {
        if (textField.text.length > 11) {
            
            textField.text = [textField.text substringToIndex:11];
            
        }
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    OSCActivityApplyModel *model = _preLoads[textView.tag - 1];

    if (model.formType == EventApplyPreloadFormTypeTextarea) {
        TextareaCell* cell = (TextareaCell* )[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textView.tag - 1 inSection:0]];
    
        if (![text isEqualToString:@""]) {
            cell.placeholderLabel.hidden = YES;
        }
        
        if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
            cell.placeholderLabel.hidden = NO;
        }
        
        
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    CGRect rect = [textView convertRect: textView.bounds toView:keyWindow];
    CGFloat windowPoint = CGRectGetMaxY(rect);
    _curTouchPointHeight = windowPoint;
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    OSCActivityApplyModel *model = _preLoads[textView.tag - 1];
   
    if (textView.text.length > 0) {
        [_parameters setObject:textView.text forKey:model.key];
        [self addParameterCollected:model];
    }
    if (textView.text.length == 0){
        [_parameters removeObjectForKey:model.key];
        if (_addKeyParameters != nil) {
            if ([_addKeyParameters containsObject:model.key]){
                [_addKeyParameters removeObject:model.key];
            }
        }
    }
    
    [_uiLocationDataDictionary setObject:textView.text forKey:model.key];
    _curTouchPointHeight = 0;

    [self.tableView reloadData];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [self.view removeGestureRecognizer:_tap];
    _curTouchPointHeight = 0;
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
    
    
    CGFloat offestY = kScreen_H - keyBoradHeight;
    CGFloat paading = 20;
    __block CGFloat moveY;
    if (_curTouchPointHeight > offestY) {
        moveY = _curTouchPointHeight - offestY + paading;
    }else{
        moveY = 0;
    }
    
    if (notification.name == UIKeyboardWillShowNotification) {
        if (isShowKeyboard == NO) {
            [UIView animateWithDuration:timeInt
                                  delay:0.f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 CGRect oldFrame = self.tableView.frame;
                                 oldFrame.origin.y -= moveY;
                                 self.tableView.frame = oldFrame;
                                 _curTouchPointHeight = 0;

                             } completion:^(BOOL finished) {
                                 isShowKeyboard = YES;
                                 //
                                 _curTouchPointHeight = 0;
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
                             _curTouchPointHeight = 0;

                         } completion:^(BOOL finished) {
                             isShowKeyboard = NO;
                             _curTouchPointHeight = 0;

                         }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - button clicked
- (IBAction)settingTouchDownColor:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHex:0x188E50];
}
- (IBAction)settingTouchUp:(UIButton *)sender {
    sender.backgroundColor = [UIColor colorWithHex:0x18BB50];
}

#pragma mark - button enable
- (void)buttonStyle:(BOOL)isEnable
{
    if (isEnable) {
        _applyButton.backgroundColor = [UIColor navigationbarColor];
        [_applyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _applyButton.enabled = YES;
    } else {
        _applyButton.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        [_applyButton setTitleColor:[UIColor colorWithHex:0xd5d5d5] forState:UIControlStateNormal];
        _applyButton.enabled = NO;
    }
}

//必填参数个数
- (void)allParamaterNumbers
{
    __block NSMutableArray *number = [NSMutableArray new];
    [self.preLoads enumerateObjectsUsingBlock:^(OSCActivityApplyModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.formType == EventApplyPreloadFormTypeCheckbox || obj.formType == EventApplyPreloadFormTypeRadio) {
            
        } else {
            if (obj.required) {
                [number addObject:obj.key];
            }
        }
        
    }];
    
    self.allKeyParameters = number.mutableCopy;
}

#pragma mark - 判断是否必选参全选
- (void)addParameterCollected:(OSCActivityApplyModel *)model
{
    if (_addKeyParameters != nil) {
        if (_addKeyParameters.count > 0) {
            if (![_addKeyParameters containsObject:model.key]) {
                [_addKeyParameters addObject:model.key];
            } else {
                
            }
        } else if (_addKeyParameters.count == 0){
            [_addKeyParameters addObject:model.key];
        }
    }
    
    [self compareObjects];
}

- (void)compareObjects
{
    __block BOOL isAllIn = YES;
    for (NSString *obj in _allKeyParameters) {
        if (![_addKeyParameters containsObject:obj]) {
            isAllIn = NO;
        }
    }
    if (isAllIn) {
        [self buttonStyle:YES];
    } else {
        [self buttonStyle:NO];
    }
}

@end







