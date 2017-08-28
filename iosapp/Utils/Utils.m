//
//  Utils.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-16.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "AppDelegate.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"

#import "OSCModelHandler.h"
#import "OSCMenuItem.h"
#import "OSCListItem.h"
#import "OSCMsgCount.h"
#import "OSCUserItem.h"

#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "NSObject+Comment.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <CommonCrypto/CommonDigest.h>
#import <MBProgressHUD.h>
#import <objc/runtime.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <GRMustache.h>
#import <DTCoreText.h>


#define keyShouldUploadLocation @"k_should_upload_location_to_server"

@implementation Utils

#pragma mark - 处理API返回信息

+ (NSAttributedString *)getAppclient:(int)clientType
{
    NSMutableAttributedString *attributedClientString;
    if (clientType > 1 && clientType <= 6) {
        NSArray *clients = @[@"", @"", @"手机", @"Android", @"iPhone", @"Windows Phone", @"微信"];
        
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:[NSString fontAwesomeIconStringForEnum:FAMobile]
                                                                        attributes:@{
                                                                                     NSFontAttributeName: [UIFont fontAwesomeFontOfSize:13],
                                                                                     }];
        
        [attributedClientString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", clients[clientType]]]];
    } else {
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    return attributedClientString;
}


+ (NSAttributedString *)getAppclientName:(int)clientType
{
    NSMutableAttributedString *attributedClientString;
    if (clientType > 1 && clientType <= 6) {
        NSArray *clients = @[@"", @"", @"手机", @"Android", @"iPhone", @"Windows Phone", @"微信"];
        
        
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", clients[clientType]]];

    } else {
        attributedClientString = [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    return attributedClientString;
}

+ (NSString *)generateRelativeNewsString:(NSArray *)relativeNews
{
    if (relativeNews == nil || [relativeNews count] == 0) {
        return @"";
    }
    
    NSString *middle = @"";
    for (NSArray *news in relativeNews) {
        middle = [NSString stringWithFormat:@"%@<a href=%@>%@</a><p/>", middle, news[1], news[0]];
    }
    return [NSString stringWithFormat:@"相关文章<div style='font-size:14px'><p/>%@</div>", middle];
}

+ (NSString *)generateTags:(NSArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    } else {
        NSString *result = @"";
        for (NSString *tag in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;", result, tag, tag];
        }
        return result;
    }
}




#pragma mark - 通用

+ (NSString *)toHex:(long long int)tmpid
{
    NSString* nLetterValue;
    NSString* str = @"";
    
    int ttmpig;
    
    for (int i = 0; i < 9; i++) {
        ttmpig = tmpid % 16;
        tmpid  = tmpid / 16;
        
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";
                break;
            case 11:
                nLetterValue =@"B";
                break;
            case 12:
                nLetterValue =@"C";
                break;
            case 13:
                nLetterValue =@"D";
                break;
            case 14:
                nLetterValue =@"E";
                break;
            case 15:
                nLetterValue =@"F";
                break;
                
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
        }
        
        str = [nLetterValue stringByAppendingString:str];
        
        if (tmpid == 0) { break; }
        
    }

    if(str.length == 1){
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
    
//    NSString *nLetterValue;
//    
//    NSString *str =@"";
//    
//    long long int ttmpig;
//    
//    for (int i = 0; i<9; i++) {
//        
//        ttmpig=tmpid%16;
//        
//        tmpid=tmpid/16;
//        
//        switch (ttmpig)
//        
//        {
//                
//            case 10:
//                
//                nLetterValue =@"A";break;
//                
//            case 11:
//                
//                nLetterValue =@"B";break;
//                
//            case 12:
//                
//                nLetterValue =@"C";break;
//                
//            case 13:
//                
//                nLetterValue =@"D";break;
//                
//            case 14:
//                
//                nLetterValue =@"E";break;
//                
//            case 15:
//                
//                nLetterValue =@"F";break;
//                
//            default:nLetterValue=[[NSString alloc]initWithFormat:@"%lli",ttmpig];
//                
//                
//                
//        }
//        
//        str = [nLetterValue stringByAppendingString:str];
//        
//        if (tmpid == 0) {
//            
//            break;  
//            
//        }  
//    }
//    return str;
    
}

#pragma mark - emoji Dictionary

+ (NSDictionary *)emojiDict
{
    static dispatch_once_t once;
    static NSDictionary *emojiDict;
    
    dispatch_once(&once, ^ {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"emoji" ofType:@"plist"];
        emojiDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    });
    
    return emojiDict;
}

+ (NSDictionary *)emojiIndexToNameDic{
    static dispatch_once_t once;
    static NSDictionary *emojiIndexToNameDic;
    
    dispatch_once(&once, ^{
        NSString *path = [[NSBundle mainBundle] pathForResource:@"emojiIndexToName" ofType:@"plist"];
        emojiIndexToNameDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    });
    return emojiIndexToNameDic;
}

#pragma mark 信息处理

+ (NSAttributedString *)attributedTimeString:(NSDate *)date
{
    NSString *rawString = [date timeAgoSince];
    
    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:rawString
                                                                         attributes:@{
                                                                                      NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
                                                                                      }];
    
    return attributedTime;
}

+ (NSAttributedString *)newTweetAttributedTimeString:(NSDate *)date
{
    NSAttributedString *attributedTime = [[NSAttributedString alloc] initWithString:[date timeAgoSince]
                                                                         attributes:@{
                                                                                      NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
                                                                                      }];
    
    return attributedTime;
}

// 参考 http://www.cnblogs.com/ludashi/p/3962573.html

+ (NSAttributedString *)emojiStringFromRawString:(NSString *)rawString
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:rawString attributes:nil];
    return [Utils emojiStringFromAttrString:attrString];
}

