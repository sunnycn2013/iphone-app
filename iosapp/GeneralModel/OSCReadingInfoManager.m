//
//  OSCReadingInfoManager.m
//  iosapp
//
//  Created by wupei on 2017/5/4.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCReadingInfoManager.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "UIDevice+SystemInfo.h"
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>
#import "OSCUserItem.h"
#import "Config.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import <sys/utsname.h>
#import "AFHTTPRequestOperationManager+Util.h"

#define kUploadTime @"uplaodTime"


@interface OSCReadingInfoManager ()<BMKLocationServiceDelegate>

@property (nonatomic, assign) NSUInteger lastIdInt;//当次上传的记录ID

@end

@implementation OSCReadingInfoManager

static OSCReadingInfoManager * _shareManager ;

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [OSCReadingInfoManager new];
//        [_shareManager deleteTable];
        [_shareManager createTable];//默认创建表
    });
    return _shareManager;
};


/** 所有字段 */
// uuid user url start_time net_state location read_time comment
// collected share phone_version sys_version client_version

//建立数据库和readinginfo表
- (void)createTable{
    debugMethod();
    NSFileManager * fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:self.dbPath] == NO) {//数据库文件不存在
        // create it
        FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
        if ([db open]) {
            NSString * sql = @"CREATE TABLE if not EXISTS 'readinginfo' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'uuid' VARCHAR(30), 'user' INTEGER,'user_name' VARCHAR(30),'operation' VARCHAR(30),'operate_type' INTEGER,'url' VARCHAR(30), 'start_time' VARCHAR(30),'net_state' VARCHAR(30),'location' VARCHAR(30),'read_time' INTEGER, comment INTEGER,'collected' INTEGER, 'voteup' INTEGER, 'share' INTEGER,'phone_version' VARCHAR(30),'sys_version' VARCHAR(30),'client_version' VARCHAR(30))";
            BOOL res = [db executeUpdate:sql];
            if (!res) {
                NSLog(@"error when creating db table");
            } else {
                NSLog(@"succ to creating db table");
            }
            [db close];
        } else {
            NSLog(@"error when open db");
        }
//    }
}

- (void)insertDataWithInfoModel:(ReadingInfoModel *)infoM {
    /** 所有字段 */
    // uuid user url start_time net_state location read_time comment
    // collected share phone_version sys_version client_version

    //基本的信息
    ReadingInfoModel *basicM = [self getSystemInfo];
    
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString * sql = @"insert into readinginfo (uuid, 'user', user_name, operation, operate_type, url, start_time, net_state, location, read_time, comment, voteup, collected, share, phone_version, sys_version, client_version) values(?,?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
        
        BOOL res = [db executeUpdate:sql,infoM.uuid,@(infoM.user),infoM.user_name,infoM.operation, @(infoM.operate_type),infoM.url, @(infoM.operate_time), basicM.network, basicM.location,@(infoM.stay), infoM.is_comment, infoM.is_voteup, infoM.is_collect, infoM.is_share, basicM.device, basicM.os, basicM.version];
        
        if (!res) {
            NSLog(@"error to insert data");
        } else {
            NSLog(@"succ to insert data");
        }
        [db close];
    }
}

- (NSMutableArray <ReadingInfoModel *> *)queryData {
    debugMethod();
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    NSMutableArray <ReadingInfoModel *> *dicArr = [[NSMutableArray alloc] init];//存放数组
    if ([db open]) {
        NSString * sql = @"select * from readinginfo";
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            ReadingInfoModel *readM = [[ReadingInfoModel alloc] init];//临时存储对象
            readM.primaryId = [rs intForColumn:@"id"];
            readM.uuid = [rs stringForColumn:@"uuid"];
            readM.user = [rs intForColumn:@"user"];
            readM.user_name = [rs stringForColumn:@"user_name"];
            readM.operation = [rs stringForColumn:@"operation"];//操作备注
            readM.operate_type = [rs intForColumn:@"operate_type"];//操作类型
            readM.url = [rs stringForColumn:@"url"];
            readM.operate_time = [rs intForColumn:@"start_time"];
            readM.network = [rs stringForColumn:@"net_state"];
            readM.location = [rs stringForColumn:@"location"];
            readM.stay = [rs intForColumn:@"read_time"];
            readM.is_comment = [rs intForColumn:@"comment"];
            readM.is_voteup = [rs intForColumn:@"voteup"];
            readM.is_collect = [rs intForColumn:@"collected"];
            readM.is_share = [rs intForColumn:@"share"];
            readM.device = [rs stringForColumn:@"phone_version"];
            readM.version = [rs stringForColumn:@"client_version"];
            readM.os = [rs stringForColumn:@"sys_version"];
            [dicArr addObject:readM];
        }
        [db close];
        
    }
    return dicArr;
}


- (void)updateInfoWithSql:(NSString *)sql {
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
//                BOOL result = [db executeUpdate:@"UPDATE readinginfo SET name = ?,phoneNum = ? WHERE phoneNum = ?",readInfoM.name,readInfoM.phoneNum,readInfoM.phoneNum];
        BOOL result = [db executeUpdate:sql];
                if (result) {
                    NSLog(@"修改成功");
                }
                else
                {
                    NSLog(@"修改失败");
                } [db close];
    }else{
        NSLog(@"数据库打开失败");
    }

}


- (void)clearWithSql:(NSString *)sql {
    FMDatabase * db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
//        NSString * sql = @"delete from readinginfo";
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error to delete db data");
        } else {
            NSLog(@"succ to deleta db data");
        }
        [db close];
    }
}


