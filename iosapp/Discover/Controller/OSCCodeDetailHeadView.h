//
//  OSCCodeDetailHeadView.h
//  iosapp
//
//  Created by wupei on 2017/5/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCCodeSnippetListModel.h"

@interface OSCCodeDetailHeadView : UIView

@property (nonatomic,strong) OSCCodeSnippetListModel *model;

@property (nonatomic, assign) CGFloat headerheight;

- (instancetype)initWithModel:(OSCCodeSnippetListModel *)model;
@end
