//
//  OSCGitDetailModel.h
//  iosapp
//
//  Created by 王恒 on 17/3/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSCGitListModel.h"

@interface OSCGitDetailModel : NSObject

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

@property (nonatomic,strong) NSString *readme;

@end
