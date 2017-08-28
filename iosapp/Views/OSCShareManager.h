//
//  OSCShareManager.h
//  iosapp
//
//  Created by 李萍 on 2016/11/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "enumList.h"
#import "OSCGitDetailModel.h"
#import "OSCCodeSnippetListModel.h"

@class OSCShareManager;
@protocol OSCShareManagerDelegate <NSObject>

@optional
- (void)shareManagerCustomShareModeWithManager:(OSCShareManager* )shareManager
                         shareBoardIndexButton:(NSInteger)buttonTag;

@end

@interface OSCShareManager : NSObject

+ (instancetype)shareManager;

- (void)showShareBoardWithShareType:(InformationType)infomationType
                          withModel:(id)model;

- (void)hiddenShareBoard;

- (void)showShareBoardWithGitModel:(OSCGitDetailModel *)model;
- (void)showShareBoardWithGitCodeModel:(OSCGitDetailModel *)model path:(NSString* )path;

/** 码云代码片段分享 */
- (void)showShareBoardWithCodeModel:(OSCCodeSnippetListModel *)model;

- (void)showShareBoardWithImage:(UIImage *)image;

@property (nonatomic, weak) id <OSCShareManagerDelegate> delegate;

@end




#pragma mark --- OSCShareBoard

@class OSCShareBoard;
@protocol OSCShareBoardDelegate <NSObject>

@optional
- (BOOL)customShareModeWithShareBoard:(OSCShareBoard* )shareBoard
                     boardIndexButton:(NSInteger)buttonTag;

@end

@interface OSCShareBoard : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (instancetype)shareBoardWithShareType:(InformationType)infomationType
                              withModel:(id)model;

+ (instancetype)shareBoardWithGitModel:(OSCGitDetailModel *)model path:(NSString* )path;

+ (instancetype)shareBoardWithCodeModel:(OSCCodeSnippetListModel *)model path:(NSString* )path;

+ (instancetype)shareBoardWithImage:(UIImage *)image;

@property (nonatomic, weak) id <OSCShareBoardDelegate> delegate;

@end
