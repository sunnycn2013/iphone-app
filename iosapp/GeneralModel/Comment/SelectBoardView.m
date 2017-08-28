//
//  SelectBoardView.m
//  iosapp
//
//  Created by wupei on 2017/4/27.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "SelectBoardView.h"

@interface SelectBoardView ()

@property (weak, nonatomic) IBOutlet UIButton *clipBtn;

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

@property (weak, nonatomic) IBOutlet UIButton *shareBtn;


@end

@implementation SelectBoardView


- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupSubViews];
}

//尺寸布局
- (void)setupSubViews {
    
    //设置图片和文字的距离
    [self.clipBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10 , 0, 0)];
    [self.commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15 , 0, 0)];
    [self.shareBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 15 , 0, 0)];
}

- (IBAction)clipBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(copyClickBtn:)]) {
        
        
        [self.delegate copyClickBtn:self.item];
        
    }
    
}
- (IBAction)commentBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commentClickBtn:)]) {
        
        [self.delegate commentClickBtn:self.item];
        
    }
}

- (IBAction)shareBtnClick:(id)sender {
   
    if ([self.delegate respondsToSelector:@selector(shareClickBtn:)]) {
        
        [self.delegate shareClickBtn:self.item];
        
    }
}



@end
