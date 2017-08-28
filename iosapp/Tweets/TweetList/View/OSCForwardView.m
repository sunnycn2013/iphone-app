//
//  OSCForwardView.m
//  iosapp
//
//  Created by Graphic-one on 16/12/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCForwardView.h"
#import "Utils.h"
#import "OSCTweetItem.h"
#import "OSCAbout.h"
#import "ImageDownloadHandle.h"
#import "AsyncDisplayTableViewCell.h"
#import "OSCPushTypeControllerHelper.h"
#import "OSCPhotoGroupView.h"

#import "UIColor+Util.h"

#import <UIImage+GIF.h>
#import <SDWebImageDownloader.h>
#import <UIImageView+WebCache.h>
#import <YYKit.h>


@interface OSCForwardView ()
{
    OSCForwardViewType _curForwardViewType;
    NSMutableArray* _imageViewsArray;   //二维数组 _imageViewsArray[line][row]
    NSMutableArray<OSCNetImage* >* _largerImageUrls;   //本地维护的大图数组
    NSMutableArray<UIImageView* >* _visibleImageViews;   //可见的imageView数组
    
    CGFloat _multiple_WH;
    CGFloat _imageItem_WH;
    CGFloat Multiple_Padding;
    CGFloat ImageItemPadding;
    
    CGRect _titleLb_Frame;
    CGRect _contentTextView_Frame;
    CGRect _pieceImage_Frame;
    MultipleImageViewFrame _multipleImageViewFrame;
    
    BOOL _trackTouchPieceImage;
    BOOL _trackTouchImagesView;
}
@end

@implementation OSCForwardView{
    __weak YYLabel* _titleLb;
    __weak UITextView* _contentTextView;
    
    __weak UIImageView* _imageTypeLogo;
    __weak UIView* _imagesView;//多图父容器
    __weak UIImageView* _pieceImage;//单图容器
}

- (instancetype)initWithType:(OSCForwardViewSource)type
{
    self = [super init];
    if (self) {
        /** 全局padding值*/
        Multiple_Padding = forwardView_padding_left;
        ImageItemPadding = 8;
        
        /** 动态值维护*/
        CGFloat fullWidth ;
        switch (type) {
            case OSCForwardViewSource_list:
                fullWidth = forwardView_FullWidth_list;
                break;
            case OSCForwardViewSource_detail:
                fullWidth = forwardView_FullWidth_detail;
                break;
            case OSCForwardViewSource_editorUI:
                fullWidth = forwardView_FullWidth_detail;
                break;
                
            default:
                fullWidth = forwardView_FullWidth_list;
                break;
        }
        CGFloat multiple_WH = ceil((fullWidth - (Multiple_Padding * 2)));
        _multiple_WH = multiple_WH;
        CGFloat imageItem_WH = ceil(((multiple_WH - (2 * ImageItemPadding)) / 3 ));
        _imageItem_WH = imageItem_WH;
        
        [self settingUI];

        _canEnterDetailPage = YES;
        _canToViewLargerIamge = NO;
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self settingUI];
//        _canEnterDetailPage = YES;
//        _canToViewLargerIamge = NO;
//    }
//    return self;
//}

#pragma mark --- settingUI
- (void)settingUI{
    _largerImageUrls = [NSMutableArray arrayWithCapacity:9];
    _visibleImageViews = [NSMutableArray arrayWithCapacity:9];
    
    self.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
    
    YYLabel* titleLb = [YYLabel new];
    _titleLb = titleLb;
    _titleLb.font = [UIFont systemFontOfSize:titleLb_font_size];
    _titleLb.numberOfLines = 2;
    _titleLb.textColor = [UIColor colorWithHex:0x24CF5F];
    [self addSubview:_titleLb];
    
    UITextView* contentTextView = [UITextView new];
    _contentTextView = contentTextView;
    [_contentTextView setTextContainerInset:UIEdgeInsetsZero];
    [_contentTextView setContentInset:UIEdgeInsetsMake(0, -1, 0, 1)];
    _contentTextView.textContainer.lineFragmentPadding = 0;
    _contentTextView.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
    [_contentTextView setTextAlignment:NSTextAlignmentLeft];
    _contentTextView.font = [UIFont systemFontOfSize:contectLb_font_size];
    _contentTextView.textColor = [UIColor colorWithHex:0x6A6A6A];
    _contentTextView.editable = NO;
    _contentTextView.scrollEnabled = NO;
    _contentTextView.backgroundColor = [UIColor clearColor];
    _contentTextView.userInteractionEnabled = NO;
    _contentTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_contentTextView];
    
/** 多图 **/
    
    UIView* imagesView = [UIView new];
    _imagesView = imagesView;
    [self addSubview:_imagesView];
    
    [self addMultiples];
    
/** 单图 **/
    UIImageView* pieceImage = [UIImageView new];
    _pieceImage = pieceImage;
    _pieceImage.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.8];
    _pieceImage.contentMode = UIViewContentModeScaleAspectFill;
    _pieceImage.clipsToBounds = YES;
    _pieceImage.userInteractionEnabled = NO;
    [self addSubview:_pieceImage];
