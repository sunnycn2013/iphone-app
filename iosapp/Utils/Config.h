//
//  Config.h
//  iosapp
//
//  Created by chenhaoxiang on 11/6/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class OSCUser;
@class OSCUserItem;
@class OSCMsgCount;

@interface Config : NSObject

+ (void)saveOwnAccount:(NSString *)account;

+ (void)saveName:(NSString *)actorName sex:(NSInteger)sex phoneNumber:(NSString *)phoneNumber corporation:(NSString *)corporation andPosition:(NSString *)position;

+ (void)clearCookie;

+ (NSString *)getOwnAccount;
+ (NSInteger)getOwnID;
+ (NSString *)getOwnUserName;
+ (NSArray *)getActivitySignUpInfomation;
+ (UIImage *)getPortrait;

+ (void)saveTweetText:(NSString *)tweetText forUser:(ino64_t)userID;
+ (NSString *)getTweetText;

+ (int)teamID;
+ (void)setTeamID:(int)teamID;
+ (void)saveTeams:(NSArray *)teams;
+ (NSMutableArray *)teams;
+ (void)removeTeamInfo;

/** OSCMsgCount handle */
+ (void)saveMsgCount:(OSCMsgCount* )msgCount;
+ (OSCMsgCount* )getCurMsgCount;

//new userItem
+ (void)saveNewProfile:(OSCUserItem *)user;
+ (void)updateNewProfile:(OSCUserItem *)user;
+ (void)clearNewProfile;
+ (OSCUserItem *)myNewProfile;


//阅读信息上传时间
+ (void)saveLastUploadTime:(NSString *)timeStr;
+ (NSString *)getLastUploadTime;

@end