+ (NSAttributedString *)emojiStringFromAttrString:(NSAttributedString*)attrString
{
    NSMutableAttributedString *emojiString = [[NSMutableAttributedString alloc] initWithAttributedString:attrString];
    NSDictionary *emoji = self.emojiDict;

    NSString *pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]|:[a-zA-Z0-9\\u4e00-\\u9fa5_]+:";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:attrString.string options:0 range:NSMakeRange(0, attrString.string.length)];
    
    NSMutableArray *emojiArray = [NSMutableArray arrayWithCapacity:resultsArray.count];
	
    
    for (NSTextCheckingResult *match in resultsArray) {
        NSRange range = [match range];
        NSString *emojiName = [attrString.string substringWithRange:range];
        
        if ([emojiName hasPrefix:@"["] && emoji[emojiName]) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            if ([UIImage imageNamed:emoji[emojiName]]) {
                textAttachment.image = [UIImage imageNamed:emoji[emojiName]];
                [textAttachment adjustY:-3];
                objc_setAssociatedObject( textAttachment, @"emoji", emojiName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
            }else{
                NSAttributedString *alertString = [[NSAttributedString alloc] initWithString:emojiName];
                [emojiArray addObject: @{@"image": alertString, @"range": [NSValue valueWithRange:range]}];
            }
        } else if ([emojiName hasPrefix:@":"]) {
            if (emoji[emojiName]) {
                [emojiArray addObject:@{@"text": emoji[emojiName], @"range": [NSValue valueWithRange:range]}];
            } else {
                UIImage *emojiImage = [UIImage imageNamed:[emojiName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]]];
                if (emojiImage) {
                    NSTextAttachment *textAttachment = [NSTextAttachment new];
                    textAttachment.image = emojiImage;
                    [textAttachment adjustY:-3];
                    objc_setAssociatedObject(textAttachment, @"emoji", emojiName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                    [emojiArray addObject: @{@"image": emojiAttributedString, @"range": [NSValue valueWithRange:range]}];
                }else{
                    NSAttributedString *alertString = [[NSAttributedString alloc] initWithString:emojiName];
                    [emojiArray addObject: @{@"image": alertString, @"range": [NSValue valueWithRange:range]}];
                }
            }
        }
    }
    
    for (NSInteger i = emojiArray.count -1; i >= 0; i--) {
        NSRange range;
        [emojiArray[i][@"range"] getValue:&range];
        if (emojiArray[i][@"image"]) {
            [emojiString replaceCharactersInRange:range withAttributedString:emojiArray[i][@"image"]];
        } else {
            [emojiString replaceCharactersInRange:range withString:emojiArray[i][@"text"]];
        }
    }
    
    return emojiString;
}

+ (NSAttributedString *)attributedStringFromHTML:(NSString *)html
{
    if (![html hasPrefix:@"<"]) {
        html = [NSString stringWithFormat:@"<span>%@</span>", html]; // DTCoreText treat raw string as <p> element
    }
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    return [[NSAttributedString alloc] initWithHTMLData:data options:@{ DTUseiOS6Attributes: @YES}
                                     documentAttributes:nil];
}

+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    NSMutableAttributedString *mutableAttrString = [[Utils emojiStringFromAttrString:attrString] mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, mutableAttrString.length)];
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, mutableAttrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
}

+ (NSAttributedString*)contentStringFromRawString:(NSString*)rawString
                                  privateChatType:(BOOL)isSelf
{
    if (!rawString || rawString.length == 0) return [[NSAttributedString alloc] initWithString:@""];
    
    NSAttributedString *attrString = [Utils attributedStringFromHTML:rawString];
    NSMutableAttributedString *mutableAttrString = [[Utils emojiStringFromAttrString:attrString] mutableCopy];
    [mutableAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, mutableAttrString.length)];
    if (isSelf) {
        [mutableAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, mutableAttrString.length)];
    }else{
        [mutableAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, mutableAttrString.length)];
    }
    
    // remove under line style
    [mutableAttrString beginEditing];
    [mutableAttrString enumerateAttribute:NSUnderlineStyleAttributeName
                                  inRange:NSMakeRange(0, mutableAttrString.length)
                                  options:0
                               usingBlock:^(id value, NSRange range, BOOL *stop) {
                                   if (value) {
                                       [mutableAttrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleNone) range:range];
                                   }
                               }];
    [mutableAttrString endEditing];
    
    return mutableAttrString;
}

