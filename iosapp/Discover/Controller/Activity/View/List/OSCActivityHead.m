//
//  OSCActivityHead.m
//  iosapp
//
//  Created by 李萍 on 2016/12/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCActivityHead.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UILabel+VerticalAlign.h"
#import "Utils.h"
#import "OSCPageControl.h"

@interface OSCActivityHead () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) OSCPageControl *pageCtl;

@property (nonatomic, strong) UIImageView *bottomImageView;
@property (nonatomic, assign) NSInteger currentIndex;
@property NSTimer *timer;

@end

@implementation OSCActivityHead

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentIndex = 0;
    }
    return self;
}

- (void)setUpScrollView:(NSMutableArray *)bannners
{
    _banners = bannners;
    
    NSInteger arrayCount = bannners.count;
    _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * arrayCount, CGRectGetHeight(self.frame));
    _scrollView.pagingEnabled = YES;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_scrollView];
    
    _pageCtl = [[OSCPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-27, CGRectGetWidth(self.frame) - 16, 27)];
    _pageCtl.backgroundColor = [UIColor clearColor];
    _pageCtl.currentPage = 0;
    _pageCtl.numberOfPages = arrayCount;
    _pageCtl.currentPageIndicatorTintColor = [UIColor newSectionButtonSelectedColor];
    _pageCtl.pageIndicatorTintColor = [UIColor whiteColor];
    _pageCtl.pageControlDotAlignment = UIPageControlDotAlignmentRight;
    _pageCtl.dotNomalWidth = 5;
    _pageCtl.dotPadding = 5;
    [self addSubview:_pageCtl];
    
    CGFloat imageViewWidth = CGRectGetWidth(_scrollView.frame);
    CGFloat imageViewHeight = CGRectGetHeight(_scrollView.frame);
    
    for (int i = 0; i < arrayCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewWidth * i, 0, imageViewWidth, imageViewHeight)];
        imageView.tag = i+1;
        imageView.contentMode = UIViewContentModeLeft & UIViewContentModeTopRight;
        imageView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeCenter;
        [_scrollView addSubview:imageView];
        OSCBanner *banner  = bannners[i];

        [imageView sd_setImageWithURL:[NSURL URLWithString:banner.img] placeholderImage:[UIImage imageNamed:@"event_cover_default"] options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if(!error){
                    imageView.contentMode = UIViewContentModeScaleToFill;
                }
        }];
        
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickTopImage:)]];
    }
    if (arrayCount > 1) {
        if(!self.timer) {
            self.timer = [NSTimer timerWithTimeInterval:4.0f target:self selector:@selector(scrollToNextPage:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            [self.timer fire];
        }
    }
}

- (void)setBanners:(NSMutableArray *)banners
{
    [self setUpScrollView:banners];
}

#pragma mark - 自动滚动
- (void)scrollToNextPage:(NSTimer *)timer
{
    _currentIndex++;
    if (_currentIndex >= _banners.count) {
        _currentIndex = 0;
    }
    _pageCtl.currentPage = _currentIndex;
    [_scrollView setContentOffset:CGPointMake(_currentIndex*CGRectGetWidth(_scrollView.frame), 0) animated:YES];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentIndex = scrollView.contentOffset.x/CGRectGetWidth(self.frame);
    _pageCtl.currentPage = _currentIndex;
}

#pragma mark - /*点击滚动图片*/
- (void)clickTopImage:(UITapGestureRecognizer *)tap
{
    if ([delegate respondsToSelector:@selector(clickScrollViewBanner:)]) {
        [delegate clickScrollViewBanner:tap.view.tag-1];
    }
}

@end
