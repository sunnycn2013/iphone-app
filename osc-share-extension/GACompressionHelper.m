//
//  GACompressionHelper.m
//  iosapp
//
//  Created by Graphic-one on 17/3/24.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "GACompressionHelper.h"

#define kCompressionSize 1024 * 512

@implementation GACompressionHelper

+ (NSData* )CompressionHelperWithOriginData:(NSData* )originData{
    NSData* targetData = nil;
    if (originData.length <= kCompressionSize) {
        targetData = originData;
    }else{
        targetData = originData;
        UIImage* originImage = [UIImage imageWithData:originData];
        CGFloat compressCount = 0.75;
        do {
            targetData = UIImageJPEGRepresentation(originImage, compressCount);
            compressCount -= 0.10;
        } while (targetData.length > kCompressionSize);
    }
    return targetData;
}

+(NSData *) CompressionHelperWithOriginImage:(UIImage *) image {
	UIImage *targetImage = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:image.imageOrientation];
	NSData* targetData = nil;
	CGFloat compressionQuality = 0.75;
	do {
		targetData = UIImageJPEGRepresentation(targetImage, compressionQuality);
		compressionQuality -= 0.10;
	} while (targetData.length > kCompressionSize);
	
	return targetData;
}


@end
