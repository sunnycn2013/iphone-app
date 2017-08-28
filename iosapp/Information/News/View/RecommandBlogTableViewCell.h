//
//  RecommandBlogTableViewCell.h
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCAbout;
@interface RecommandBlogTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

//提供给最后一个cell取消分割线的接口
@property (nonatomic,assign,getter=isHiddenColorLine) BOOL hiddenLine;

@property (nonatomic, strong) OSCAbout *abouts;

@property (nonatomic, strong) NSString *newsRelatedSoftWareStr;
@end
