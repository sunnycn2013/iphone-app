//
//  OSCCodeSnippetDetailController.h
//  iosapp
//
//  Created by wupei on 2017/5/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCCodeSnippetListModel.h"

@interface OSCCodeSnippetDetailController : UIViewController

@property (nonatomic, copy)   NSString *idStr;//
@property (nonatomic, copy)   NSString *path;
@property (strong, nonatomic) NSString *fileName;

@property (strong, nonatomic) NSString *content;


- (instancetype)initWithContentIdStr:(NSString *)idStr;

@property (nonatomic,strong) OSCCodeSnippetListModel * detailModel;

@end