+ (NSString *)convertRichTextToRawYYTextView:(YYTextView *)textView
{
    if (!textView.text || [textView.text isEqual:[NSNull null]] || textView.text.length <= 0) return nil;
    
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    
    NSString *pattern = @"[\ue000-\uf8ff]|[\\x{1f300}-\\x{1f7ff}]|\\x{263A}\\x{FE0F}|☺";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emojiToText" ofType:@"plist"];
    NSDictionary *emojiToText = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        NSString *emoji = [textView.text substringWithRange:match.range];
        if(!emojiToText[emoji]){
            [rawText replaceCharactersInRange:match.range withString:@"[表情]"];
        }else{
            [rawText replaceCharactersInRange:match.range withString:emojiToText[emoji]];
        }
    }

    [textView.attributedText enumerateAttribute:YYTextAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(YYTextAttachment *attachment, NSRange range, BOOL *stop) {
                                         if (attachment) {
                                             NSString *emojiStr = attachment.userInfo[@"emoji"];
                                             [rawText insertString:emojiStr atIndex:range.location];
                                         }
                                     }];
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSString *)convertRichTextToRawText:(UITextView *)textView
{
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    
    NSString *pattern = @"[\ue000-\uf8ff]|[\\x{1f300}-\\x{1f7ff}]|\\x{263A}\\x{FE0F}|☺";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:textView.text options:0 range:NSMakeRange(0, textView.text.length)];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emojiToText" ofType:@"plist"];
    NSDictionary *emojiToText = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        NSString *emoji = [textView.text substringWithRange:match.range];
        if(!emojiToText[emoji]){
            [rawText replaceCharactersInRange:match.range withString:@"[表情]"];
        }else{
            [rawText replaceCharactersInRange:match.range withString:emojiToText[emoji]];
        }
    }
    
    
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(NSTextAttachment *attachment, NSRange range, BOOL *stop) {
                                         if (!attachment) {return;}
                                         
                                         NSString *emojiStr = objc_getAssociatedObject(attachment, @"emoji");
                                         [rawText insertString:emojiStr atIndex:range.location];
                                     }];
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSString *)convertRichTextIndexToName:(UITextView *)textView{
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    NSString *pattern = @"[\ue000-\uf8ff]|[\\x{1f300}-\\x{1f7ff}]|\\x{263A}\\x{FE0F}|☺";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:rawText options:0 range:NSMakeRange(0, textView.text.length)];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emojiToText" ofType:@"plist"];
    NSDictionary *emojiToText = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        NSString *emoji = [textView.text substringWithRange:match.range];
        if(!emojiToText[emoji]){
            [rawText replaceCharactersInRange:match.range withString:@"[表情]"];
        }else{
            [rawText replaceCharactersInRange:match.range withString:emojiToText[emoji]];
        }
    }
    [textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, textView.attributedText.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        NSTextAttachment *attachment = (NSTextAttachment *)value;
        if (!attachment) {
            return;
        }
        NSString *emojiIndex = objc_getAssociatedObject(attachment, @"emoji");
        NSString *emojiName = self.emojiIndexToNameDic[emojiIndex];
        [rawText insertString:emojiName atIndex:range.location];
    }];
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSString *)convertRichTextIndexToNameWithYYTV:(YYTextView *)textView{
    NSMutableString *rawText = [[NSMutableString alloc] initWithString:textView.text];
    NSString *pattern = @"[\ue000-\uf8ff]|[\\x{1f300}-\\x{1f7ff}]|\\x{263A}\\x{FE0F}|☺";
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *resultsArray = [re matchesInString:rawText options:0 range:NSMakeRange(0, textView.text.length)];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:@"emojiToText" ofType:@"plist"];
    NSDictionary *emojiToText = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        NSString *emoji = [textView.text substringWithRange:match.range];
        if(!emojiToText[emoji]){
            [rawText replaceCharactersInRange:match.range withString:@"[表情]"];
        }else{
            [rawText replaceCharactersInRange:match.range withString:emojiToText[emoji]];
        }
    }
    [textView.attributedText enumerateAttribute:YYTextAttachmentAttributeName
                                        inRange:NSMakeRange(0, textView.attributedText.length)
                                        options:NSAttributedStringEnumerationReverse
                                     usingBlock:^(YYTextAttachment *attachment, NSRange range, BOOL *stop) {
                                         if (!attachment) {
                                             return;
                                         }
                                         NSString *emojiStr = attachment.userInfo[@"emoji"];
                                         NSString *emojiName = self.emojiIndexToNameDic[emojiStr];
                                         [rawText insertString:emojiName atIndex:range.location];
                                     }];
    
    return [rawText stringByReplacingOccurrencesOfString:@"\U0000fffc" withString:@""];
}

+ (NSString *)convertStringToNameWithString:(NSString *)string{
    if (string) {
        NSMutableString *rawString = [string mutableCopy];
        NSString *pattern = @"\\[\\d{1,3}\\]";
        NSError *error = nil;
        NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSArray *resultsArray = [re matchesInString:rawString options:0 range:NSMakeRange(0, rawString.length)];
        for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
            NSString *emojiName = self.emojiIndexToNameDic[[rawString substringWithRange:match.range]];
            if (emojiName) {
                [rawString replaceCharactersInRange:match.range withString:emojiName];
            }
        }
        return [rawString copy];
    }
    return nil;
}

+ (NSData *)compressImage:(UIImage *)image
{
    CGSize size = [self scaleSize:image.size];
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger maxFileSize = 500 * 1024;
    CGFloat compressionRatio = 0.7f;
    CGFloat maxCompressionRatio = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
    
    while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
        compressionRatio -= 0.1f;
        imageData = UIImageJPEGRepresentation(image, compressionRatio);
    }
    
    return imageData;
}

+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    } else {
        return CGSizeMake(800 * width / height, 800);
    }
}


+ (BOOL)isURL:(NSString *)string
{
    NSString *pattern = @"^(http|https)://.*?$(net|com|.com.cn|org|me|)";
    
    NSPredicate *urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    
    return [urlPredicate evaluateWithObject:string];
}


+ (NSInteger)networkStatus
{
    return [AFNetworkReachabilityManager shareReachability].networkReachabilityStatus;
}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] != 0;
}


#pragma mark UI处理

+ (CGFloat)valueBetweenMin:(CGFloat)min andMax:(CGFloat)max percent:(CGFloat)percent
{
    return min + (max - min) * percent;
}

+ (MBProgressHUD *)createHUD
{
    UIWindow *window;
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *eachWindow in windows){
        if ([eachWindow isKeyWindow]) {
            window = eachWindow;
        }
    }
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:window];
    HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    [window addSubview:HUD];
    [HUD showAnimated:YES];
    HUD.removeFromSuperViewOnHide = YES;
    
    return HUD;
}

+ (UIImage *)createQRCodeFromString:(NSString *)string
{
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *QRFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [QRFilter setValue:stringData forKey:@"inputMessage"];
    [QRFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CGFloat scale = 5;
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:QRFilter.outputImage fromRect:QRFilter.outputImage.extent];
    
    //Scale the image usign CoreGraphics
    CGFloat width = QRFilter.outputImage.extent.size.width * scale;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    //Cleaning up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    return image;
}

+ (NSAttributedString *)attributedCommentCount:(int)commentCount
{
    NSString *rawString = [NSString stringWithFormat:@"%@ %d", [NSString fontAwesomeIconStringForEnum:FACommentsO], commentCount];
    NSAttributedString *attributedCommentCount = [[NSAttributedString alloc] initWithString:rawString
                                                                                 attributes:@{
                                                                                              NSFontAttributeName: [UIFont fontAwesomeFontOfSize:12],
                                                                                              }];
    
    return attributedCommentCount;
}


