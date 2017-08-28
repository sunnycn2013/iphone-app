//
//  OSCNearByPeopleModel.h
//  iosapp
//
//  Created by 王恒 on 17/1/11.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "enumList.h"
#import "OSCUserItem.h"

@class OSCNearByPeopleMore;
@interface OSCNearByPeopleModel : NSObject

@property (nonatomic,assign) NSInteger id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *portrait;
@property (nonatomic,assign) UserGenderType gender;
@property (nonatomic,strong) OSCNearByPeopleMore *more;
@property (nonatomic,assign) NSUInteger meters;
@property (nonatomic,strong) OSCUserIdentity *identity;

@end

@interface OSCNearByPeopleMore : NSObject

@property (nonatomic,strong) NSString *company;

@end
