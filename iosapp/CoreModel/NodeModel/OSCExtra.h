//
//  OSCExtra.h
//  iosapp
//
//  Created by Graphic-one on 16/12/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

@interface OSCExtra : NSObject

/** 活动相关 额外参数*/
@property (nonatomic, strong) NSString* eventStartDate;

@property (nonatomic, strong) NSString* eventEndDate;

@property (nonatomic, assign) NSInteger eventApplyCount;

@property (nonatomic, assign) ApplyStatus eventApplyStatus;

@property (nonatomic, assign) ActivityStatus eventStatus;

@property (nonatomic, assign) ActivityType eventType;

@property (nonatomic, strong) NSString* eventLocation;

@property (nonatomic, strong) NSString* eventProvince;
@property (nonatomic, strong) NSString* eventCity;
@property (nonatomic, strong) NSString* eventSpot;

@property (nonatomic, strong) NSString* eventCostDesc;


/** 翻译相关 额外参数*/
@property (nonatomic, strong) NSString* translationTitle;


/** 博客相关 额外参数*/
@property (nonatomic, strong) NSString* blogCategory;

@property (nonatomic, strong) NSString* blogPayNotify;


/** 软件相关 额外参数*/
@property (nonatomic, strong) NSString* softwareLicense;
@property (nonatomic, strong) NSString* softwareHomePage;
@property (nonatomic, strong) NSString* softwareDocument;
@property (nonatomic, strong) NSString* softwareDownload;

@property (nonatomic, strong) NSString* softwareLanguage;
@property (nonatomic, strong) NSString* softwareSupportOS;
@property (nonatomic, strong) NSString* softwareCollectionDate;
@property (nonatomic, strong) NSString* softwareIdentification;

@property (nonatomic, strong) NSString* softwareName;
@property (nonatomic, assign) NSInteger softwareStar;
@property (nonatomic, assign) NSInteger   softwareScore;
@property (nonatomic, strong) NSString* softwareTitle;

@end
















