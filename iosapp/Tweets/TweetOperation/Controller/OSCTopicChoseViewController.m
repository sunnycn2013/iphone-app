//
//  OSCTopicChoseViewController.m
//  iosapp
//
//  Created by 王恒 on 17/1/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCTopicChoseViewController.h"
#import "Utils.h"

#import "NSObject+Comment.h"
#import "UIColor+Util.h"

#import <MBProgressHUD.h>
#import <YYKit.h>

#define kTitleTextFieldH 35
#define kHotTopic @[@"码云",@"毎日の歌",@"开源中国",@"开源中国客户端"]

@interface OSCTopicChoseViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>

@property (nonatomic,weak) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *topicArray;
@property (nonatomic,strong) UITextField *textField;

@property (nonatomic,strong) NSMutableArray *sortArray;//存放本地拼音，用于排序

@end

@implementation OSCTopicChoseViewController

- (instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationItem.title = @"选择话题";
    self.view.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick)];
    
    [self handelTopicArray];
    
    [self addContenteView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark --- Method
- (void)addContenteView{
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(5, 69, kScreenSize.width - 10, kTitleTextFieldH)];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.layer.cornerRadius = kTitleTextFieldH / 2;
    _textField.layer.masksToBounds = YES;
    _textField.layer.borderWidth = 0.5;
    _textField.layer.borderColor = [UIColor colorWithHex:0xc7c7cc].CGColor;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    leftView.tintColor = [UIColor lightGrayColor];
    leftView.backgroundColor = [UIColor whiteColor];
    UIImageView *leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(7, 5, 17, 17)];
    leftImage.image = [[UIImage imageNamed:@"toolbar-reference"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [leftView addSubview:leftImage];
    _textField.leftView = leftView;
    _textField.placeholder = @"请输入话题或点击下列话题";
    _textField.textColor = [UIColor navigationbarColor];
    _textField.font = [UIFont systemFontOfSize:15.0];
    _textField.delegate = self;
    _textField.returnKeyType = UIReturnKeyDone;
    [_textField addTarget:self action:@selector(textFieldValueChange) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:_textField];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 + kTitleTextFieldH + 10, kScreenSize.width, kScreenSize.height - 64 - kTitleTextFieldH + 10) style:UITableViewStylePlain];
    _tableView = tableView;
    _tableView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.sectionHeaderHeight = 25;
    UIButton *footerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    footerBtn.frame = CGRectMake(0, 0, kScreenSize.width, 40);
    footerBtn.backgroundColor = [UIColor whiteColor];
    footerBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [footerBtn setTitle:@"点击清除本地记录" forState:UIControlStateNormal];
    [footerBtn setTitleColor:[[UIColor grayColor] colorWithAlphaComponent:0.6] forState:UIControlStateNormal];
    [footerBtn addTarget:self action:@selector(clearBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 0.5)];
    lineView.backgroundColor = [UIColor separatorColor];
    [footerBtn addSubview:lineView];
    if([_topicArray[1] count] > 0){
        _tableView.tableFooterView = footerBtn;
    }else{
        _tableView.tableFooterView = [UIView new];
    }
    [self.view addSubview:_tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.textField resignFirstResponder];
}

- (void)handelTopicArray{
    _topicArray = [[NSMutableArray alloc] init];
    NSMutableArray *hotTopicArray = [kHotTopic mutableCopy];
    [_topicArray addObject:hotTopicArray];
    NSArray *array = [NSObject allLocalTopics];
    if (!array) {
        array = [NSArray array];
    }
    _sortArray = [NSMutableArray array];
    for (NSString *topicString in array) {
        [_sortArray addObject:[self StringToEnglishWithString:topicString]];
    }
    NSMutableArray *localTopicArray = [array mutableCopy];
    [_topicArray addObject:localTopicArray];
}

- (void)rightBarButtonClick{
    [_textField resignFirstResponder];
    [self clickReturn];
}

- (void)clickReturn{
    NSString *textString = _textField.text;
	textString = [textString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; //去掉首位空格
    if (textString.length > 0) {
        if ([self.topicDelegate respondsToSelector:@selector(completeChoseTopicWithTopicString:)]) {
            [self.topicDelegate completeChoseTopicWithTopicString:textString];
        }
        [NSObject updateTopic2LocalTopic:textString];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        MBProgressHUD *hud = [Utils createHUD];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"话题不能为空";
        [hud hideAnimated:YES afterDelay:2];
    }
}

- (void)clearBtnClick{
    [NSObject removeAllTopics];
    NSMutableArray *localArray = _topicArray[1];
    [localArray removeAllObjects];
    [_tableView deleteSection:1 withRowAnimation:UITableViewRowAnimationFade];
    _tableView.tableFooterView = [UIView new];
}

- (void)textFieldValueChange{
    NSString *textEnglish = [self StringToEnglishWithString:_textField.text];
    NSMutableArray *localTopicArray = _topicArray[1];
    if (textEnglish.length > 0 && localTopicArray.count > 1) {
        for (NSString *string in _sortArray) {
            if ([string containsString:textEnglish]) {
                NSInteger index = [_sortArray indexOfObject:string];
                NSString *topic = localTopicArray[index];
                [localTopicArray removeObject:topic];
                [localTopicArray insertObject:topic atIndex:0];
            }
        }
        NSIndexSet *set = [NSIndexSet indexSetWithIndex:1];
        [_tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSString *)StringToEnglishWithString:(NSString *)targetString{
    NSMutableString *mutable = [targetString mutableCopy];
    CFRange cfRange = CFRangeMake(0, mutable.length);
    CFStringTransform((__bridge CFMutableStringRef)mutable, &cfRange, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)mutable, &cfRange, kCFStringTransformStripDiacritics, NO);
    mutable = [[mutable stringByReplacingOccurrencesOfString:@" " withString:@""] mutableCopy];
    return mutable;
}

#pragma mark --- UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger numberSection = 1;
    if([_topicArray[1] count] != 0){
        numberSection ++;
    }
    return numberSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_topicArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.text = _topicArray[indexPath.section][indexPath.row];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *localArray = _topicArray[indexPath.section];
        [NSObject removeTopic:localArray[indexPath.row]];
        [localArray removeObjectAtIndex:indexPath.row];
        if (localArray.count == 0) {
            [_tableView deleteSection:1 withRowAnimation:UITableViewRowAnimationFade];
        }else{
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        tableView.tableFooterView = [UIView new];
    }
}

#pragma mark --- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.topicDelegate respondsToSelector:@selector(completeChoseTopicWithTopicString:)]) {
        [self.topicDelegate completeChoseTopicWithTopicString:_topicArray[indexPath.section][indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 25)];
    headerView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, kScreenSize.width - 20, 25)];
    label.font = [UIFont systemFontOfSize:13.0];
    label.textColor = [UIColor grayColor];
    if (section == 0) {
        label.text = @"热门";
    }else{
        label.text = @"本地";
    }
    [headerView addSubview:label];
    return headerView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

#pragma mark --- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_textField resignFirstResponder];
}

#pragma mark --- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self clickReturn];
    return YES;
}

@end
