//
//  OSCPageControl.m
//  test
//
//  Created by 李萍 on 2016/12/14.
//  Copyright © 2016年 李萍. All rights reserved.
//

#import "OSCPageControl.h"

@implementation OSCPageControl

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_dotCurrentWidth == 0) {
        _dotCurrentWidth = _dotNomalWidth;
    } else {
        _dotCurrentWidth = _dotCurrentWidth+0;
    }
    
    //计算圆点间距
    CGFloat marginX = _dotNomalWidth + _dotPadding;
    //遍历subview,设置圆点frame
    
    int  dotsCount = (int)[self.subviews count];
    for (int i = 0; i < dotsCount; i++) {
        UIImageView* dot = [self.subviews objectAtIndex:i];
        
        CGFloat dotX = 0;
        NSInteger alignMent = (NSInteger)self.pageControlDotAlignment;
        switch (alignMent) {
            case UIPageControlDotAlignmentLeft:
            {
                dotX = i * marginX;
                break;
            }
            case UIPageControlDotAlignmentCenter:
            {
                //计算整个pageControll的宽度
                CGFloat newW = (self.subviews.count) * marginX - self.dotPadding;
                //设置新frame
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newW, self.frame.size.height);
                //设置居中
                CGPoint center = self.center;
                center.x = self.superview.center.x;
                self.center = center;
                
                dotX = i * marginX;
                
                break;
            }
            case UIPageControlDotAlignmentRight:
            {
                CGFloat selfWidth = CGRectGetWidth(self.frame);
                dotX = selfWidth - ((dotsCount - 1 - i) * marginX + self.dotNomalWidth);
                
                break;
            }
            default:
            {
                dotX = i * marginX;
                break;
            }
                
        }
        
        
        if (i == self.currentPage) {
            [dot setFrame:CGRectMake(dotX, dot.frame.origin.y, _dotCurrentWidth, _dotCurrentWidth)];
        }else {
            [dot setFrame:CGRectMake(dotX, dot.frame.origin.y, _dotNomalWidth, _dotNomalWidth)];
        }
    }
}

@end
