//
//  NSString+Comment.m
//  iosapp
//
//  Created by Graphic-one on 17/2/7.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "NSString+Comment.h"

@implementation NSString (Comment)

#pragma mark - pinyin
/*
 - (NSString*)pinyinFirst{
 if (self == nil || self.length == 0) {
 return @"";
 }
 NSMutableString *result = [NSMutableString stringWithString:[self substringToIndex:1]];
 //先转换为带声调的拼音
 CFStringTransform((CFMutableStringRef)result,NULL, kCFStringTransformMandarinLatin,NO);
 //再转换为不带声调的拼音
 CFStringTransform((CFMutableStringRef)result,NULL, kCFStringTransformStripDiacritics,NO);
 return result;
 }
 */
- (NSString*)pinyin {
    if (self == nil || self.length == 0) {
        return @"";
    }
    NSMutableString *result = [NSMutableString stringWithString:self];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)result,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)result,NULL, kCFStringTransformStripDiacritics,NO);
    return [result uppercaseString];
}


#pragma mark - HTML handle
- (NSString *)escapeHTML
{
    NSMutableString *result = [self mutableCopy];
    [result replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    [result replaceOccurrencesOfString:@"'"  withString:@"&#39;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
    
    return result;
}

- (NSString *)deleteHTMLTag
{
    NSMutableString *trimmedHTML = [self mutableCopy];
    
    NSString *styleTagPattern = @"<style[^>]*?>[\\s\\S]*?<\\/style>";
    NSRegularExpression *styleTagRe = [NSRegularExpression regularExpressionWithPattern:styleTagPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSArray *resultsArray = [styleTagRe matchesInString:trimmedHTML options:0 range:NSMakeRange(0, trimmedHTML.length)];
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        [trimmedHTML replaceCharactersInRange:match.range withString:@""];
    }
    
    NSString *htmlTagPattern = @"<[^>]+>";
    NSRegularExpression *normalHTMLTagRe = [NSRegularExpression regularExpressionWithPattern:htmlTagPattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    resultsArray = [normalHTMLTagRe matchesInString:trimmedHTML options:0 range:NSMakeRange(0, trimmedHTML.length)];
    for (NSTextCheckingResult *match in [resultsArray reverseObjectEnumerator]) {
        [trimmedHTML replaceCharactersInRange:match.range withString:@""];
    }
    
    return trimmedHTML;
}

@end