- (void)uploadReadingInfoWith:(NSArray <ReadingInfoModel *>*)arrDic {

    self.lastIdInt = [arrDic lastObject].primaryId;

    NSDictionary *jsonDic = [self convertJsonStr:arrDic];
    
//    http://61.145.122.155:8080/apiv2/user_behaviors_collect/add
    
    NSString *urlStr = [NSString stringWithFormat:@"http://61.145.122.155:8080/apiv2/%@",OSCAPI_USER_BEHAVIORS_COLLECT_ADD];
    
//    OSCAPI_V2_PREFIX
    
//     NSString *urlStr = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_USER_BEHAVIORS_COLLECT_ADD];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager.requestSerializer setValue:Reading_Collect_Tiken forHTTPHeaderField:@"passcode"];
    
    [manager POST:urlStr  parameters:jsonDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        if (1 == [responseObject[@"code"] integerValue]) {
    
            //存储时间。上传时间到 NSdefault。启动APP时使用。
            [Config saveLastUploadTime:responseObject[@"time"]];
            
            //如果上传成功，依据最后一条id 清空已经上传的本地数据。
            NSString *clearSql = [NSString stringWithFormat:@"delete from readinginfo where id <= %ld",(unsigned long)self.lastIdInt];
            
            
            [self clearWithSql:clearSql];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"上传用户阅读信息失败%@",error);
    }];
}

- (NSDictionary *)convertJsonStr:(NSArray <ReadingInfoModel *>*)arrDic {
    //JSON 字符串作为参数
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *arrJson = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrDic count]; i++) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)arrDic[i].user]  forKey:@"user"];
        [dic setValue:arrDic[i].user_name  forKey:@"user_name"];
        [dic setValue:arrDic[i].operation forKey:@"operation"];
        [dic setValue:@(arrDic[i].operate_time) forKey:@"operate_time"];
        [dic setValue:@(arrDic[i].operate_type) forKey:@"operate_type"];
        [dic setValue:arrDic[i].uuid forKey:@"uuid"];
        [dic setValue:arrDic[i].url  forKey:@"url"];
        [dic setValue:arrDic[i].network forKey:@"network"];
        [dic setValue:arrDic[i].location forKey:@"location"];
        [dic setValue:[NSString stringWithFormat:@"%ld",(long)arrDic[i].stay] forKey:@"stay"];
        [dic setValue:@(arrDic[i].is_comment) forKey:@"is_comment"];
        [dic setValue:@(arrDic[i].is_voteup) forKey:@"is_voteup"];
        [dic setValue:@(arrDic[i].is_share) forKey:@"is_share"];
        [dic setValue:@(arrDic[i].is_collect) forKey:@"is_collect"];
        [dic setValue:arrDic[i].device forKey:@"device"];
        [dic setValue:arrDic[i].version forKey:@"version"];
        [dic setValue:arrDic[i].os forKey:@"os"];
        [arrJson addObject:dic];
    }
    NSData *data= [NSJSONSerialization dataWithJSONObject:arrJson options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [dictionary setObject:jsonStr  forKey:@"json"];
    
    return  dictionary;
}

- (ReadingInfoModel *)getSystemInfo {
    ReadingInfoModel *newM = [[ReadingInfoModel alloc] init];
    //1、获取网络状态
    NSString *netState = [self networkingStatesFromStatebar];
    //2、拿到城市
    OSCUserItem *author = [Config myNewProfile];
    NSString *city = author.more.city;

    //3、手机型号、系统版本
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    //  NSString *deviceCateory = kDeviceArray[[UIDevice currentDeviceResolution]];
    //  NSString *UUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    //4、客户端版本
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    newM.network = netState;
    newM.location = city;
    newM.os = systemVersion;
    newM.version = appVersion;
    newM.device = [self iphoneType];

    return  newM;
}

//网络状态处理
- (NSString *)networkingStatesFromStatebar {
    // 状态栏是由当前app控制的，首先获取当前app
    UIApplication *app = [UIApplication sharedApplication];
    
    NSArray *children = [[[app valueForKeyPath:@"statusBar"] valueForKeyPath:@"foregroundView"] subviews];
    
    int type = 0;
    for (id child in children) {
        if ([child isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            type = [[child valueForKeyPath:@"dataNetworkType"] intValue];
        }
    }
    
    NSString *stateString = @"wifi";
    
    switch (type) {
        case 0:
//            stateString = @"notReachable";
            stateString = nil;
            break;
            
        case 1:
            stateString = @"2G";
            break;
            
        case 2:
            stateString = @"3G";
            break;
            
        case 3:
            stateString = @"4G";
            break;
            
        case 4:
            stateString = @"LTE";
            break;
            
        case 5:
            stateString = @"wifi";
            break;
            
        default:
            break;
    }
    
    return stateString;
}


- (NSString *)iphoneType {
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPod Touch 1G";
    
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPod Touch 2G";
    
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPod Touch 3G";
    
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPod Touch 4G";
    
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPod Touch 5G";
    
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad 1G";
    
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad 2";
    
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPad Mini 1G";
    
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad 3";
    
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad 4";
    
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPad Mini 2G";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhone Simulator";
    
    if ([platform isEqualToString:@"x86_64"])    return @"iPhone Simulator";
    
    return platform;
    
}

- (void)deleteTable {
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    if ([db open]) {
        NSString *sql = @"drop table readinginfo";
        BOOL res = [db executeUpdate:sql];
        if (!res) {
            NSLog(@"error to drop db data");
        }else{
            NSLog(@"succ to drop db data");
        }
        [db close];
    }
}

/**
 懒加载

 @return 数据库路径
 */
- (NSString *)dbPath{
    NSString *doc =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * path = [doc stringByAppendingPathComponent:@"readinginfo.sqlite"];
    NSLog(@"dbpath%@",path);
    return path;
}


@end
