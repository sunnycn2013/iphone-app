//
//  BannerScrollView.h
//  iosapp
//
//  Created by Graphic-one on 17/2/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BannerScrollViewConfiguration,OSCBannerModel;

/** BannerScrollView cycle show the way */
typedef NS_ENUM(NSInteger,BannerScrollViewStyle){
    BannerScrollViewStyleAutoAndSpringback  = 0, //Automatic cycle display pictures and springback
    BannerScrollViewStyleAuto               = 1, //Single direction automatically round
    BannerScrollViewStyleNone               = -1,//Manual sliding banner
};

/** The alignment of widget (titleLabel or pageController) in horizontal way */
typedef NS_ENUM(NSUInteger,WidgetHorizontalAlignment){
    WidgetHorizontalAlignmenttLeft              = 0,
    WidgetHorizontalAlignmentCenter             = 1,
    WidgetHorizontalAlignmentRight              = 2,
};

@protocol BannerScrollViewDelegate <NSObject>
- (void)clickedScrollViewBanners:(NSInteger)bannerTag;
@end


/** BannerScrollView is an independent control based on "SDWebImage" kit */
@interface BannerScrollView : UIView

///< Don't need to transform the model
+ (instancetype)bannerScrollViewWithFrame:(CGRect)frame
                            configuration:(BannerScrollViewConfiguration* )config
                                   titile:(nullable NSArray<NSString* >* )title
                             netImagePath:(nullable NSArray<NSString* >* )url
                               localImage:(nullable NSArray<NSData* >* )data;

///< Need to transform the model
+ (instancetype)bannerScrollViewWithFrame:(CGRect)frame
                            configuration:(BannerScrollViewConfiguration* )config
                                   models:(NSArray<OSCBannerModel* >* )models;

@property (nonatomic, strong) NSArray<OSCBannerModel* > *banners;
@property (nonatomic, weak) id<BannerScrollViewDelegate> delegate;

- (instancetype)init UNAVAILABLE_ATTRIBUTE ;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE ;
@end


#pragma mark - 

/**
 *  BannerScrollViewConfiguration is in the service of "BannerScrollView" configuration model object .
 *  Use BannerScrollViewConfiguration (quickConfigurationTitleFontSize:) method can realize rapid configuration .
 *  Use BannerScrollViewConfiguration (instanceBannerConfigurationPlaceholderImage:) method implement a custom configuration .
 */

@interface BannerScrollViewConfiguration : NSObject

+ (instancetype)quickConfigurationTitleFontSize:(CGFloat)fontSize
                                     titleColor:(UIColor* )titleColor
                              pageSelectedColor:(UIColor* )pageColor
                                          style:(BannerScrollViewStyle)style;


+ (instancetype)instanceBannerConfigurationPlaceholderImage:(nullable UIImage* ) placeholderImage
                                                    orColor:(nullable NSArray<UIColor* >* )colors
                                                  needTitle:(BOOL)isNeedTitle
                                                titleHeight:(CGFloat)titleHeight
                                             titleAlignment:(WidgetHorizontalAlignment)titleAlignment
                                           andTitleFontName:(nullable NSString* )fontName
                                           andTitleFontSize:(CGFloat)fontSize
                                              andTitleColor:(nullable UIColor* )titleColor
                                                   needPage:(BOOL)isNeedPage
                                              pageAlignment:(WidgetHorizontalAlignment)pageAlignment
                                        andPageDefaultColor:(nullable UIColor* )defaultColor
                                       andPageSelectedColor:(UIColor* )selectedColor
                                              needDiskCache:(BOOL)isNeedDiskCache
                                                      style:(BannerScrollViewStyle)style;

@property (nonatomic,assign) BannerScrollViewStyle style;

/** when value is nil using the "color" property as a gradient color */
@property (nonatomic,strong,nullable) UIImage* placeholderImage;///< default is nil
/** Priority is lower than "placeholderImage" property , Direction: from top to bottom */
@property (nonatomic,strong,nullable) NSArray<UIColor* >* colors;///< default is nil , used as a placeholder gradient background

@property (nonatomic,assign,getter=isNeedTitleLabel) BOOL needTitle;///< default is YES
@property (nonatomic,assign) WidgetHorizontalAlignment titleAlignment;///< default is WidgetHorizontalAlignmenttLeft
@property (nonatomic,assign) CGFloat titleHeight;///< default is 50px
@property (nonatomic,assign,nullable) NSString* fontName;///< default is nil , using System font
@property (nonatomic,assign) CGFloat fontSize;
@property (nonatomic,strong) UIColor* titleColor;

@property (nonatomic,assign,getter=isNeedPageController) BOOL needPage;///< default is YES
@property (nonatomic,assign) WidgetHorizontalAlignment pageAlignment;///< default is WidgetHorizontalAlignmentRight
@property (nonatomic,strong,nullable) UIColor* defaultColor;///< default is white
@property (nonatomic,strong) UIColor* selectedColor;

@property (nonatomic,assign,getter=isNeedDiskCache) BOOL needDiskCache;///< default is YES

@end


#pragma mark -

/**
 *  OSCBannerModel are specially serve BannerScrollView model object .
 *  Because BannerScrollView required data is very lightweight ,  So I suggest you to convert the model .
 */
@interface OSCBannerModel : NSObject

+ (instancetype)bannerModelWithTitle:(nullable NSString* )title
                        netImagePath:(nullable NSString* )netImagePath
                      localImageData:(nullable NSData* )localImageData;

@property (nonatomic,strong,nullable) NSString* title;

@property (nonatomic,strong,nullable) NSString* netImagePath;

@property (nonatomic,strong,nullable) NSData* localImageData;

@end


NS_ASSUME_NONNULL_END


