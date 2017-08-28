//
//  UIImage+Comment.m
//  iosapp
//
//  Created by Graphic-one on 17/3/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "UIImage+Comment.h"
#import "UIColor+Util.h"
#import <math.h>

@implementation UIImage (Util)

// 同 - (UIImage *)jsq_imageMaskedWithColor:(UIColor *)maskColor

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor
{
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage *)cropToRect:(CGRect)rect
{
    CGImageRef imageRef   = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}

- (UIImage *)fixOrientation {
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end



@implementation UIImage (GA_Portrait)

+ (NSArray<UIColor* >* )_colors{
    static NSArray<UIColor* >* shareColor ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareColor = @[
                       [UIColor colorWithHex:0xFF1abc9c],
                       [UIColor colorWithHex:0xFF2ecc71],
                       [UIColor colorWithHex:0xFF3498db],
                       [UIColor colorWithHex:0xFF9b59b6],
                       [UIColor colorWithHex:0xFF34495e],
                       [UIColor colorWithHex:0xFF16a085],
                       [UIColor colorWithHex:0xFF27ae60],
                       [UIColor colorWithHex:0xFF2980b9],
                       [UIColor colorWithHex:0xFF8e44ad],
                       [UIColor colorWithHex:0xFF2c3e50],
                       [UIColor colorWithHex:0xFFf1c40f],
                       [UIColor colorWithHex:0xFFe67e22],
                       [UIColor colorWithHex:0xFFe74c3c],
                       [UIColor colorWithHex:0xFFeca0f1],
                       [UIColor colorWithHex:0xFF95a5a6],
                       [UIColor colorWithHex:0xFFf39c12],
                       [UIColor colorWithHex:0xFFd35400],
                       [UIColor colorWithHex:0xFFc0392b],
                       [UIColor colorWithHex:0xFFbdc3c7],
                       [UIColor colorWithHex:0xFF7f8c8d],
                       ];
    });
    return shareColor;
}

+ (instancetype)creatCharacterPortrait:(NSString* )userName{
	if (!userName || userName == (id)kCFNull || userName.length == 0) userName = @"X";
    
    NSString* firstStr = [userName substringWithRange:NSMakeRange(0, 1)];
    firstStr = firstStr.uppercaseString;

    NSUInteger colorHex = ((abs(((int)[firstStr characterAtIndex:0] - 64))) % ([self _colors].count));
    UIColor* color = [self _colors][colorHex];
    
    CALayer* bg_layer = [CALayer layer];
    bg_layer.frame = (CGRect){{0,0},{80,80}};
    bg_layer.backgroundColor = color.CGColor;

    CATextLayer* layer = [CATextLayer new];
    layer.string = firstStr;
    layer.font = (__bridge CFTypeRef)[UIFont systemFontOfSize:60];
    layer.alignmentMode = @"center";
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.frame = (CGRect){{10,18},{60,60}};
    [bg_layer addSublayer:layer];
    
    UIGraphicsBeginImageContext(bg_layer.bounds.size);
    [bg_layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


