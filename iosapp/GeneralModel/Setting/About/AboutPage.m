//
//  AboutPage.m
//  iosapp
//
//  Created by chenhaoxiang on 3/6/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AboutPage.h"
#import "Utils.h"
#import "OSLicensePage.h"
#import "KeyViewController.h"

#import <Masonry.h>

@interface AboutPage ()

@end

@implementation AboutPage

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"关于我们";
    self.view.backgroundColor = [UIColor themeColor];
    
    UIImageView *logo = [UIImageView new];
    logo.contentMode = UIViewContentModeScaleAspectFit;
    logo.image = [UIImage imageNamed:@"logo"];
	logo.userInteractionEnabled = YES;
	UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickedOnLogo)];
	tap.numberOfTapsRequired = 10;
	[logo addGestureRecognizer:tap];
    [self.view addSubview:logo];
    
    UILabel *declarationLabel = [UILabel new];
    declarationLabel.numberOfLines = 0;
    declarationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    declarationLabel.textAlignment = NSTextAlignmentCenter;
    declarationLabel.textColor = [UIColor lightGrayColor];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    declarationLabel.text = [NSString stringWithFormat:@"%@ (%@) \n©2017 oschina.net.\nAll rights reserved.", version,build];
    [self.view addSubview:declarationLabel];
    
    UILabel *OSLicenseLabel = [UILabel new];
    OSLicenseLabel.textColor = [UIColor colorWithHex:0x4169E1];
    OSLicenseLabel.text = @"开源许可";
    OSLicenseLabel.userInteractionEnabled = YES;
    [OSLicenseLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickOSLicenseLabel)]];
    [self.view addSubview:OSLicenseLabel];
    
    [logo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(-90);
        make.centerX.equalTo(self.view);
        make.height.equalTo(@(80));
        make.bottom.equalTo(declarationLabel.mas_top).offset(-20);
        make.width.equalTo(@(80));
    }];
    
    [declarationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(200));
        make.centerX.equalTo(self.view);
    }];
    
    [OSLicenseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-50);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)clickedOnLogo
{
	[self.navigationController pushViewController:[KeyViewController new] animated:YES];
}

- (void)onClickOSLicenseLabel
{
    [self.navigationController pushViewController:[OSLicensePage new] animated:YES];
}



@end