+ (NSString *)HTMLWithData:(NSDictionary *)data usingTemplate:(NSString *)templateName
{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html" inDirectory:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableDictionary *mutableData = [data mutableCopy];
    
    return [GRMustacheTemplate renderObject:mutableData fromString:template error:nil];
}

/*
 数字限制字符串
 */
+ (NSString *)numberLimitString:(int)number
{
    NSString *numberStr = @"";
    if (number >= 0 && number < 1000) {
        numberStr = [NSString stringWithFormat:@"%d", number];
    } else if (number >= 1000 && number < 10000) {
        int integer = number / 1000;
        int decimal = number % 1000 / 100;
        
        numberStr = [NSString stringWithFormat:@"%d.%dk", integer, decimal];
    } else {
        int inte = number / 1000;
        numberStr = [NSString stringWithFormat:@"%dk", inte];
    }
    
    return numberStr;
}

+ (UIImage*)createImageWithColor:(UIColor*) color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (NSString *)sha1:(NSString *)input
{
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

// 获取本地时间
+ (NSString *)getCurrentTimeString
{
    NSDate *curTime = [NSDate date];// 获取本地时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];  // 格式化时间NSDate
    NSString *stringFromDate = [formatter stringFromDate:curTime];
    
    return stringFromDate;
}

#pragma mark - 选择边框，主题色输入色，红色警告色
+ (void)setButtonBorder:(UIView *)view isFail:(BOOL)isFail isEditing:(BOOL)isEditing
{
    if (isFail) {
        view.layer.borderWidth = 2;
        view.layer.borderColor = [UIColor colorWithHex:0xe35b5a].CGColor;
    } else {
        if (isEditing) {
            view.layer.borderWidth = 2;
            view.layer.borderColor = [UIColor newSectionButtonSelectedColor].CGColor;
        } else {
            view.layer.borderWidth = 0;
        }
    }
}

#pragma makr - 检测是否为手机号
+ (BOOL)validateMobile:(NSString *)mobileNum
{
    NSString *regex = @"^1[3|5|7|8][0-9]\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject:mobileNum])
    {
        return NO;
    }
    
    else
    {
        return YES;
    }
}

#pragma makr - 检测是否为邮箱地址
+ (BOOL)validateEmail:(NSString *)emailString
{
    NSString *regex = @"[\\w!#$%&'*+/=?^_`{|}~-]+(?:\\.[\\w!#$%&'*+/=?^_`{|}~-]+)*@(?:[\\w](?:[\\w-]*[\\w])?\\.)+[\\w](?:[\\w-]*[\\w])?";
//    NSString *regex = @"^[A-Za-z0-9\u4e00-\u9fa5]+@[a-zA-Z0-9_-]+(\.[a-zA-Z0-9_-]+)+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if(![pred evaluateWithObject:emailString]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - image new
+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - app token
+(NSString *) getAppToken
{
	#if DEBUG
    
        return Debug_App_Token;

	#else
    
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"token_key_%@%@",Application_BundleID,Application_BuildNumber];
        NSString *value = [defaults objectForKey:key];
        if (value == nil) {
            NSArray* array = [[NSArray arrayWithObjects: Application_BuildNumber,Application_Version,App_Token_Key,nil] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            NSString* value = [Utils sha1:[array componentsJoinedByString:@"-"]];
            [defaults setObject:value forKey:key];
            [defaults synchronize];
            return [self getAppToken];
        } else {
            return value;
        }
	
	#endif
}


#pragma mark - 是否记录地理位置的配置参数
+(NSString *) shouldUploadLocation {
	return [[NSUserDefaults standardUserDefaults] objectForKey:keyShouldUploadLocation];
}

+(void) setShouldUploadLocation: (NSString *) yesOrNo {
	[[NSUserDefaults standardUserDefaults] setObject:yesOrNo forKey:keyShouldUploadLocation];
}

+ (NSString *)getUpLoadExtInfo {
	OSCUserItem *userItem = [Config myNewProfile];
	NSString *company = (userItem.more.company) ? userItem.more.company : @"";
	NSString *extInfo = [NSString stringWithFormat:
						 @"{\"id\":\"%ld\",\"name\":\"%@\",\"portrait\":\"%@\",\"gender\":\"%ld\",\"more\":{\"company\":\"%@\"}}",userItem.id,userItem.name,userItem.portrait,userItem.gender,company];
	extInfo = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																		   (CFStringRef)extInfo,
																		   NULL,
																		   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																		   kCFStringEncodingUTF8);
	return extInfo;
}

+ (NSAttributedString* )handle_TagString:(NSString* )originStr
                                fontSize:(CGFloat)fontSize;
{
    if (!originStr || [originStr isEqual:[NSNull null]]) return [NSMutableAttributedString new];
    
    NSString* needHandleStr = originStr;
    NSMutableAttributedString* mAttStr = [[NSMutableAttributedString alloc] initWithString:needHandleStr];
    [mAttStr setFont:[UIFont systemFontOfSize:fontSize]];
    [mAttStr setColor:[UIColor blackColor] range:mAttStr.rangeOfAll];
    
    NSString* pattern_str = @"@([^@^\\s^:^,^;^'，'^'；'^>^<]{1,})";
    NSRegularExpression* regular = [NSRegularExpression regularExpressionWithPattern:pattern_str options:NSRegularExpressionCaseInsensitive error:NULL];
    NSArray* result = [regular matchesInString:needHandleStr options:0 range:needHandleStr.rangeOfAll];
    
    for (NSTextCheckingResult* checkingResult in result) {
        NSString* resultStr = [needHandleStr substringWithRange:checkingResult.range];
        NSMutableAttributedString* mAttResultStr = [[NSMutableAttributedString alloc] initWithString:resultStr];

        [mAttResultStr setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:mAttResultStr.rangeOfAll];
        [mAttResultStr setColor:[UIColor blackColor] range:mAttResultStr.rangeOfAll];
        [mAttResultStr setFont:[UIFont systemFontOfSize:fontSize]];
        
        [mAttStr replaceCharactersInRange:checkingResult.range withAttributedString:mAttResultStr];
    }

    
    needHandleStr = mAttStr.string;
    
    pattern_str = @"#.+?#";
    regular = [NSRegularExpression regularExpressionWithPattern:pattern_str options:NSRegularExpressionCaseInsensitive error:NULL];
    result = [regular matchesInString:needHandleStr options:0 range:needHandleStr.rangeOfAll];
    
    for (NSTextCheckingResult* checkingResult in result) {
        NSString* resultStr = [needHandleStr substringWithRange:checkingResult.range];
        NSMutableAttributedString* mAttResultStr = [[NSMutableAttributedString alloc] initWithString:resultStr];
        
        [mAttResultStr setTextBinding:[YYTextBinding bindingWithDeleteConfirm:YES] range:mAttResultStr.rangeOfAll];
        [mAttResultStr setColor:[UIColor blackColor] range:mAttResultStr.rangeOfAll];
        [mAttResultStr setFont:[UIFont systemFontOfSize:fontSize]];
        
        [mAttStr replaceCharactersInRange:checkingResult.range withAttributedString:mAttResultStr];
    }
    
    return mAttStr.copy;
}

@end


@implementation Utils (UserContacter)

+ (void)getNomalAttentionContacterAndSaveToAttentionContacter
{
    [self loopNetwork:nil failureCount:0];
}

+ (void)loopNetwork:(NSString* )pageToken
       failureCount:(NSInteger)failureCount
{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    __block NSString* curPageToken = pageToken;
    __block NSInteger curFailureCount = failureCount;
    
    NSMutableDictionary* mutableDic = @{ @"id"    : @([Config getOwnID]) ,
                                         @"count" : @(100),
                                        }.mutableCopy;
    if (pageToken && pageToken.length > 0) {
        [mutableDic setValue:pageToken forKey:@"pageToken"];
    }
    
    [manger GET:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_USER_FOLLOWS]
     parameters:mutableDic.copy
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            BOOL isSuccess = [responseObject[@"code"] integerValue] == 1;
            if (isSuccess) {
                NSDictionary* result = responseObject[@"result"];
                curPageToken = result[@"nextPageToken"];
                NSArray* items = result[@"items"];
                NSArray<OSCAuthor* >* authors = [NSArray osc_modelArrayWithClass:[OSCAuthor class] json:items];
                if (authors && authors.count > 0) {
                    [NSObject updateToAttentionContacterList:authors];
                    curFailureCount = 0;
                    [self loopNetwork:curPageToken failureCount:curFailureCount];
                }
            }else{
                curFailureCount++ ;
                if (curFailureCount < 2) {
                    [self loopNetwork:pageToken failureCount:curFailureCount];
                }
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            curFailureCount ++;
            if (curFailureCount < 2) {
                [self loopNetwork:pageToken failureCount:curFailureCount];
            }
        }];
}