//    图片类型标识
    UIImageView* imageTypeLogo = [UIImageView new];
    _imageTypeLogo = imageTypeLogo;
    _imageTypeLogo.frame = (CGRect){{_pieceImage.bounds.size.width - 18 - 2,_pieceImage.bounds.size.height - 11 - 2 },{18,11}};
    imageTypeLogo.hidden = YES;
    [_pieceImage addSubview:imageTypeLogo];
    
}
- (void)addMultiples{
    _imageViewsArray = [NSMutableArray arrayWithCapacity:3];
    
    CGFloat originX = 0;
    CGFloat originY = 0;
    for (int i = 0 ; i < 3; i++) {//line
        originY = i * (_imageItem_WH + ImageItemPadding);
        NSMutableArray* lineNodes = [NSMutableArray arrayWithCapacity:3];
        for (int j = 0; j < 3; j++) {//row
            originX = j * (_imageItem_WH + ImageItemPadding);
            UIImageView* imageView = [[UIImageView alloc]init];
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadLargeImageWithTap:)]];
            imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.8];
            imageView.hidden = YES;
            imageView.userInteractionEnabled = NO;
            imageView.frame = (CGRect){{originX,originY},{_imageItem_WH,_imageItem_WH}};
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_imagesView addSubview:imageView];
/** imageTypeLogo */
            UIImageView* imageTypeLogo = [UIImageView new];
            imageTypeLogo.userInteractionEnabled = NO;
            imageTypeLogo.hidden = YES;
            [imageView addSubview:imageTypeLogo];
            
            [lineNodes addObject:imageView];
        }
        [_imageViewsArray addObject:lineNodes];
    }
}

#pragma mark --- layout SubViews
- (void)layoutSubviews{
    [super layoutSubviews];
    
    switch (_curForwardViewType) {
        case OSCForwardViewType_NoPIC:
        {
            _titleLb.frame = _titleLb_Frame;
            _contentTextView.frame = _contentTextView_Frame;
            break;
        }
            
        case OSCForwardViewType_OnlyPIC:{
            _titleLb.frame = _titleLb_Frame;
            _contentTextView.frame = _contentTextView_Frame;
            _pieceImage.frame = _pieceImage_Frame;
            break;
        }
            
        case OSCForwardViewType_MultiplePIC:{
            _titleLb.frame = _titleLb_Frame;
            _contentTextView.frame = _contentTextView_Frame;
            _imagesView.frame = _multipleImageViewFrame.frame;
            break;
        }
            
        default:
            break;
    }
    
}

#pragma mark --- setting Item
- (void)setForwardItem:(OSCAbout *)forwardItem{
    _forwardItem = forwardItem;
    
    if (_forwardItem.type == InformationTypeTweet) {
        _contentTextView.textContainer.maximumNumberOfLines = 0;
    }else{
        _contentTextView.textContainer.maximumNumberOfLines = 3;
    }
    
    if (forwardItem.images.count > 1) {
        _curForwardViewType = OSCForwardViewType_MultiplePIC;
    }else if (forwardItem.images.count == 1){
        _curForwardViewType = OSCForwardViewType_OnlyPIC;
    }else{
        _curForwardViewType = OSCForwardViewType_NoPIC;
    }
    
    [self resetForwardView];
    
    _titleLb.text = _forwardItem.title;

    if (forwardItem.type == InformationTypeTweet) {
        NSAttributedString* str = [Utils contentStringFromRawString:_forwardItem.content];
        NSMutableAttributedString* mutableAttributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:str];
        [mutableAttributedStr setAttributes:@{
                                              NSForegroundColorAttributeName : [UIColor colorWithHex:0x24CF5F],
                                              NSFontAttributeName            : [UIFont systemFontOfSize:contectLb_font_size]
                                              }
                                      range:NSMakeRange(0, _forwardItem.title.length)];
        [mutableAttributedStr addAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHex:0x6a6a6a] , NSFontAttributeName : [UIFont systemFontOfSize:contectLb_font_size]} range:NSMakeRange(_forwardItem.title.length, str.length - _forwardItem.title.length)];
        _contentTextView.attributedText = mutableAttributedStr;
    }else{
        _contentTextView.text = _forwardItem.content;
    }
    
    [self handleForwardViewType];
    
    _titleLb_Frame = _forwardItem.titleLabelFrame;
    _contentTextView_Frame = _forwardItem.contectTextViewFrame;
    
    self.height = _forwardItem.viewHeight;
}

