//
//  OSCTweetDetailContentCell.h
//  iosapp
//
//  Created by Graphic-one on 16/12/6.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYKit.h>

@class OSCTweetDetailContentCell , OSCPhotoGroupView ;
@protocol OSCTweetDetailPageDelegate <NSObject>

- (void) userPortraitDidClick:(__kindof OSCTweetDetailContentCell* )tweetDetailCell;

- (void) commentButtonDidClick:(__kindof OSCTweetDetailContentCell* )tweetDetailCell;

- (void) likeButtonDidClick:(__kindof OSCTweetDetailContentCell* )tweetDetailCell
                tapGestures:(UITapGestureRecognizer* )tap;

- (void) forwardButtonDidClick:(__kindof OSCTweetDetailContentCell* )tweetDetailCell;

- (void) shouldInteract:(__kindof OSCTweetDetailContentCell* )tweetDetailCell
               TextView:(UITextView* )textView
                    URL:(NSURL *)URL
                inRange:(NSRange)characterRange;

@optional
- (void) loadLargeImageDidFinsh:(__kindof OSCTweetDetailContentCell* )tweetDetailCell
                 photoGroupView:(OSCPhotoGroupView* )groupView
                       fromView:(UIImageView* )fromView;

- (void) forwardViewDidClick:(__kindof OSCTweetDetailContentCell* )tweetDetailCell;

@end

@interface OSCTweetDetailContentCell : UITableViewCell

@end
