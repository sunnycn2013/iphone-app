//
//  OSCReadingInfoManager.h
//  iosapp
//
//  Created by wupei on 2017/5/4.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ReadingInfoModel.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"


/**
 负责搜集用户行为信息
 */

@interface OSCReadingInfoManager : NSObject

@property (nonatomic, copy)   NSString * dbPath;//数据库地址

@property (nonatomic, copy)   NSString * fileName;//


@property (nonatomic, strong) FMDatabase *dataBase;//数据库对象


//单例生成一个manager
+ (instancetype)shareManager;

/** 网络状态 */
- (NSString *)networkingStatesFromStatebar;

//处理网络状态、地址定位、手机型号、系统版本、客户端版本
- (ReadingInfoModel *)getSystemInfo;

/** 数据库的增 */ 
- (void)insertDataWithInfoModel:(ReadingInfoModel *)infoM ;

/** 取出表中所有记录 */
- (NSMutableArray <ReadingInfoModel *> *)queryData;

/** 依据SQL进行更新  */
- (void)updateInfoWithSql:(NSString *)sql;


/**
 数据上传服务器 本地缓存的时间 数据是否超过15条。
 @return
 */
- (void)uploadReadingInfoWith:(NSArray <ReadingInfoModel *>*)arr;

/** 上传成功后，清空数据 */
- (void)clearWithSql:(NSString *)sql;

/** 删除表 */
- (void)deleteTable;
@end