- (void)handleForwardViewType
{
    switch (_curForwardViewType) {
        case OSCForwardViewType_MultiplePIC:
        {
            
            for (OSCNetImage* imageDataSource in _forwardItem.images) {
                [_largerImageUrls addObject:imageDataSource];
            }
            
            if (_pieceImage.superview) {  [_pieceImage removeFromSuperview]; }
            
            [self loopAssemblyContentWithLine:_forwardItem.forwardingMultipleFrame.line
                                          row:_forwardItem.forwardingMultipleFrame.row
                                        count:(int)_forwardItem.images.count];
            
            _multipleImageViewFrame = _forwardItem.forwardingMultipleFrame;
            
            break;
        }
            
            
        case OSCForwardViewType_OnlyPIC:
        {
            if (_imagesView.superview) { [_imagesView removeFromSuperview]; }
            
            OSCNetImage* imageData = [_forwardItem.images firstObject];
            BOOL isGif = [imageData.thumb hasSuffix:@".gif"];
            if (isGif) {
                _imageTypeLogo.image = [[AsyncDisplayTableViewCell new] gifImage];
                _imageTypeLogo.hidden = NO;
            }

            [_pieceImage sd_setImageWithURL:[NSURL URLWithString:imageData.href] placeholderImage:[Utils createImageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (isGif) {
                    NSData *dataImage = UIImagePNGRepresentation(image);
                    image = [UIImage sd_animatedGIFWithData:dataImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_pieceImage setImage:image];
                    });
                }
                _pieceImage.userInteractionEnabled = YES;
            }];
            _pieceImage_Frame = _forwardItem.imageFrame;

            break;
        }
            
            
        case OSCForwardViewType_NoPIC:
        {
            if (_imagesView.superview) { [_imagesView removeFromSuperview]; }
            if (_pieceImage.superview) {  [_pieceImage removeFromSuperview]; }
            
            break;
        }
            
        default:
            break;
    }
}

//为多图容器赋值
-(void)loopAssemblyContentWithLine:(int)line row:(int)row count:(int)count{
    int dataIndex = 0;
    for (int i = 0; i < line; i++) {
        for (int j = 0; j < row; j++) {
            if (dataIndex == count) return;
            OSCNetImage* imageData = _forwardItem.images[dataIndex];
            UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
            imageView.tag = dataIndex;
            imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.6];
            imageView.hidden = NO;
            [_visibleImageViews addObject:imageView];
            
            BOOL isGif = [imageData.thumb hasSuffix:@".gif"];
            if (isGif){
                UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                imageTypeLogo.frame = (CGRect){{imageView.bounds.size.width - 18 - 2,imageView.bounds.size.height - 11 - 2 },{18,11}};
                imageTypeLogo.image = [[AsyncDisplayTableViewCell new] gifImage];
                imageTypeLogo.hidden = NO;
            }
            
///< 只检索小图 然后再打开大图的回调里面把小图url换成大图url实现回调清晰
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageData.thumb] placeholderImage:[Utils createImageWithColor:[[UIColor grayColor] colorWithAlphaComponent:0.6]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (isGif) {
                    NSData *dataImage = UIImagePNGRepresentation(image);
                    image = [UIImage sd_animatedGIFWithData:dataImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [imageView setImage:image];
                    });
                }
                imageView.userInteractionEnabled = YES;
            }];
            
            dataIndex++;
        }
    }
}

