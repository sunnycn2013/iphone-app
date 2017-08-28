//
//  Model.h
//  iosapp
//
//  Created by Graphic-one on 16/12/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"

@class OSCMsgCount;
/** model泛型 */
@interface Model : NSObject

@property (nonatomic,assign) NSInteger code;

@property (nonatomic,strong) NSString* message;

@property (nonatomic,strong) NSString* time;

@property (nonatomic,strong) id result;

@property (nonatomic,strong) OSCMsgCount* msgCount;

@end
