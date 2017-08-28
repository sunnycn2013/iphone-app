//
//  OSCActivityHead.h
//  iosapp
//
//  Created by 李萍 on 2016/12/15.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCBanner.h"

@protocol OSCActivityHeadDelegate <NSObject>

- (void)clickScrollViewBanner:(NSInteger)bannerTag;

@end


@interface OSCActivityHead : UIView

@property (nonatomic, strong) NSMutableArray *banners;
@property (nonatomic, strong) id <OSCActivityHeadDelegate> delegate;

@end
