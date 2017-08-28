//
//  OSCCodeSnippetListModel.h
//  iosapp
//
//  Created by wupei on 2017/5/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CodeOwner;
@interface OSCCodeSnippetListModel : NSObject

@property (nonatomic,strong) NSString *id_str;//内容ID字符串

@property (nonatomic,strong) NSString *url;

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) NSString *language;

@property (nonatomic,strong) NSString *code_description;

@property (nonatomic,strong) CodeOwner *owner;

@property (nonatomic,strong) NSString *content;//内容

@property (nonatomic,assign) NSInteger comments_count;

@property (nonatomic,assign) NSInteger stars_count;

@property (nonatomic,assign) NSInteger forks_count;

@property (nonatomic,strong) NSString *created_at;

@property (nonatomic,strong) NSString *updated_at;

/**外部使用拼接attribute*/
@property (nonatomic,strong) NSMutableAttributedString *titleAttribute;

@property (nonatomic,strong) NSMutableAttributedString *infoAttribute;

/**以下是异步绘制布局计算信息*/
@property (nonatomic,assign) CGRect portraitFrame;

@property (nonatomic,assign) CGRect titleFrame;

@property (nonatomic,assign) CGRect descriptionFrame;

@property (nonatomic,assign) CGRect infoFrame;

@property (nonatomic,assign) CGRect langueFrame;

@property (nonatomic,assign) float cellHeight;

/**异步绘制计算*/
- (void)calculateLayoutWithCurTweetCellWidth:(CGFloat)curWidth;

@end


@interface CodeOwner : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString *portrait_new;

@property (nonatomic,strong) NSString *username;

@property (nonatomic,strong) NSString *name;//昵称

@end





