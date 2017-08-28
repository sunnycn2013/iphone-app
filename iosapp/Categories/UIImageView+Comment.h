//
//  UIImageView+Comment.h
//  iosapp
//
//  Created by Graphic-one on 16/11/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (Comment)

@end



/** using runtime save bitmap */
@interface UIImageView (CornerRadius)

- (instancetype)initWithCornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;

- (void)zy_cornerRadiusAdvance:(CGFloat)cornerRadius rectCornerType:(UIRectCorner)rectCornerType;

- (instancetype)initWithRoundingRectImageView;

- (void)zy_cornerRadiusRoundingRect;

- (void)zy_attachBorderWidth:(CGFloat)width color:(UIColor *)color;

@end


/** using 'shouldRasterize' handle */
@interface UIImageView (RadiusHandle)

- (void)addCorner:(CGFloat)radius;

- (void)handleCornerRadiusWithRadius:(CGFloat)radius;///使用光栅化

@end


/** 使用SDWebImage赋值图片并提供默认占位 */
@interface UIImageView (PortraitImage)

- (void)loadPortrait:(NSURL *)portraitURL userName:(NSString* )userName;

@end


/** UIImage ImageEffects &&  LBBlurredImage */
@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end

typedef void(^LBBlurredImageCompletionBlock)(void);

extern CGFloat const kLBBlurredImageDefaultBlurRadius;

@interface UIImageView (LBBlurredImage)

/**
 Set the blurred version of the provided image to the UIImageView
 
 @param UIImage the image to blur and set as UIImageView's image
 @param CGFLoat the radius of the blur used by the Gaussian filter
 @param LBBlurredImageCompletionBlock a completion block called after the image
 was blurred and set to the UIImageView (the block is dispatched on main thread)
 */
- (void)setImageToBlur:(UIImage *)image
            blurRadius:(CGFloat)blurRadius
       completionBlock:(LBBlurredImageCompletionBlock)completion;

/**
 Set the blurred version of the provided image to the UIImageView
 with the default blur radius
 
 @param UIImage the image to blur and set as UIImageView's image
 @param LBBlurredImageCompletionBlock a completion block called after the image
 was blurred and set to the UIImageView (the block is dispatched on main thread)
 */
- (void)setImageToBlur:(UIImage *)image
       completionBlock:(LBBlurredImageCompletionBlock)completion;

@end


