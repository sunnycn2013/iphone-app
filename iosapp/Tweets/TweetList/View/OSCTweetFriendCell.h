//
//  OSCTweetFriendCell.h
//  iosapp
//
//  Created by 李萍 on 2016/12/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol OSCTweetFriendIDelegate <NSObject>

- (void)clickImageAction:(NSInteger)imageRow;

@end

@interface OSCTweetFriendCell : UITableViewCell


+ (instancetype)returnReuseTextTweetCellWithTableView:(UITableView* )tableView
                                           identifier:(NSString* )reuseIdentifier;

@property (nonatomic, strong) NSMutableArray *selectedFriends;
@property (nonatomic, assign) id <OSCTweetFriendIDelegate> delegate;

@end
