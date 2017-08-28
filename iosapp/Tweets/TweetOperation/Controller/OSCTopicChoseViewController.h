//
//  OSCTopicChoseViewController.h
//  iosapp
//
//  Created by 王恒 on 17/1/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopicChoseVCDelegate <NSObject>

- (void)completeChoseTopicWithTopicString:(NSString *)topicString;

@end

@interface OSCTopicChoseViewController : UIViewController

@property (nonatomic,weak) id<TopicChoseVCDelegate> topicDelegate;

- (instancetype)init;

@end
