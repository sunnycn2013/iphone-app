//
//  GACompressionHelper.h
//  iosapp
//
//  Created by Graphic-one on 17/3/24.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GACompressionHelper : NSObject

+ (NSData* )CompressionHelperWithOriginData:(NSData* ) originData;

+ (NSData *)CompressionHelperWithOriginImage:(UIImage *) image;

@end
