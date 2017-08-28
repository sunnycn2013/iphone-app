//
//  OSCForwardView.h
//  iosapp
//
//  Created by Graphic-one on 16/12/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger,OSCForwardViewType){
    OSCForwardViewType_NoPIC,
    OSCForwardViewType_OnlyPIC,
    OSCForwardViewType_MultiplePIC,
};

typedef NS_ENUM(NSUInteger,OSCForwardViewSource){
    OSCForwardViewSource_list       = 0,
    OSCForwardViewSource_detail     = 1,
    OSCForwardViewSource_editorUI   = 2,
} ;

#define forwardView_padding_left 8
#define forwardView_padding_right 8
#define forwardView_padding_top 8
#define forwardView_padding_bottom 8

#define forwardView_PieceImageView_Height 130
#define forwardView_titleLb_maxHeight
#define forwardView_contectTextView_maxHeight

#define forwardView_title_SPACE_content 4
#define forwardView_content_SPACE_picture 10

#define titleLb_font_size 14
#define contectLb_font_size 13

@class OSCForwardView,OSCPhotoGroupView;
@protocol OSCForwardViewDelegate <NSObject>

- (void)forwardViewDidClick:(OSCForwardView* )forwardView;

@optional
- (void)forwardViewDidLoadLargeImage:(OSCForwardView* )forwardView
                      photoGroupView:(OSCPhotoGroupView *)groupView
                            fromView:(UIImageView *)fromView;;

@end

@class OSCAbout;

@interface OSCForwardView : UIView

- (instancetype)initWithType:(OSCForwardViewSource)type;

@property (nonatomic,strong) OSCAbout* forwardItem;

@property (nonatomic,assign,getter=isCanEnterDetailPage) BOOL canEnterDetailPage;///< default is YES

@property (nonatomic,assign,getter=isCanToViewLargerIamge) BOOL canToViewLargerIamge;///< default is NO

@property (nonatomic,weak) id<OSCForwardViewDelegate> delegate;

///** Lock initialization routine method */
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

@end