@end



@implementation Utils (MessageCenter)

+ (void)sendRequest2MsgCountInterface:(MsgCountType)msgCountType{

    if (msgCountType & MsgCountTypeAll) {
        [self _sendRequest2MsgCountInterface:(@"0x00011111")];
        return ;
    }
    
    if (msgCountType & MsgCountTypeMention) {
        [self _sendRequest2MsgCountInterface:(@"0x00000001")];
    }
    
    if (msgCountType & MsgCountTypeLetter) {
        [self _sendRequest2MsgCountInterface:(@"0x00000010")];
    }
    
    if (msgCountType & MsgCountTypeReview) {
        [self _sendRequest2MsgCountInterface:(@"0x00000100")];
    }
    
    if (msgCountType & MsgCountTypeFans) {
        [self _sendRequest2MsgCountInterface:(@"0x00001000")];
    }
    
    if (msgCountType & MsgCountTypeLike) {
        [self _sendRequest2MsgCountInterface:(@"0x00010000")];
    }
    
}

+ (void)_sendRequest2MsgCountInterface:(NSString* )clearFlag
{
    NSUInteger hex = strtoul([clearFlag UTF8String],0,0);

    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];

    [manger POST:[NSString stringWithFormat:@"%@%@",OSCAPI_V2_HTTPS_PREFIX,OSCAPI_MESSAGE_CLEAR]
      parameters:@{ @"clearFlag" : @(hex) }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             BOOL isSuccess = [responseObject[@"code"] integerValue] == 1;
             if (isSuccess) {
                 // nothing ... 
             }else{
                 [self _sendRequest2MsgCountInterface:clearFlag];
             }
    }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             [self _sendRequest2MsgCountInterface:clearFlag];
    }];

}

+ (void)beforehandSend_AtMe_List_Request{
    NSString* url = [NSString stringWithFormat:@"%@%@?uid=%ld",OSCAPI_V2_PREFIX,OSCAPI_MESSAGES_ATME_LIST,(long)[Config getOwnID]];
    [self _ListThePullInAdvance:url];
}

+ (void)beforehandSend_Comment_List_Request{
    NSString* url = [NSString stringWithFormat:@"%@%@?uid=%ld",OSCAPI_V2_PREFIX,OSCAPI_MESSAGES_COMMENTS_LIST,(long)[Config getOwnID]];
    [self _ListThePullInAdvance:url];
}

+ (void)beforehandSend_Chat_List_Request{
    NSString* url = [NSString stringWithFormat:@"%@%@?uid=%ld",OSCAPI_V2_PREFIX,OSCAPI_MESSAGES_LIST,(long)[Config getOwnID]];
    [self _ListThePullInAdvance:url];
}


