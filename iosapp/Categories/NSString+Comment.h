//
//  NSString+Comment.h
//  iosapp
//
//  Created by Graphic-one on 17/2/7.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Comment)

///< conversion pinyin
- (NSString*)pinyin;

///< HTML handle
- (NSString *)escapeHTML;
- (NSString *)deleteHTMLTag;

@end