#pragma mark --- gestureRecognizers open
- (void)setCanEnterDetailPage:(BOOL)canEnterDetailPage{
    _canEnterDetailPage = canEnterDetailPage;
    
    self.userInteractionEnabled = _canEnterDetailPage;

    if (_canEnterDetailPage && (!self.gestureRecognizers || self.gestureRecognizers.count == 0)) {
        UITapGestureRecognizer* tapGestureGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchInForwardView:)];
        [self addGestureRecognizer:tapGestureGecognizer];
    }
}
- (void)setCanToViewLargerIamge:(BOOL)canToViewLargerIamge{
    _canToViewLargerIamge = canToViewLargerIamge;
    
    _pieceImage.userInteractionEnabled = _canToViewLargerIamge;
    
    if (_canToViewLargerIamge && (!_pieceImage.gestureRecognizers || _pieceImage.gestureRecognizers.count == 0))
    {
        UITapGestureRecognizer* tapGestureGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchInImages:)];
        [_pieceImage addGestureRecognizer:tapGestureGecognizer];
    }
    
    _imagesView.userInteractionEnabled = _canToViewLargerIamge;

}

#pragma mark --- gestureRecognizers handle
- (void)touchInForwardView:(UITapGestureRecognizer* )tap
{
    switch (tap.state)
    {
        case UIGestureRecognizerStateBegan:
            self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
            break;
            
        case UIGestureRecognizerStateEnded:
            self.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
                if ([_delegate respondsToSelector:@selector(forwardViewDidClick:)]) {
                    [_delegate forwardViewDidClick:self];
                }
            break;
            
        case UIGestureRecognizerStateCancelled:
            self.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
            break;
            
        default:
            break;
    }
}
- (void)touchInImages:(UITapGestureRecognizer* )tap
{
    UIImageView* fromView = _pieceImage;
    OSCNetImage* tweetItem = [_forwardItem.images lastObject];
    
    OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
    currentPhotoItem.largeImageURL = [NSURL URLWithString:tweetItem.href];
    currentPhotoItem.thumbView = fromView;
    currentPhotoItem.largeImageSize = (CGSize){tweetItem.w,tweetItem.h};
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
    
    if ([_delegate respondsToSelector:@selector(forwardViewDidLoadLargeImage:photoGroupView:fromView:)]) {
        [_delegate forwardViewDidLoadLargeImage:self photoGroupView:photoGroup fromView:fromView];
    }
}




#pragma mark --- 加载大图
- (void)loadLargeImageWithTap:(UITapGestureRecognizer* )tap{
    UIImageView* fromView = (UIImageView* )tap.view;
    int index = (int)fromView.tag;
    //    current touch object
    OSCNetImage* image =  _largerImageUrls[index];
    
    //    all imageItem objects
    NSMutableArray* photoGroupItems = [NSMutableArray arrayWithCapacity:_largerImageUrls.count];
    
    for (int i = 0; i < _largerImageUrls.count; i++) {
        OSCNetImage* iamges =  _largerImageUrls[i];
        OSCPhotoGroupItem* photoItem = [OSCPhotoGroupItem new];
        photoItem.thumbView = _visibleImageViews[i];
        photoItem.largeImageURL = [NSURL URLWithString:iamges.href];
        photoItem.largeImageSize = (CGSize){image.w,image.h};
        [photoGroupItems addObject:photoItem];
    }
    
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];
    
    if ([_delegate respondsToSelector:@selector(forwardViewDidLoadLargeImage:photoGroupView:fromView:)]) {
        [_delegate forwardViewDidLoadLargeImage:self photoGroupView:photoGroup fromView:fromView];
    }
}
#pragma mark --- 重置 ForwardView
- (void)resetForwardView
{
    switch (_curForwardViewType) {
        case OSCForwardViewType_NoPIC:{
            
            break;
        }
            
        case OSCForwardViewType_OnlyPIC:{
            _pieceImage.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.8];
            _pieceImage.userInteractionEnabled = NO;
            _pieceImage.image = nil;
            break;
        }
            
        case OSCForwardViewType_MultiplePIC:{
            for (int i = 0; i < 3; i++) {
                for (int j = 0; j < 3; j++) {
                    UIImageView* imageView = (UIImageView* )_imageViewsArray[i][j];
                    imageView.backgroundColor = [[UIColor grayColor]colorWithAlphaComponent:0.8];
                    imageView.userInteractionEnabled = NO;
                    imageView.tag = 0;
                    imageView.hidden = YES;
                    imageView.image = nil;
                    [_largerImageUrls removeAllObjects];
                    [_visibleImageViews removeAllObjects];
                    UIImageView* imageTypeLogo = (UIImageView* )[[imageView subviews] lastObject];
                    imageTypeLogo.image = nil;
                    imageTypeLogo.hidden = YES;
                }
            }
            break;
        }
            
        default:
            break;
    }

}

@end