+ (void)_ListThePullInAdvance:(NSString* )requestUrl{
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    
    [manger GET:requestUrl
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if([responseObject[@"code"]integerValue] == 1) {
                NSDictionary* resultDic = responseObject[@"result"];
                NSArray* items = resultDic[@"items"];
                
                if (items && items.count > 0) {
                    NSString* resourceName = [NSObject cacheResourceNameWithURL:requestUrl parameterDictionaryDesc:nil];
                    [NSObject handleResponseObject:resultDic resource:resourceName cacheType:SandboxCacheType_notice];
                }
                
            }
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
        }];
}

@end




@implementation Utils (SubMenuManger)

/** 定制化分栏*/
///获取全部本固定的 menuNames && meunTokens
+ (NSArray<NSString* >* )fixedLocalMenuNames{
    NSArray<NSString* >* fixedLocalTokens = [self fixedLocalMenuTokens];
    NSArray<OSCMenuItem* >* fixedLocalItems = [self conversionMenuItemsWithMenuTokens:fixedLocalTokens];
    NSArray<NSString* >* fixedLocalNames = [self conversionMenuNamesWithMenuItems:fixedLocalItems];
    return fixedLocalNames;
}
+ (NSArray<NSString* >* )fixedLocalMenuTokens{
    NSArray* fixedLocalTokens = @[
                                 //fixed
                                 @"d6112fa662bc4bf21084670a857fbd20",//开源资讯
                                 @"df985be3c5d5449f8dfb47e06e098ef9",//推荐博客
                                 @"98d04eb58a1d12b75d254deecbc83790",//技术问答
                                 @"1abf09a23a87442184c2f9bf9dc29e35",//每日一搏
                                 ];
    return fixedLocalTokens;
}

+ (NSArray<OSCMenuItem* >* )allLocalMenuItems{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"subMenuItems.plist" ofType:nil];
    NSArray* localMenusArr = [NSArray arrayWithContentsOfFile:filePath];
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:localMenusArr];
    return meunItems;
}

///获取全部本地的 menuNames && meunTokens
+ (NSArray<NSString* >* )allLocalMenuNames{
    NSArray* meunItems = [self allLocalMenuItems];
    NSMutableArray* allNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in meunItems) {
        [allNames addObject:curItem.name];
    }
    return allNames.copy;
}
+ (NSArray<NSString* >* )allLocalMenuTokens{
    NSArray* meunItems = [self allLocalMenuItems];
    NSMutableArray* allTokens = @[].mutableCopy;
    for (OSCMenuItem* curItem in meunItems) {
        [allTokens addObject:curItem.token];
    }
    return allTokens.copy;
}

///获取全部已选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allSelectedMenuNames{
    NSArray* chooseItemTokens = [self allSelectedMenuTokens];
    NSArray<OSCMenuItem* >* allChooseMenuItems = [self conversionMenuItemsWithMenuTokens:chooseItemTokens];
    NSMutableArray* allNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in allChooseMenuItems) {
        [allNames addObject:curItem.name];
    }
    return allNames.copy;
}
+ (NSArray<NSString* >* )allSelectedMenuTokens{
    NSMutableArray* mutableChooseItemTokens = [[NSUserDefaults standardUserDefaults] arrayForKey:kUserDefaults_ChooseMenus].mutableCopy;
    NSArray<NSString* >* allTokens = [self allLocalMenuTokens];
    if (!mutableChooseItemTokens || mutableChooseItemTokens.count == 0) {
        mutableChooseItemTokens = [self getNomalSelectedMenuItemTokens].mutableCopy;
        [self updateUserSelectedMenuListWithMenuTokens:mutableChooseItemTokens.copy];
    }
    NSMutableArray* deleteFixedLocalTokens = [NSMutableArray arrayWithCapacity:mutableChooseItemTokens.count];
    NSArray<NSString* >* fixedLocalTokens = [self fixedLocalMenuTokens];
    for (NSString* menuToken in mutableChooseItemTokens) {/** 去除fixed分栏 */
        if (![fixedLocalTokens containsObject:menuToken]) {
            [deleteFixedLocalTokens addObject:menuToken];
        }
    }
    mutableChooseItemTokens = deleteFixedLocalTokens;
    NSMutableArray* resultMuatbleArray = [NSMutableArray arrayWithCapacity:mutableChooseItemTokens.count];
    for (NSString* menuToken in mutableChooseItemTokens) {/** 去除不合法分栏 */
        if ([allTokens containsObject:menuToken]) {
            [resultMuatbleArray addObject:menuToken];
        }
    }
    mutableChooseItemTokens = resultMuatbleArray;
    [self updateUserSelectedMenuListWithMenuTokens:mutableChooseItemTokens.copy];
    return mutableChooseItemTokens.copy;
}

