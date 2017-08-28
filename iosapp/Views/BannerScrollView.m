//
//  BannerScrollView.m
//  iosapp
//
//  Created by Graphic-one on 17/2/16.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "BannerScrollView.h"

///< Double processor cache (Memory & Disk)
@interface _CacheHandle : NSObject
+ (nullable UIImage* )getImage:(NSString* )url;
+ (BOOL)saveImage:(NSData* )data url:(NSString* )url toDisk:(BOOL)isNeedSaveDisk;
@end

@implementation _CacheHandle
static NSMapTable* _mapTable;
+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mapTable = [[NSMapTable alloc] init];
    });
}

+ (NSString* )tmpPath{
    return [NSHomeDirectory() stringByAppendingFormat:@"/tmp"];
}

+ (UIImage *)getImage:(NSString *)url{
    if (!url || [url isEqual:(id)kCFNull]) return nil;
    
    NSString* file = [[self tmpPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",url.hash]];
    if ([_mapTable objectForKey:url]) {//Memory
        return [_mapTable objectForKey:url];
    }else if ([[NSFileManager defaultManager] fileExistsAtPath:file]){//Disk
        NSData* data = [NSData dataWithContentsOfFile:file];
        [_mapTable setObject:[UIImage imageWithData:data scale:[UIScreen mainScreen].scale] forKey:url];
        return [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
    }else{
        return nil;
    }
}

+ (BOOL)saveImage:(NSData *)data
              url:(NSString *)url
           toDisk:(BOOL)isNeedSaveDisk
{
    if (!data || [data isEqual:(id)kCFNull])  return NO;
    if (!url  || [url isEqual:(id)kCFNull]) return NO;
    
    NSString* file = [[self tmpPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",url.hash]];

    [_mapTable setObject:[UIImage imageWithData:data scale:[UIScreen mainScreen].scale] forKey:url];//Memory
    
    if (isNeedSaveDisk) {
        return [data writeToFile:file atomically:YES];//Disk
    }else{
        return [_mapTable objectForKey:url] != nil;
    }
}
@end


#define TITLE_HEIGHT 30
#define PAGECONTROLLER_WIDTH 60

#pragma mark - BannerImageView
@interface BannerImageView : UIView
@property (nonatomic, strong) BannerScrollViewConfiguration* configuration;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIView* bottomView;
@property (nonatomic, weak) UILabel *titleLable;
- (void)setContentForBanners:(OSCBannerModel *)banner placeholder:(UIImage* )placeholderImage;
@end

@implementation BannerImageView
{
    BOOL _isDone;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isDone = NO;
        [self setUIForSubImage:frame];
    }
    
    return self;
}

- (void)setUIForSubImage:(CGRect)frame
{
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _imageView = imageView;
    _imageView.backgroundColor = [UIColor lightGrayColor];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 50, CGRectGetWidth(self.frame), 50)];
    _bottomView = bottomView;
    [self layerForCycleScrollViewTitle:bottomView];
    [self addSubview:bottomView];
    
    UILabel* titleLable = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetHeight(self.frame)-TITLE_HEIGHT, CGRectGetWidth(self.frame)-96, TITLE_HEIGHT)];
    _titleLable = titleLable;
    _titleLable.font = [UIFont systemFontOfSize:15];
    _titleLable.textColor = [UIColor colorWithRed:((float)((0xffffff & 0xFF0000) >> 16))/255.0
                                            green:((float)((0xffffff & 0xFF00) >> 8))/255.0
                                             blue:((float)(0xffffff & 0xFF))/255.0
                                            alpha:1.0];
    _titleLable.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLable];
}

- (void)setConfiguration:(BannerScrollViewConfiguration *)configuration{
    _configuration = configuration;
    
    if (configuration.placeholderImage) {
        [_imageView setImage:configuration.placeholderImage];
    }else if (configuration.colors){
        [self layerForCycleScrollViewTitle:_bottomView];
    }
    
    if (_configuration.isNeedTitleLabel) {
        _titleLable.frame = CGRectMake(0, CGRectGetHeight(self.frame) - _configuration.titleHeight, CGRectGetWidth(self.frame), _configuration.titleHeight);
        
        CGRect originFrame = _titleLable.frame;
        switch (_configuration.titleAlignment) {
            case WidgetHorizontalAlignmenttLeft:
                // cur titleAlignment ...
                break;
            case WidgetHorizontalAlignmentCenter:{
                CGFloat targetW = self.bounds.size.width - originFrame.origin.x * 2;
                originFrame.size.width = targetW;
                _titleLable.frame = originFrame;
                _titleLable.textAlignment = NSTextAlignmentCenter;
                break;
            }
            case WidgetHorizontalAlignmentRight:{
                CGFloat targetX = self.bounds.size.width - originFrame.origin.x - originFrame.size.width;
                originFrame.origin.x = targetX;
                _titleLable.frame = originFrame;
                _titleLable.textAlignment = NSTextAlignmentLeft;
                break;
            }
                
            default:
                break;
        }
        
        _titleLable.textColor = _configuration.titleColor ?: _titleLable.textColor;
        CGFloat fontSize = _configuration.fontSize ?: 15;
        _titleLable.font = _configuration.fontName ? [UIFont fontWithName:_configuration.fontName size:fontSize] : [UIFont systemFontOfSize:fontSize];
        
    }else{
        _bottomView.hidden = YES;
        _titleLable.hidden = YES;
    }
}


