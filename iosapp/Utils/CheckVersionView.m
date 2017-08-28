//
//  CheckVersionView.m
//  iosapp
//
//  Created by wupei on 2017/5/9.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "CheckVersionView.h"
#import <YYLabel.h>
#import <Masonry.h>

@interface CheckVersionView ()


@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation CheckVersionView

- (IBAction)closeBtnClick:(id)sender {
    
    
    if ([self.delegate respondsToSelector:@selector(closeBtnClick)]) {
        [self.delegate closeBtnClick];
    }
    
}
- (IBAction)updateBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(updateBtnClick)]) {
        [self.delegate updateBtnClick];
    }
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    //if内的条件应该为，当触摸点point超出蓝色部分，但在黄色部分时
    
    if (CGRectContainsPoint(self.frame,point)||CGRectContainsPoint(self.closeBtn.frame,point)) {
        return YES;
    }
    
    return NO;
}

@end
