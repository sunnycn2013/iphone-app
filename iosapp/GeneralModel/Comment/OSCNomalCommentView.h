//
//  OSCNomalCommentView.h
//  iosapp
//
//  Created by Graphic-one on 17/1/17.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCBaseCommetView.h"
#import "OSCCommentItem.h"

@class OSCCommentItem;
@interface OSCNomalCommentView : OSCBaseCommetView

@property (nonatomic , weak) id<OSCCommetViewDelegate> delegate;

@end
