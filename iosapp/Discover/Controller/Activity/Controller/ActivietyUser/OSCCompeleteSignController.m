//
//  OSCCompeleteSignController.m
//  iosapp
//
//  Created by 王恒 on 17/4/14.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCCompeleteSignController.h"

#import "UIColor+Util.h"

#import <Masonry.h>

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface OSCCompeleteSignController ()

@property (nonatomic,strong) NSDictionary *result;
@property (nonatomic,strong) NSString *activityName;

@end

@implementation OSCCompeleteSignController

- (instancetype)initWithSignInResult:(NSDictionary *)result withActivityName:(NSString *)title{
    self = [super init];
    if (self) {
        _result = result;
        _activityName = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configSelf];
    [self addContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --- Method
- (void)configSelf{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"活动签到";
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)addContentView{
    CGFloat titleHeight = [self getTextHeightWithString:_activityName withFont:[UIFont systemFontOfSize:18.0] withWidth:kScreenSize.width - 32];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, titleHeight + 32)];
    headerView.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
    [self.view addSubview:headerView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 16, kScreenSize.width - 32, titleHeight)];
    label.text = _activityName;
    label.font = [UIFont systemFontOfSize:18];
    label.numberOfLines = 0;
    [headerView addSubview:label];
    
    UIImageView *topTmageView = [UIImageView new];
    topTmageView.image = [UIImage imageNamed:@"bg_ticket_event_top"];
    [self.view addSubview:topTmageView];
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;

    messageLabel.text= _result[@"message"];
    messageLabel.font = [UIFont systemFontOfSize:14];
    messageLabel.numberOfLines = 0;
    [topTmageView addSubview:messageLabel];
    
    UILabel *costLabel = [UILabel new];
    costLabel.textColor = [UIColor whiteColor];
    costLabel.textAlignment = NSTextAlignmentCenter;
    costLabel.font = [UIFont systemFontOfSize:72];
    costLabel.text = [NSString stringWithFormat:@"￥%ld",[_result[@"cost"] integerValue]/100];
    [topTmageView addSubview:costLabel];
    
    [topTmageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(headerView.mas_bottom).offset(30);
        make.height.equalTo(@(184));
        make.width.equalTo(@(278));
    }];
    
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topTmageView).offset(25);
        make.left.equalTo(topTmageView).offset(16);
        make.right.equalTo(topTmageView).offset(-16);
    }];
    
    [costLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(6);
        make.width.equalTo(topTmageView);
        make.height.equalTo(@(85));
        make.left.equalTo(topTmageView);
    }];
    
    UIView *costMessageView = [UIView new];
    costMessageView.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
    [self.view addSubview:costMessageView];
    
    UILabel *costMessageLabel = [UILabel new];
    costMessageLabel.text = _result[@"costMessage"];
    costMessageLabel.textColor = [UIColor colorWithHex:0x111111];
    costMessageLabel.font = [UIFont systemFontOfSize:14];
    costMessageLabel.numberOfLines = 0;
    [costMessageView addSubview:costMessageLabel];
    
    UIImageView *bottomImageView = [UIImageView new];
    bottomImageView.image = [UIImage imageNamed:@"bg_ticket_event_bottom"];
    [self.view addSubview:bottomImageView];
    
    [costMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topTmageView.mas_bottom);
        make.width.equalTo(topTmageView.mas_width);
        make.bottom.equalTo(costMessageLabel).offset(16);
        make.left.equalTo(topTmageView);
    }];
    
    [costMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(costMessageView).offset(16);
        make.left.equalTo(costMessageView).offset(16);
        make.right.equalTo(costMessageView.mas_right).offset(-16);
    }];
    
    [bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topTmageView);
        make.top.equalTo(costMessageView.mas_bottom);
        make.height.equalTo(@(20));
        make.width.equalTo(topTmageView.mas_width);
    }];
}

- (CGFloat)getTextHeightWithString:(NSString *)string
                          withFont:(UIFont *)font
                         withWidth:(CGFloat)width{
    CGRect textFrame = [string boundingRectWithSize:CGSizeMake(width, MAX_CANON) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    return textFrame.size.height;
}

@end