- (void)setContentForBanners:(OSCBannerModel *)banner
                 placeholder:(UIImage* )placeholderImage
{
    if (banner.localImageData && banner.localImageData.length > 0) {
        [_imageView setImage:[UIImage imageWithData:banner.localImageData]];
    }else if (banner.netImagePath && banner.netImagePath.length > 0){
        if ([_CacheHandle getImage:banner.netImagePath]) {
            [_imageView setImage:[_CacheHandle getImage:banner.netImagePath]];
            _isDone = YES;
        }else{
            if (!_isDone) {
                NSURLSession* shareSession = [NSURLSession sharedSession];
                NSURLSessionTask* task = [shareSession dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:banner.netImagePath]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error) {
                        _isDone = NO;
                    }else{
                        [_CacheHandle saveImage:data url:banner.netImagePath toDisk:_configuration.isNeedDiskCache];
                        UIImage* image = [UIImage imageWithData:data];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_imageView setImage:image];
                            _isDone = YES;
                        });
                    }
                }];
                [task resume];
            }
        }
    }else{
        if (placeholderImage) {
            [_imageView setImage:placeholderImage];
        }else{
            _imageView.backgroundColor = [UIColor whiteColor];
        }
    }
    _titleLable.text = banner.title;
}

- (void)layerForCycleScrollViewTitle:(UIView *)bottomView
{
    NSArray* layers = bottomView.layer.sublayers;
    if (layers) {
        for (CALayer* layer in layers) {
            [layer removeFromSuperlayer];
        }
    }
    
    UIColor* statrColor , *endColor ;
    if (_configuration.colors && _configuration.colors.count > 0) {
        statrColor = _configuration.colors.firstObject;
        endColor   = _configuration.colors.lastObject;
    }else{
        statrColor = [self gradientLayerStartColor];
        endColor   = [self gradientLayerEndColor];
    }
    
    CAGradientLayer *layer = [CAGradientLayer new];
    layer.colors = @[
                     (__bridge id)statrColor.CGColor,
                     (__bridge id)endColor.CGColor,
                     ];
    layer.startPoint = CGPointMake(0, 0);
    layer.endPoint = CGPointMake(0, 0.7);
    layer.frame = bottomView.bounds;
    
    [bottomView.layer addSublayer:layer];
}

#pragma mark -  default Value
- (UIColor* )gradientLayerStartColor{
    return [UIColor colorWithRed:((float)((0x000000 & 0xFF0000) >> 16))/255.0
                           green:((float)((0x000000 & 0xFF00) >> 8))/255.0
                            blue:((float)(0x000000 & 0xFF))/255.0
                           alpha:0.0];
}
- (UIColor* )gradientLayerEndColor{
    return [UIColor colorWithRed:((float)((0x000000 & 0xFF0000) >> 16))/255.0
                           green:((float)((0x000000 & 0xFF00) >> 8))/255.0
                            blue:((float)(0x000000 & 0xFF))/255.0
                           alpha:0.35];
}

@end

#pragma mark - BannerScrollView
@interface BannerScrollView () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageController;

@property (nonatomic, strong) BannerScrollViewConfiguration* configuration;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BannerScrollView

+ (instancetype)bannerScrollViewWithFrame:(CGRect)frame
                            configuration:(BannerScrollViewConfiguration* )config
                                   titile:(nullable NSArray<NSString* >* )title
                             netImagePath:(nullable NSArray<NSString* >* )url
                               localImage:(nullable NSArray<NSData* >* )data
{
    if (!url && !data) return nil;
    
    BOOL isLocal , isHasTitles ;
    isLocal = ( data && data.count > 0 ) ? YES : NO;
    if (title && title.count > 0) isHasTitles = YES;
    if (isHasTitles && isLocal) NSParameterAssert(title.count == data.count);
    if (isHasTitles && !isLocal) NSParameterAssert(title.count == url.count);

    NSUInteger count = isLocal ? data.count : url.count;
    NSMutableArray* mArr = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        OSCBannerModel* model = [OSCBannerModel bannerModelWithTitle:isHasTitles ? title[i] : nil
                                                        netImagePath:isLocal ? nil : url[i]
                                                      localImageData:isLocal ? data[i]: nil];
        [mArr addObject:model];
    }
    
    return [self bannerScrollViewWithFrame:frame configuration:config models:mArr.copy];
}

