//
//  OSCActivityApplyModel.h
//  iosapp
//
//  Created by 李萍 on 2016/12/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

@interface OSCActivityApplyModel : NSObject

@property (nonatomic, copy)   NSString *key;
@property (nonatomic, assign) EventApplyPreloadKeyType keyType;
@property (nonatomic, assign) EventApplyPreloadFormType formType;
@property (nonatomic, copy)   NSString *label;
@property (nonatomic, copy)   NSString *option;
@property (nonatomic, copy)   NSString *optionStatus;
@property (nonatomic, copy)   NSString *defaultValue;
@property (nonatomic, assign) BOOL required;

@end

//option
@interface SelectOption : NSObject

@property (nonatomic, copy) NSString *optionTitle;
@property (nonatomic, assign) NSInteger optionStatus;
//@property (nonatomic, assign) EventApplyPreloadFormType formType;

@end