///获取全部未选的 menuNames && meunTokens
+ (NSArray<NSString* >* )allUnselectedMenuNames{
    NSArray<NSString* >* allUnselectedMenuTokens = [self allUnselectedMenuTokens];
    NSArray<OSCMenuItem* >* allUnselectedMenuItems = [self conversionMenuItemsWithMenuTokens:allUnselectedMenuTokens];
    allUnselectedMenuItems = [self sortTransformation:allUnselectedMenuItems];
    NSMutableArray* allUnselectedNames = @[].mutableCopy;
    for (OSCMenuItem* curMenuItem in allUnselectedMenuItems) {
        [allUnselectedNames addObject:curMenuItem.name];
    }
    return allUnselectedNames.copy;
}
+ (NSArray<NSString* >* )allUnselectedMenuTokens{
    NSArray* allTokens = [self allLocalMenuTokens];
    NSArray* allSelectedMenuTokens = [self allSelectedMenuTokens];
    
    NSMutableArray* unselectedTokens = @[].mutableCopy;
    for (NSString* curToken in allTokens) {
        if (![allSelectedMenuTokens containsObject:curToken]) {
            [unselectedTokens addObject:curToken];
        }
    }
    NSMutableArray* deleteFixedLocalTokens = [NSMutableArray arrayWithCapacity:unselectedTokens.count];
    NSArray<NSString* >* fixedLocalTokens = [self fixedLocalMenuTokens];
    for (NSString* menuToken in unselectedTokens) {/** 去除fixed分栏 */
        if (![fixedLocalTokens containsObject:menuToken]) {
            [deleteFixedLocalTokens addObject:menuToken];
        }
    }
    unselectedTokens = deleteFixedLocalTokens;
    
    return unselectedTokens.copy;
}
/** name token item 相互转换*/
///用name转换成具体menuItem
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuNames:(NSArray<NSString* >* )menuNames{
    NSArray<OSCMenuItem* >* allMeunItems = [self allLocalMenuItems];
    NSMutableArray* conversionMenuItem = @[].mutableCopy;
//    for (OSCMenuItem* curMenuItem in allMeunItems) {
//        if ([menuNames containsObject:curMenuItem.name]) {
//            [conversionMenuItem addObject:curMenuItem];
//        }
//        if (conversionMenuItem.count == menuNames.count) {
//            return conversionMenuItem.copy;
//        }
//    }
    NSMutableArray *allName = [NSMutableArray array];
    for(OSCMenuItem* curMenuItem in allMeunItems){
        [allName addObject:curMenuItem.name];
    }
    for (NSString *name in menuNames) {
        NSInteger index = [allName indexOfObject:name];
        OSCMenuItem *item = allMeunItems[index];
        [conversionMenuItem addObject:item];
    }
    return conversionMenuItem.copy;
}
///用token转换成具体menuItem
+ (NSArray<OSCMenuItem* >* )conversionMenuItemsWithMenuTokens:(NSArray<NSString* >* )menuTokens{
    NSArray<OSCMenuItem* >* allMeunItems = [self allLocalMenuItems];
    NSMutableArray* conversionMenuItem = @[].mutableCopy;
//    for (OSCMenuItem* curMenuItem in allMeunItems) {
//        if ([menuTokens containsObject:curMenuItem.token]) {
//            [conversionMenuItem addObject:curMenuItem];
//        }
//        if (conversionMenuItem.count == menuTokens.count) {
//            return conversionMenuItem.copy;
//        }
//    }
    NSMutableArray *allToken = [NSMutableArray array];
    for(OSCMenuItem* curMenuItem in allMeunItems){
        [allToken addObject:curMenuItem.token];
    }
    for (NSString *token in menuTokens) {
        NSInteger index = [allToken indexOfObject:token];
        OSCMenuItem *item = allMeunItems[index];
        [conversionMenuItem addObject:item];
    }
    return conversionMenuItem.copy;
}
///用menuItem转换成token
+ (NSArray<NSString* >* )conversionMenuTokensWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems{
    NSMutableArray* meunTokens = @[].mutableCopy;
    for (OSCMenuItem* menuItem in menuItems) {
        [meunTokens addObject:menuItem.token];
    }
    return meunTokens.copy;
}
///用menuItem转换成name
+ (NSArray<NSString* >* )conversionMenuNamesWithMenuItems:(NSArray<OSCMenuItem* >* )menuItems{
    NSMutableArray* meunNames = @[].mutableCopy;
    for (OSCMenuItem* menuItem in menuItems) {
        [meunNames addObject:menuItem.name];
    }
    return meunNames.copy;
}

///更新本地plist表(含全部分栏信息)
+ (void)updateLocalMenuList{
    /**
    NSString* requestURL = [NSString stringWithFormat:@"%@%@",OSCAPI_V2_PREFIX,OSCAPI_INFORMATION_SUB_ENUM];
    
    AFHTTPRequestOperationManager *manger = [AFHTTPRequestOperationManager OSCJsonManager];
    [manger GET:requestURL
     parameters:nil
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            if ([responseObject[@"code"] integerValue] == 1) {
                
            }
    }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            NSLog(@"%@",error);
    }];
     */
}
+ (void)usingLocatMenuListUpdateUserMenuList{
    NSArray<NSString* >* allSelectedMenuTokens = [self allSelectedMenuTokens];
    NSArray<NSString* >* allLocalMenuTokens = [self allLocalMenuTokens];
    NSMutableArray* updateUserList = @[].mutableCopy;
    for (NSString* curToken in allSelectedMenuTokens) {
        if ([allLocalMenuTokens containsObject:curToken]) {
            [updateUserList addObject:curToken];
        }
    }
    [self updateUserSelectedMenuListWithMenuTokens:updateUserList.copy];
}
///更新UserSelectedMeunList(包含用户选中的分栏信息)
+ (void)updateUserSelectedMenuListWithMenuItems:(NSArray<OSCMenuItem* >* )newUserMenuList_items{
    NSArray<NSString* >* menuTokens = [self conversionMenuTokensWithMenuItems:newUserMenuList_items];
    [self updateUserSelectedMenuListWithMenuTokens:menuTokens];
}
+ (void)updateUserSelectedMenuListWithMenuTokens:(NSArray<NSString* >* )newUserMenuList_tokens{
    [[NSUserDefaults standardUserDefaults] setObject:newUserMenuList_tokens forKey:kUserDefaults_ChooseMenus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)updateUserSelectedMenuListWithMenuNames:(NSArray<NSString* >* )newUserMenuList_names{
    NSArray<OSCMenuItem* >* menuItems = [self conversionMenuItemsWithMenuNames:newUserMenuList_names];
    NSArray<NSString* >* menuTokens = [self conversionMenuTokensWithMenuItems:menuItems];
    [self updateUserSelectedMenuListWithMenuTokens:menuTokens];
}


+ (NSArray<NSString* >* )getNomalSelectedMenuItemTokens{
    NSArray* nomalToken = [self fixedLocalMenuTokens];
    return nomalToken;
}

///根据item的order进行排序
+ (NSArray<OSCMenuItem* >* )sortTransformation:(NSArray<OSCMenuItem* >* )items{
    NSMutableArray<OSCMenuItem* >* sortMutableArray = [NSMutableArray arrayWithCapacity:items.count];
    
    /**test
    NSMutableArray<NSNumber* >* orderArray = @[].mutableCopy;
    for (OSCMenuItem* item in items) {
        [orderArray addObject:@(item.order)];
    }
    NSLog(@"%@",orderArray);
     */
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    sortMutableArray = [items sortedArrayUsingDescriptors:@[sortDescriptor]].copy;
    
    /**
    for (OSCMenuItem* item in sortMutableArray) {
        [orderArray addObject:@(item.order)];
    }
    NSLog(@"%@",orderArray);
     */
    
    return sortMutableArray;
}

/** 过渡版分栏读写接口*/
+ (NSString* )originMenuFilePath{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_original.json" ofType:nil];
    return filePath;
}
+ (NSString* )activeMenuItemFilePath{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_active.json" ofType:nil];
    return filePath;
}
+ (NSArray<OSCMenuItem* >* )getOriginMenuItem{//获取全部分栏信息
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_original.json" ofType:nil];
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
    id localMenusArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:localMenusArr];
    return meunItems;
}
+ (NSArray<NSString* >* )getOriginMenuItemNames{
    NSArray<OSCMenuItem* >* originItems = [self getOriginMenuItem];
    
    NSMutableArray* originNames = @[].mutableCopy;
    for (OSCMenuItem* meunItem in originItems) {
        [originNames addObject:meunItem.name];
    }
    return originNames.copy;
}
+ (NSArray<OSCMenuItem* >* )getActiveMenuItem{//获取用户选择分栏信息
    NSArray* chooseMenus = [[NSUserDefaults standardUserDefaults] valueForKey:kUserDefaults_ChooseMenus];
    if (chooseMenus.count == 0 || !chooseMenus) {
        NSString* filePath = [[NSBundle mainBundle] pathForResource:@"sub_tab_active.json" ofType:nil];
        NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
        chooseMenus = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:NULL];
    }
    NSArray* meunItems = [NSArray osc_modelArrayWithClass:[OSCMenuItem class] json:chooseMenus];
    return meunItems;
}