+ (instancetype)bannerScrollViewWithFrame:(CGRect)frame
                            configuration:(BannerScrollViewConfiguration* )config
                                   models:(NSArray<OSCBannerModel* >* )models
{
    BannerScrollView* banner = [[BannerScrollView alloc] initWithFrame:frame];
    if (banner) {
        banner.configuration = config;
        banner.banners = models;
    }
    return banner;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        _scrollView = scrollView;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_scrollView];
        
        UIPageControl* pageController = [[UIPageControl alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-PAGECONTROLLER_WIDTH-16, CGRectGetHeight(self.frame)-TITLE_HEIGHT, PAGECONTROLLER_WIDTH, TITLE_HEIGHT)];
        _pageController = pageController;
        _pageController.backgroundColor = [UIColor clearColor];
        _pageController.currentPage = 0;
        _pageController.pageIndicatorTintColor = [UIColor whiteColor];
        _pageController.currentPageIndicatorTintColor = [UIColor colorWithRed:((float)((0x24CF5F & 0xFF0000) >> 16))/255.0 green:((float)((0x24CF5F & 0xFF00) >> 8))/255.0 blue:((float)(0x24CF5F & 0xFF))/255.0 alpha:1.0];
        [self addSubview:_pageController];
    }
    
    return self;
}

- (void)setBanners:(NSArray<OSCBannerModel *> *)banners{
    _banners = banners;
    
    NSMutableArray* resultArr = banners.mutableCopy;
    if (_configuration.style == BannerScrollViewStyleAuto) {
        [resultArr insertObject:banners.lastObject atIndex:0];
        [resultArr addObject:banners.firstObject];
    }
    
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * resultArr.count, CGRectGetHeight(self.frame));

    if (_configuration.isNeedPageController) {
        _pageController.hidden = NO;
        _pageController.numberOfPages = _configuration.style == BannerScrollViewStyleAuto ? resultArr.count - 2 : resultArr.count;
        _pageController.pageIndicatorTintColor = _configuration.defaultColor ?: _pageController.pageIndicatorTintColor;
        _pageController.currentPageIndicatorTintColor = _configuration.selectedColor ?: _pageController.currentPageIndicatorTintColor;
    }else{
        _pageController.hidden = YES;
    }


    CGFloat imageViewWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat imageViewHeight = CGRectGetHeight(_scrollView.frame);
    UIImage* placeholderImage = _configuration.placeholderImage ?: _configuration.colors ? [self createImageWithStartColor:_configuration.colors.firstObject endColor:_configuration.colors.lastObject] : [self createImageWithStartColor:[[UIColor grayColor] colorWithAlphaComponent:0.5] endColor:[UIColor whiteColor]] ;
    
    int indexTag = 0;
    for (int i = 0; i < resultArr.count; i++) {
        if (_configuration.style == BannerScrollViewStyleAuto && (i == 0 || i == resultArr.count - 1)) {
            BannerImageView *view = [[BannerImageView alloc] initWithFrame:CGRectMake(imageViewWidth * i, 0, imageViewWidth, imageViewHeight)];
            view.configuration = _configuration;
            [_scrollView addSubview:view];
            OSCBannerModel *banner  = resultArr[i];
            [view setContentForBanners:banner placeholder:placeholderImage];
        }else{
            BannerImageView *view = [[BannerImageView alloc] initWithFrame:CGRectMake(imageViewWidth * i, 0, imageViewWidth, imageViewHeight)];
            view.tag = indexTag + 1;
            indexTag++ ;
            [_scrollView addSubview:view];
            OSCBannerModel *banner  = resultArr[i];
            [view setContentForBanners:banner placeholder:placeholderImage];
            
            [view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopImage:)]];
        }
    }
    if (banners.count > 1 && _configuration.style != BannerScrollViewStyleNone) {
        if(!self.timer) {
            self.timer = [NSTimer timerWithTimeInterval:4.0f target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }
}


#pragma mark - timer setting
- (void)scrollToNextPage:(NSTimer *)timer
{
    NSInteger curIndex = _scrollView.contentOffset.x / CGRectGetWidth(self.frame);
    curIndex++;
    
    if (_configuration.style == BannerScrollViewStyleAuto) {
        if (curIndex >= _banners.count + 2) {
            [_scrollView setContentOffset:CGPointMake( 1.0 * CGRectGetWidth(_scrollView.frame), 0) animated:NO];
            return;
        }
    }else{
        if (curIndex >= _banners.count) {
            curIndex = 0;
        }
    }
    [_scrollView setContentOffset:CGPointMake(curIndex * CGRectGetWidth(_scrollView.frame), 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger curIndex = scrollView.contentOffset.x / CGRectGetWidth(self.frame);
    NSInteger pageCount ;
    if (_configuration.style == BannerScrollViewStyleAuto) {
        if (curIndex == 0) {
            [_scrollView setContentOffset:CGPointMake( _banners.count * CGRectGetWidth(_scrollView.frame), 0) animated:NO];
            return;
        }else if (curIndex == _banners.count + 1){
            [_scrollView setContentOffset:CGPointMake( 1 * CGRectGetWidth(_scrollView.frame), 0) animated:NO];
            return;
        }else{
            pageCount = curIndex - 1;
        }
    }
    _pageController.currentPage = pageCount;
}


#pragma mark - tapHandle
- (void)clickTopImage:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(clickedScrollViewBanners:)]) {
        [_delegate clickedScrollViewBanners:tap.view.tag - 1];
    }
}

