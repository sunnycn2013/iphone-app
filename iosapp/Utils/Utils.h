//
//  Utils.h
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "enumList.h"

#import "UIView+Util.h"
#import "UIColor+Util.h"
#import "UIImageView+Comment.h"
#import "UIImage+Comment.h"
#import "NSTextAttachment+Util.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "UINavigationController+Comment.h"
#import "NSDate+Comment.h"
#import "NSString+Comment.h"


typedef NS_ENUM(NSUInteger, hudType) {
    hudTypeSendingTweet,
    hudTypeLoading,
    hudTypeCompleted
};

@class MBProgressHUD,OSCMenuItem,YYTextView;

@interface Utils : NSObject

+ (NSString *)toHex:(long long int)tmpid;

+ (NSDictionary *)emojiDict;
+ (NSDictionary *)emojiIndexToNameDic;

+ (NSAttributedString *)getAppclient:(int)clientType;
+ (NSAttributedString *)getAppclientName:(int)clientType;

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews;
+ (NSString *)generateTags:(NSArray *)tags;

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString;
+ (NSAttributedString *)emojiStringFromAttrString:(NSAttributedString*)attrString;
+ (NSAttributedString *)attributedStringFromHTML:(NSString *)HTML;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString;
+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
                                  privateChatType:(BOOL)isSelf;
+ (NSData *)compressImage:(UIImage *)image;

+ (NSString *)convertRichTextToRawYYTextView:(YYTextView *)textView;
+ (NSString *)convertRichTextToRawText:(UITextView *)textView;
//用于假数据的转换
+ (NSString *)convertRichTextIndexToName:(UITextView *)textView;
+ (NSString *)convertRichTextIndexToNameWithYYTV:(YYTextView *)textView;
//用于私信界面的表情
+ (NSString *)convertStringToNameWithString:(NSString *)string;

+ (BOOL)isURL:(NSString *)string;
+ (NSInteger)networkStatus;
+ (BOOL)isNetworkExist;

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent;

+ (MBProgressHUD *)createHUD;
+ (UIImage *)createQRCodeFromString:(NSString *)string;

+ (NSAttributedString *)attributedTimeString:(NSDate *)date;
+ (NSAttributedString *)attributedCommentCount:(int)commentCount;

+ (NSAttributedString *)newTweetAttributedTimeString:(NSDate *)date;

+ (NSString *)HTMLWithData:(NSDictionary *)data usingTemplate:(NSString *)templateName;

+ (NSString *)numberLimitString:(int)number;

+ (UIImage*)createImageWithColor:(UIColor*) color;

+ (NSString *)sha1:(NSString *)input;

+ (NSString *)getCurrentTimeString;

///< 按钮边框线颜色
+ (void)setButtonBorder:(UIView *)view isFail:(BOOL)isFail isEditing:(BOOL)isEditing;
///< 检测是否为手机号
+ (BOOL)validateMobile:(NSString *)mobileNum;
///< 检测是否为邮箱地址
+ (BOOL)validateEmail:(NSString *)emailString;

///< image new
+ (UIImage *)imageWithColor:(UIColor *)color;

+ (NSString *) getAppToken;

///< 处理string 正则匹配进行tagString显示
+ (NSAttributedString* )handle_TagString:(NSString* )originStr
                                fontSize:(CGFloat)fontSize;


+(NSString *) shouldUploadLocation;
+(void) setShouldUploadLocation: (NSString *) yesOrNo;
+(NSString *)getUpLoadExtInfo;


@end



@interface Utils (UserContacter)

+ (void)getNomalAttentionContacterAndSaveToAttentionContacter;

@end



@interface Utils (MessageCenter)

+ (void)sendRequest2MsgCountInterface:(MsgCountType)msgCountType;

+ (void)beforehandSend_AtMe_List_Request;

+ (void)beforehandSend_Comment_List_Request;

+ (void)beforehandSend_Chat_List_Request;

@end



@interface Utils (SubMenuManger)

/** 定制化分栏*/
///获取全部本固定的 menuNames && meunTokens
+ (NSArray<NSString* >* )fixedLocalMenuNames;
+ (NSArray<NSString* >* )fixedLocalMenuTokens;
///获取全部本地的 menuNames && meunTokens
+ (NSArray<NSString* >* )allLocalMenuNames;
+ (NSArray<NSString* >* )allLocalMenuTokens;

///获取全部已选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allSelectedMenuNames;
+ (NSArray<NSString* >* )allSelectedMenuTokens;

///获取全部未选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allUnselectedMenuNames;
+ (NSArray<NSString* >* )allUnselectedMenuTokens;

+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuNames:(NSArray<NSString* >* )menuNames;
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuTokens:(NSArray<NSString* >* )menuTokens;
+ (NSArray<NSString* >* )conversionMenuTokensWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems;
+ (NSArray<NSString* >* )conversionMenuNamesWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems;

+ (void)updateLocalMenuList;
+ (void)updateUserSelectedMenuListWithMenuItems:(NSArray<OSCMenuItem* >* )newUserMenuList_items;
+ (void)updateUserSelectedMenuListWithMenuTokens:(NSArray<NSString* >* )newUserMenuList_tokens;
+ (void)updateUserSelectedMenuListWithMenuNames:(NSArray<NSString* >* )newUserMenuList_names;


/** 过渡版分栏读写接口*/
//+ (NSArray<NSString* >* )allSelected_MenuNames;
//+ (NSArray<NSString* >* )allUnselected_MenuNames;
//+ (void)updateUserSelectedMenuList_With_MenuNames:(NSArray<NSString* >* )newUserMenuList_names;
//+ (NSArray<OSCMenuItem* >* )conversionMenuItems_With_MenuNames:(NSArray<NSString* >* )menuNames;

@end






