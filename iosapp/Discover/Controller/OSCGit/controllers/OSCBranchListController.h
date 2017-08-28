//
//  OSCBranchListController.h
//  iosapp
//
//  Created by Graphic-one on 17/3/13.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCGitDetailModel;

@interface OSCBranchListController : UIViewController

- (instancetype)initWithPath:(NSString* )path refName:(NSString* )refName projectId:(NSUInteger)id;

@property (nonatomic,strong) OSCGitDetailModel* detailModel;

@end