#pragma mark - delegate

- (void)clickScrollViewBanner:(NSInteger)bannerTag
{
    if ([_delegate respondsToSelector:@selector(clickedScrollViewBanners:)]){
        [_delegate clickedScrollViewBanners:bannerTag];
    }
}


#pragma mark - ImageHandle
- (UIImage* )createImageWithStartColor:(UIColor* )startColor
                              endColor:(UIColor* )endColor
{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray* colors = @[(__bridge id)startColor.CGColor,(__bridge id )endColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,(CFArrayRef)colors,NULL);
    CGColorSpaceRelease(colorSpace);
    
    CGPoint startPoint = (CGPoint){CGRectGetMidX(self.bounds),CGRectGetMinY(self.bounds)};
    CGPoint endPoint   = (CGPoint){CGRectGetMidX(self.bounds),CGRectGetMaxY(self.bounds)};
    CGContextDrawLinearGradient(context,gradient,startPoint,endPoint,0);
    
    CGGradientRelease(gradient);
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsPopContext();
    UIGraphicsEndImageContext();
    return img;
}
@end



#pragma mark -

/**
 *  BannerScrollViewConfiguration is in the service of "BannerScrollView" configuration model object .
 *  Use BannerScrollViewConfiguration (quickConfigurationTitleFontSize:) method can realize rapid configuration .
 *  Use BannerScrollViewConfiguration (instanceBannerConfigurationPlaceholderImage:) method implement a custom configuration .
 */
@implementation BannerScrollViewConfiguration

+ (instancetype)quickConfigurationTitleFontSize:(CGFloat)fontSize
                                     titleColor:(UIColor* )titleColor
                              pageSelectedColor:(UIColor* )pageColor
                                          style:(BannerScrollViewStyle)style
{
    return [self instanceBannerConfigurationPlaceholderImage:nil orColor:nil needTitle:YES titleHeight:50 titleAlignment:WidgetHorizontalAlignmenttLeft andTitleFontName:nil andTitleFontSize:fontSize andTitleColor:titleColor needPage:YES pageAlignment:WidgetHorizontalAlignmentRight andPageDefaultColor:nil andPageSelectedColor:pageColor needDiskCache:YES style:style];
}

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
                                                      style:(BannerScrollViewStyle)style
{
    BannerScrollViewConfiguration* cofig = [BannerScrollViewConfiguration new];
    
    cofig.placeholderImage = placeholderImage;
    cofig.colors = cofig.placeholderImage ? nil : colors ?: @[[[UIColor grayColor] colorWithAlphaComponent:0.5] , [UIColor whiteColor]];
    
    cofig.needTitle = isNeedTitle;
    cofig.titleHeight = titleHeight > 0 ?: 50;
    cofig.titleAlignment = titleAlignment;
    cofig.fontName = fontName ?: [UIFont systemFontOfSize:15].fontName;
    cofig.fontSize = fontSize > 0 ?: 15;
    cofig.titleColor = titleColor ?: [UIColor whiteColor];
    
    cofig.needPage = isNeedPage;
    cofig.pageAlignment = pageAlignment;
    cofig.defaultColor = defaultColor ?: [UIColor whiteColor];
    cofig.selectedColor = selectedColor;
    
    cofig.needDiskCache = isNeedDiskCache;
    cofig.style = style;
    
    return cofig;
}

@end


#pragma mark -

/**
 *  OSCBannerModel are specially serve BannerScrollView model object .
 *  Because BannerScrollView required data is very lightweight ,  So I suggest you to convert the model .
 */
@implementation OSCBannerModel

+ (instancetype)bannerModelWithTitle:(NSString *)title
                        netImagePath:(NSString *)netImagePath
                      localImageData:(NSData *)localImageData
{
    OSCBannerModel* model = [OSCBannerModel new];
    model.title = title;
    model.netImagePath = netImagePath;
    model.localImageData = localImageData;
    return model;
}

@end



