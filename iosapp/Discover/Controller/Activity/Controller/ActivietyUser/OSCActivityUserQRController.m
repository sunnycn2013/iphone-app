//
//  OSCActivityUserQRController.m
//  iosapp
//
//  Created by 王恒 on 17/4/11.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCActivityUserQRController.h"
#import "OSCPhotoGroupView.h"
#import "OSCNetImage.h"
#import "OSCShareInvitation.h"

#import "UIColor+Util.h"

#import <YYKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <Masonry.h>

@interface OSCActivityUserQRController ()

@property (nonatomic,strong) NSString *imageURL;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *shareBtn;

@end

@implementation OSCActivityUserQRController

- (instancetype)initWithQRImage:(NSString *)imageURL{
    self = [super init];
    if (self) {
        _imageURL = imageURL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configSelf];
    [self addContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configSelf{
    self.navigationItem.title = @"活动报名";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)addContentView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenSize.width, kScreenSize.height - 64 - 60)];
    scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:scrollView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 40, kScreenSize.width - 32, 23)];
    label.font = [UIFont systemFontOfSize:16];
    label.text = @"恭喜，您已报名成功并收到邀请函!";
    label.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:label];
    
    _imageView = [UIImageView new];
    _imageView.backgroundColor = [UIColor separatorColor];
    UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_imageView addSubview:hud];
    [hud startAnimating];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_imageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [hud stopAnimating];
    }];
    
    _imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)];
    [_imageView addGestureRecognizer:tapGR];
    [scrollView addSubview:_imageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor navigationbarColor];
    [button setTitle:@"分享邀请函" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.layer.cornerRadius = 3;
    button.layer.masksToBounds = YES;
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [button setBackgroundImage:[self imageWithColor:[UIColor colorWithHex:0x188E50]] forState:UIControlStateHighlighted];
    
    [self.view addSubview:button];
    
    self.shareBtn = button;
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(label.mas_bottom).offset(20);
        make.centerX.equalTo(scrollView);
        make.width.equalTo(@(190));
        make.height.equalTo(@(338));
    }];
    
    [hud mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_imageView);
        make.centerY.equalTo(_imageView).offset(-20);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(-12);
        make.bottom.equalTo(self.view).offset(-15);
        make.height.equalTo(@(45));
    }];
    
    scrollView.contentSize = CGSizeMake(kScreenSize.width, 411);
}



- (void)imageClick{
    OSCPhotoGroupItem* currentPhotoItem = [OSCPhotoGroupItem new];
    currentPhotoItem.largeImageURL = [NSURL URLWithString:_imageURL];
    currentPhotoItem.largeImageSize = (CGSize){kScreenSize.width,kScreenSize.width * 1.78};
    OSCPhotoGroupView* photoGroup = [[OSCPhotoGroupView alloc] initWithGroupItems:@[currentPhotoItem]];
    [photoGroup presentFromImageView:_imageView toContainer:[[UIApplication sharedApplication] keyWindow] animated:YES completion:^{
    }];
}

- (void)buttonClick{

    UIImage *image = self.imageView.image;
    
    [[OSCShareInvitation shareManager] showShareBoardWithImage:image];
}


//颜色转为图片
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
