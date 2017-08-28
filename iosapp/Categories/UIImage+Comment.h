//
//  UIImage+Comment.h
//  iosapp
//
//  Created by Graphic-one on 17/3/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)
- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;
- (UIImage *)cropToRect:(CGRect)rect;
- (UIImage *)fixOrientation;
@end


@interface UIImage (GA_Portrait)

+ (instancetype)creatCharacterPortrait:(NSString* )userName;

@end