+ (NSArray<NSString* >* )allSelected_MenuNames{
    NSArray<OSCMenuItem* >* activeMenuItems = [self getActiveMenuItem];
    NSMutableArray* allSelected_MenuNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in activeMenuItems) {
        [allSelected_MenuNames addObject:curItem.name];
    }
    return allSelected_MenuNames.copy;
}

+ (NSArray<NSString* >* )allUnselected_MenuNames{
    NSArray<OSCMenuItem* >* originMenuItems = [self getOriginMenuItem];
    NSArray<OSCMenuItem* >* activeMenuItems = [self getActiveMenuItem];
    
    NSMutableArray<OSCMenuItem* >* allUnselected_MenuItems = @[].mutableCopy;
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < activeMenuItems.count; i++) {
        [nameArray addObject:activeMenuItems[i].name];
    }
    
    for (OSCMenuItem* curItem in originMenuItems) {
        if (![nameArray containsObject:curItem.name]) {
            [allUnselected_MenuItems addObject:curItem];
        }
    }
    
//    NSArray<OSCMenuItem* >* allUnselected_Sort_MenuItems = [self sortTransformation:allUnselected_MenuItems.copy];
    NSArray<OSCMenuItem* >* allUnselected_Sort_MenuItems = allUnselected_MenuItems.copy;

    
    NSMutableArray<NSString* >* allUnselected_MenuNames = @[].mutableCopy;
    for (OSCMenuItem* curItem in allUnselected_Sort_MenuItems) {
        [allUnselected_MenuNames addObject:curItem.name];
    }
    
    return allUnselected_MenuNames.copy;
}

+ (void)updateUserSelectedMenuList_With_MenuNames:(NSArray<NSString* >* )newUserMenuList_names{
    NSArray<OSCMenuItem* >* allOriginItems = [self getOriginMenuItem];
    NSArray<NSString* >* allOriginItemNames = [self getOriginMenuItemNames];
    
    NSMutableArray<OSCMenuItem* >* userSelectedArr = @[].mutableCopy;
    for (NSString* curItemName in newUserMenuList_names) {
        for (NSString* curOriginItemName in allOriginItemNames) {
            if ([curItemName isEqualToString:curOriginItemName]) {
                NSInteger index = [allOriginItemNames indexOfObject:curOriginItemName];
                OSCMenuItem* indexItem = [allOriginItems objectAtIndex:index];
                [userSelectedArr addObject:indexItem];
            }
        }
    }

    NSMutableArray* mstableDicArr = [NSMutableArray arrayWithCapacity:userSelectedArr.count];
    for (OSCMenuItem* menuItem in userSelectedArr.copy) {
        [mstableDicArr addObject:[menuItem osc_modelToJSONObject]];
    }
    
    NSArray* dicArray = mstableDicArr.copy;
    [[NSUserDefaults standardUserDefaults] setObject:dicArray forKey:kUserDefaults_ChooseMenus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray<OSCMenuItem* >* )conversionMenuItems_With_MenuNames:(NSArray<NSString* >* )menuNames{
    NSArray<OSCMenuItem* >* originMenuItem = [self getOriginMenuItem];
    NSArray<NSString* >* originMenuName = [self getOriginMenuItemNames];
    
    NSMutableArray<OSCMenuItem* >* conversionMenuItems = @[].mutableCopy;
    for (NSString* curName in menuNames) {
        for (NSString* originName in originMenuName) {
            if ([curName isEqualToString:originName]) {
                NSInteger index = [originMenuName indexOfObject:originName];
                OSCMenuItem* indexItem = [originMenuItem objectAtIndex:index];
                [conversionMenuItems addObject:indexItem];
            }
        }
    }
    return conversionMenuItems.copy;
}
@end



















