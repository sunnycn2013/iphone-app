//
//  OSCGitDetailModel.m
//  iosapp
//
//  Created by 王恒 on 17/3/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCGitDetailModel.h"

#import <NSObject+YYModel.h>

@implementation OSCGitDetailModel

+ (NSDictionary *)modelCustomPropertyMapper{
    return @{@"git_description":@"description",
             @"git_public":@"public",
             @"git_namespace":@"namespace"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"owner":[GitOwner class],
             @"git_namespace":[GitNameSpace class]};
}

@end
