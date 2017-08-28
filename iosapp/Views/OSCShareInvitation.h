//
//  OSCShareInvitation.h
//  iosapp
//
//  Created by wupei on 2017/4/21
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "enumList.h"
#import "OSCGitDetailModel.h"

@class OSCShareInvitation;
@protocol OSCShareInvitationDelegate <NSObject>

@optional
- (void)shareManagerCustomShareModeWithManager:(OSCShareInvitation* )shareManager
                         shareBoardIndexButton:(NSInteger)buttonTag;

@end

@interface OSCShareInvitation : NSObject

+ (instancetype)shareManager;

- (void)showShareBoardWithShareType:(InformationType)infomationType
                          withModel:(id)model;

- (void)hiddenShareBoard;

- (void)showShareBoardWithGitModel:(OSCGitDetailModel *)model;
- (void)showShareBoardWithGitCodeModel:(OSCGitDetailModel *)model path:(NSString* )path;

- (void)showShareBoardWithImage:(UIImage *)image;

@property (nonatomic, weak) id <OSCShareInvitationDelegate> delegate;

@end




#pragma mark --- OSCShareInvitationBoard

@class OSCShareInvitationBoard;
@protocol OSCShareInvitationBoardDelegate <NSObject>

@optional
- (BOOL)customShareModeWithShareBoard:(OSCShareInvitationBoard* )shareBoard
                     boardIndexButton:(NSInteger)buttonTag;

@end

@interface OSCShareInvitationBoard : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (instancetype)shareBoardWithShareType:(InformationType)infomationType
                              withModel:(id)model;

+ (instancetype)shareBoardWithGitModel:(OSCGitDetailModel *)model path:(NSString* )path;

+ (instancetype)shareBoardWithImage:(UIImage *)image;

@property (nonatomic, weak) id <OSCShareInvitationBoardDelegate> delegate;

@end
