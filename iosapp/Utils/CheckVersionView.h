//
//  CheckVersionView.h
//  iosapp
//
//  Created by wupei on 2017/5/9.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckVersionViewDelegate  <NSObject>

- (void)updateBtnClick;

- (void)closeBtnClick;



@end
@interface CheckVersionView : UIView


@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@property (weak, nonatomic) IBOutlet UITextView *contentView;

@property (nonatomic, assign) id delegate;
@end
