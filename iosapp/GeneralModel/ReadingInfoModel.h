//
//  ReadingInfoModel.h
//  iosapp
//
//  Created by wupei on 2017/5/4.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "OSCAPI.h"

//1   project
//2   question
//3   blog
//4   translate
//5
//6   news
typedef NS_ENUM(NSInteger,OperateType ){
    OperateTypeProject = 1,
    OperateTypeQuestion,
    OperateTypeBlog,
    OperateTypeTranslate,
    OperateTypeNews = 6,
};

@interface ReadingInfoModel : NSObject

//数据库主键自增id
@property (nonatomic, assign) NSInteger primaryId;
//设备标识
@property (nonatomic, strong) NSString *uuid;
//登录用户id
@property (nonatomic, assign) NSInteger user;
//用户名
@property (nonatomic, strong) NSString *user_name;
//操作备注
@property (nonatomic, strong) NSString *operation;// read
//消息类型
@property (nonatomic, assign) OperateType operate_type;// 1 2 3 4 5.
//开始阅读时间
@property (nonatomic, assign) NSInteger operate_time;//时间戳字符串
//阅读停留时间 单位秒
@property (nonatomic, assign) NSInteger stay;
//文档URL
@property (nonatomic, strong) NSString *url;
//网络状态
@property (nonatomic, strong) NSString *network;
//地址
@property (nonatomic, strong) NSString *location;
//是否评论
@property (nonatomic, assign) NSInteger is_comment;
//是否点赞
@property (nonatomic, assign) NSInteger is_voteup;
//是否收藏
@property (nonatomic, assign) NSInteger is_collect;
//是否分享
@property (nonatomic, assign) NSInteger is_share;
//手机型号
@property (nonatomic, strong) NSString *device;
//操作系统版本
@property (nonatomic, strong) NSString *os;
//客户端版本
@property (nonatomic, strong) NSString *version;


@end
