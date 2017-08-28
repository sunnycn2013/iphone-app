//
//  OSCGitListModel.h
//  iosapp
//
//  Created by 王恒 on 17/3/2.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class GitOwner,GitNameSpace;
@interface OSCGitListModel : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) NSString *git_description;

@property (nonatomic,strong) NSString *default_branch;

@property (nonatomic,strong) GitOwner *owner;

@property (nonatomic,assign) BOOL *git_public;

@property (nonatomic,strong) NSString *path;

@property (nonatomic,strong) NSString *path_with_namespace;

@property (nonatomic,assign) BOOL issues_enabled;

@property (nonatomic,assign) BOOL pull_requests_enabled;

@property (nonatomic,assign) BOOL wiki_enabled;

@property (nonatomic,strong) NSString *created_at;

@property (nonatomic,strong) GitNameSpace *git_namespace;

@property (nonatomic,strong) NSString *last_push_at;

@property (nonatomic,assign) NSInteger parent_id;

@property (nonatomic,assign) NSInteger forks_count;

@property (nonatomic,assign) NSInteger stars_count;

@property (nonatomic,assign) NSInteger watches_count;

@property (nonatomic,strong) NSString *language;

@property (nonatomic,assign) BOOL stared;

@property (nonatomic,assign) BOOL watched;

@property (nonatomic,assign) BOOL relation;

@property (nonatomic,assign) NSInteger recomm;

@property (nonatomic,strong) NSString *real_path;

@property (nonatomic,strong) NSString *svn_url_to_repo;

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




@interface GitOwner : NSObject

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString *username;

@property (nonatomic,strong) NSString *email;

@property (nonatomic,strong) NSString *name;

@property (nonatomic,strong) NSString *state;

@property (nonatomic,strong) NSString *created_at;

@property (nonatomic,strong) NSString *portrait;

@property (nonatomic,strong) NSString *portrait_new;

@end




@interface GitNameSpace : NSObject

@property (nonatomic,strong) NSString *created_at;

@property (nonatomic,strong) NSString *git_description;

@property (nonatomic,assign) NSInteger id;

@property (nonatomic,strong) NSString *name;

@property (nonatomic,assign) NSInteger owner_id;

@property (nonatomic,strong) NSString *path;

@property (nonatomic,strong) NSString *updated_at;

@end

