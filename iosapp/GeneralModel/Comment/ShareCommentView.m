//
//  sharecommentLiew.m
//  iosapp
//
//  Created by wupei on 2017/4/25.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "ShareCommentView.h"
#import "UIView+YYAdd.h"
#import "OSCAPI.h"
#import "Utils.h"
#import "OSCTopCommentView.h"

@interface ShareCommentView ()

@property (nonatomic, strong) UIImageView *logoImageView;//logo
@property (nonatomic, strong) UIView *greenLineV;//绿色线条
@property (nonatomic, strong) UILabel *titleL;//标题
@property (nonatomic, strong) UIImageView *iconImgV;//头像
@property (nonatomic, strong) UILabel *nameL;//名字
@property (nonatomic, strong) UILabel *timeL;//时间


@property (nonatomic, strong) OSCTopCommentView *commentView;//有引用的评论区，直接使用cell的topView

@property (nonatomic, strong) UILabel *unReferL;//无引用的评论区

@property (nonatomic, strong) UIView *lineV;//底部线条

@property (nonatomic, strong) UIImageView *markImgV;//标识图片
@property (nonatomic, strong) UIImageView *qRImgV;//二维码图片
@property (nonatomic, strong) UILabel *bottomL;//底部文字

//


@end

@implementation ShareCommentView

// 步骤3 在initWithFrame:方法中添加子控件
- (instancetype)initWithFrame:(CGRect)frame CommentItem:(OSCCommentItem *)commentItem title:(NSString *)titleStr

{
    
    self.commentItem = commentItem;
   
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *logoImageView = [[UIImageView alloc] init];
        self.logoImageView = logoImageView;
        [logoImageView setImage:[UIImage imageNamed:@"logo_osc_share"]];
        self.logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.logoImageView setContentScaleFactor:[[UIScreen mainScreen] scale]];

        [self addSubview:self.logoImageView];
        
        if (self.commentItem.refer.count <= 0) {//无引用的
            
            self.commentView = [[OSCTopCommentView alloc] initWithViewModel:self.commentItem uxiliaryNodeStyle:CommentUxiliaryNode_none isShare:YES];
            CGFloat height = self.commentView.getShareLHeight;
            self.commentView.height = self.commentItem.layoutInfo.userPortraitFrame.size.height + height + 20;
            
           
            [self addSubview:self.commentView];
        }else{
            //评论区。 有引用的评论区。
            self.commentView = [[OSCTopCommentView alloc] initWithViewModel:self.commentItem uxiliaryNodeStyle:CommentUxiliaryNode_none isShare:YES];
            self.commentView.height = self.commentItem.layoutHeight + 25;
            [self addSubview:self.commentView];
        }
        
    
        //绿线
        self.greenLineV = [[UIView alloc] init];
        [self addSubview:self.greenLineV];

        self.titleL = [[UILabel alloc] init];
        self.titleL.text = titleStr;
        [self addSubview:self.titleL];
        
        
        self.lineV = [[UIView alloc] init];
        self.lineV.backgroundColor = [UIColor colorWithRed:200/255.0 green:199/255.0 blue:204/255.0 alpha:1/1.0];
        [self addSubview:self.lineV];
        
        self.markImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];//标识图片
        self.markImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.markImgV setContentScaleFactor:[[UIScreen mainScreen] scale]];
        [self addSubview:self.markImgV];
        
        self.qRImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qrcode"]];//二维码图片
        self.qRImgV.contentMode = UIViewContentModeScaleAspectFit;
        [self.qRImgV setContentScaleFactor:[[UIScreen mainScreen] scale]];
        [self addSubview:self.qRImgV];
        
        self.bottomL = [[UILabel alloc] init];
        self.bottomL.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        self.bottomL.textColor = [UIColor colorWithRed:157/255.0 green:157/255.0 blue:157/255.0 alpha:1/1.0];
        self.bottomL.textAlignment = NSTextAlignmentRight;

        self.bottomL.text = @"长按识别图中二维码";
        
        [self addSubview:self.bottomL];
        
    }


    return self;
}

// 步骤4 在`layoutSubviews`方法中设置子控件的`frame`（在该方法中一定要调用`[super layoutSubviews]`方法）
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    //1、logoV
    self.logoImageView.width =  200;
    self.logoImageView.height = 35;
    self.logoImageView.top = 20;
    [self.logoImageView setCenterX:self.width/2];


    //2、
    self.greenLineV.backgroundColor = [UIColor colorWithHex:0x24CF5F];
    self.greenLineV.frame = CGRectMake(16, 90, 2, 16);
    
    //标题
    
    self.titleL.frame = CGRectMake(25, 85, 334, 50);
    self.titleL.font = [UIFont systemFontOfSize:18.0];
    self.titleL.numberOfLines = 0;
    self.titleL.textAlignment = NSTextAlignmentLeft;
    // 设置文字属性 要和label的一致
    NSDictionary *attrs = @{NSFontAttributeName : self.titleL.font};
    CGSize maxSize = CGSizeMake(self.width - 32, MAXFLOAT);
    
    // 计算文字占据的高度
    CGSize size = [_titleL.text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    self.titleL.width = size.width;
    self.titleL.height = size.height;
    
    if (self.commentItem.refer.count <= 0 ) {
        //3、有引用评论区
        self.commentView.top = CGRectGetMaxY(self.titleL.frame)+20;
        //底部线条
        self.lineV.top = self.commentView.top + self.commentView.frame.size.height + 35;
        self.lineV.width = 343;
        self.lineV.height = 0.5;
        self.lineV.left = 16;
    }else
    
    {
    
        //3、有引用评论区
        self.commentView.top = CGRectGetMaxY(self.titleL.frame)+20;
        
        //底部线条
        
        self.lineV.top = self.commentView.top + self.commentView.frame.size.height + 12;
        self.lineV.width = 343;
        self.lineV.height = 0.5;
        self.lineV.left = 16;
    }
    
    //4、icon 和 二维码
    self.markImgV.width = 40;
    self.markImgV.height = 40;
    self.markImgV.top = self.lineV.bottom + 20;
    self.markImgV.right = self.width - 68;
    
    self.qRImgV.width = 40;
    self.qRImgV.height = 40;
    self.qRImgV.top = self.markImgV.top;
    self.qRImgV.right = self.width - 16;
    
    
    //5、底部文字
    
    self.bottomL.width = 230;
    self.bottomL.height = 35;
    self.bottomL.top = self.qRImgV.bottom + 5;
    self.bottomL.right = self.width - 16;
    
    self.height = CGRectGetMaxY(self.bottomL.frame) + 20;
}




@end