//#pragma mark --- touch handle
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    _trackTouchPieceImage = NO;
//    _trackTouchImagesView = NO;
//
//    if (self.isCanEnterDetailPage) {
//        if (self.isCanToViewLargerIamge) {
//            switch (_curForwardViewType) {
//                case OSCForwardViewType_OnlyPIC:
//                    _trackTouchPieceImage = [self touchInViewWithTouches:touches view:_pieceImage];
//                    break;
//
//                case OSCForwardViewType_MultiplePIC:
//                    _trackTouchImagesView = [self touchInViewWithTouches:touches view:_imagesView];
//                    break;
//
//                default:
//                    break;
//            }
//        }else{
//            self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
//        }
//    }else{
//        [super touchesBegan:touches withEvent:event];
//    }
//}
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    if (self.isCanEnterDetailPage) {
//        if (self.isCanToViewLargerIamge) {
//            if (( (_curForwardViewType == OSCForwardViewType_OnlyPIC) && (_trackTouchPieceImage)) ||
//                ( (_curForwardViewType == OSCForwardViewType_MultiplePIC) && (_trackTouchImagesView))) {
//                // Handled by gestures touching ...
//            }else{
//                self.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
//                if ([_delegate respondsToSelector:@selector(forwardViewDidClick:)]) {
//                    [_delegate forwardViewDidClick:self];
//                }
//            }
//        }else{
//            self.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
//            if ([_delegate respondsToSelector:@selector(forwardViewDidClick:)]) {
//                [_delegate forwardViewDidClick:self];
//            }
//        }
//    }else{
//        [super touchesEnded:touches withEvent:event];
//    }
//}
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    if (self.isCanEnterDetailPage) {
//        self.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
//    }else{
//        [super touchesCancelled:touches withEvent:event];
//    }
//}
//
//- (BOOL)touchInViewWithTouches:(NSSet<UITouch *> *)touches view:(UIView* )view{
//    UITouch* t = [touches anyObject];
//    CGPoint p = [t locationInView:view];
//    if (CGRectContainsPoint(view.bounds, p)) {
//        return YES;
//    }else{
//        return NO;
//    }
//}


//#pragma mark --- 加载大图
//- (void)loadLargeImageWithTap:(UITapGestureRecognizer* )tap{
//    UIImageView* fromView = (UIImageView* )tap.view;
//
//    NSMutableArray* photoGroupItems = [NSMutableArray arrayWithCapacity:_largerImageUrls.count];
//
//    OSCTweetImages* image =  _largerImageUrls[index];
//
//    for (int i = 0; i < _largerImageUrls.count; i++) {
//        OSCTweetImages* iamges =  _largerImageUrls[i];
//        OSCPhotoGroupItem* photoItem = [OSCPhotoGroupItem new];
//        photoItem.thumbView = _visibleImageViews[i];
//        photoItem.largeImageURL = [NSURL URLWithString:iamges.href];
//        photoItem.largeImageSize = (CGSize){image.w,image.h};
//        [photoGroupItems addObject:photoItem];
//    }
//
//    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:photoGroupItems];
//
//    if ([_delegate respondsToSelector:@selector(forwardViewDidLoadLargeImage:photoGroupView:fromView:)]) {
//        [_delegate forwardViewDidLoadLargeImage:self photoGroupView:photoGroup fromView:fromView];
//    }
//}



//- (void)touchInImages:(UITapGestureRecognizer* )tap
//{
//    switch (_curForwardViewType)
//    {
//        case OSCForwardViewType_OnlyPIC:{
//            UIImageView* fromView = _pieceImage;
//            OSCTweetImages* tweetItem = [_forwardItem.images lastObject];
//
//            OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
//            currentPhotoItem.largeImageURL = [NSURL URLWithString:tweetItem.href];
//            currentPhotoItem.thumbView = fromView;
//            currentPhotoItem.largeImageSize = (CGSize){tweetItem.w,tweetItem.h};
//
//            OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
//
//            if ([_delegate respondsToSelector:@selector(forwardViewDidLoadLargeImage:photoGroupView:fromView:)]) {
//                [_delegate forwardViewDidLoadLargeImage:self photoGroupView:photoGroup fromView:fromView];
//            }
//            break;
//        }
//
//        case OSCForwardViewType_MultiplePIC:{
//            [self loadLargeImageWithTap:tap];
//            break;
//        }
//
//        default:
//            break;
//    }
//}




//    if (_canToViewLargerIamge && (!_imagesView.gestureRecognizers || _imagesView.gestureRecognizers.count == 0))
//    {
//        UITapGestureRecognizer* tapGestureGecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchInImages:)];
//        [_imagesView addGestureRecognizer:tapGestureGecognizer];
//    }

