//
//  SoftWareDetailBodyCell.m
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "SoftWareDetailBodyCell.h"
#import "Utils.h"
#import "OSCListItem.h"

#define kScreenSize [UIScreen mainScreen].bounds.size

@interface SoftWareDetailBodyCell ()
@property (weak, nonatomic) IBOutlet UILabel *softWareAuthorNameLb;
@property (weak, nonatomic) IBOutlet UILabel *openSourceProtocolLb;
@property (weak, nonatomic) IBOutlet UILabel *devLanguageNameLb;
@property (weak, nonatomic) IBOutlet UILabel *systemNameLb;
@property (weak, nonatomic) IBOutlet UILabel *includedDateLb;
@end

@implementation SoftWareDetailBodyCell
-(void)awakeFromNib{
    [super awakeFromNib];
    
    _webView.scrollView.bounces = NO;
    _webView.scrollView.scrollEnabled = NO;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor whiteColor];
    
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"webViewClickImageFunction.js" ofType:nil]encoding:NSUTF8StringEncoding error:nil]];
}



#pragma mark --- configuration License Info
-(void)configurationRelatedInfo:(OSCListItem *)softWareModel{
    _softWareAuthorNameLb.text = softWareModel.author.name.length ? softWareModel.author.name : @"匿名";
	_softWareAuthorNameLb.userInteractionEnabled = YES;
    _openSourceProtocolLb.text = softWareModel.extra.softwareLicense.length ? softWareModel.extra.softwareLicense : @"未知";
    _devLanguageNameLb.text = softWareModel.extra.softwareLanguage.length ? softWareModel.extra.softwareLanguage : @"未知";
    _systemNameLb.text = softWareModel.extra.softwareSupportOS.length ? softWareModel.extra.softwareSupportOS : @"未知";
    _includedDateLb.text = softWareModel.extra.softwareCollectionDate.length ? softWareModel.extra.softwareCollectionDate : @"未知";
}

-(void)configurationRelatedInfo:(OSCListItem* )softWareModel tapGesture:(UITapGestureRecognizer *)tap
{
    _softWareAuthorNameLb.text = softWareModel.author.name.length ? softWareModel.author.name : @"匿名";
	_softWareAuthorNameLb.userInteractionEnabled = YES;
    _openSourceProtocolLb.text = softWareModel.extra.softwareLicense.length ? softWareModel.extra.softwareLicense : @"未知";
    _devLanguageNameLb.text = softWareModel.extra.softwareLanguage.length ? softWareModel.extra.softwareLanguage : @"未知";
    _systemNameLb.text = softWareModel.extra.softwareSupportOS.length ? softWareModel.extra.softwareSupportOS : @"未知";
    _includedDateLb.text = softWareModel.extra.softwareCollectionDate.length ? softWareModel.extra.softwareCollectionDate : @"未知";
	[_softWareAuthorNameLb addGestureRecognizer:tap];
}

@end
