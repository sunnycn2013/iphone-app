//
//  OSCShareInvitation.m
//  iosapp
//
//  Created by wupei on 2017/4/21
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCShareInvitation.h"
#import "Utils.h"
#import "Config.h"

#import "OSCListItem.h"
#import "OSCTweetItem.h"
#import "OSCAbout.h"
#import "TweetEditingVC.h"
#import "JDStatusBarView.h"
#import "NewLoginViewController.h"
#import "OSCPhotoAlbumManger.h"
#import "ImageViewerController.h"

#import "UMSocial.h"
#import <MBProgressHUD.h>


#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SHAREBOARD_HEIGHT curShareBoard.bounds.size.height
#define SHAREBOARD_WIDTH curShareBoard.bounds.size.width

@interface OSCShareInvitation ()<OSCShareInvitationBoardDelegate>
{
	__weak OSCShareInvitationBoard* _curShareBoard;
}

@end

@implementation OSCShareInvitation

static OSCShareInvitation* _shareManager ;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [OSCShareInvitation new];
    });
    return _shareManager;
}

- (void)showShareBoardWithShareType:(InformationType)infomationType
						  withModel:(id)model
{
	if (_curShareBoard) { _curShareBoard = nil;}
	
	OSCShareInvitationBoard *curShareBoard = [OSCShareInvitationBoard shareBoardWithShareType:infomationType withModel:model];
	_curShareBoard = curShareBoard;
	curShareBoard.frame = [UIScreen mainScreen].bounds;
	curShareBoard = curShareBoard;
	curShareBoard.delegate = self;
	
	[[UIApplication sharedApplication].keyWindow addSubview:curShareBoard];
	
	//背景蒙层的动画：alpha值从0.0变化到0.5
	[curShareBoard.bgView setAlpha:0.0];
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		[curShareBoard.bgView setAlpha:0.5];
	} completion:^(BOOL finished) { }];
	
	//分享面板的动画：从底部向上滚动弹出来
	[curShareBoard.contentView setFrame:CGRectMake(0, SCREEN_HEIGHT , SHAREBOARD_WIDTH, SHAREBOARD_HEIGHT )];
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		[curShareBoard.contentView setFrame:CGRectMake(0,SCREEN_HEIGHT - SHAREBOARD_HEIGHT,SHAREBOARD_WIDTH,SHAREBOARD_HEIGHT)];
	} completion:^(BOOL finished) {}];
}

- (void)showShareBoardWithGitModel:(OSCGitDetailModel *)model{
    if (_curShareBoard) { _curShareBoard = nil;}
    
    OSCShareInvitationBoard *curShareBoard = [OSCShareInvitationBoard shareBoardWithGitModel:model path:nil];
    _curShareBoard = curShareBoard;
    curShareBoard.frame = [UIScreen mainScreen].bounds;
    curShareBoard = curShareBoard;
    curShareBoard.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:curShareBoard];
    
    //背景蒙层的动画：alpha值从0.0变化到0.5
    [curShareBoard.bgView setAlpha:0.0];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.bgView setAlpha:0.5];
    } completion:^(BOOL finished) { }];
    
    //分享面板的动画：从底部向上滚动弹出来
    [curShareBoard.contentView setFrame:CGRectMake(0, SCREEN_HEIGHT , SHAREBOARD_WIDTH, SHAREBOARD_HEIGHT )];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.contentView setFrame:CGRectMake(0,SCREEN_HEIGHT - SHAREBOARD_HEIGHT,SHAREBOARD_WIDTH,SHAREBOARD_HEIGHT)];
    } completion:^(BOOL finished) {}];
}
- (void)showShareBoardWithGitCodeModel:(OSCGitDetailModel *)model path:(NSString* )path{
    if (_curShareBoard) { _curShareBoard = nil;}
    
    OSCShareInvitationBoard *curShareBoard = [OSCShareInvitationBoard shareBoardWithGitModel:model path:path];
    _curShareBoard = curShareBoard;
    curShareBoard.frame = [UIScreen mainScreen].bounds;
    curShareBoard = curShareBoard;
    curShareBoard.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:curShareBoard];
    
    //背景蒙层的动画：alpha值从0.0变化到0.5
    [curShareBoard.bgView setAlpha:0.0];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.bgView setAlpha:0.5];
    } completion:^(BOOL finished) { }];
    
    //分享面板的动画：从底部向上滚动弹出来
    [curShareBoard.contentView setFrame:CGRectMake(0, SCREEN_HEIGHT , SHAREBOARD_WIDTH, SHAREBOARD_HEIGHT )];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.contentView setFrame:CGRectMake(0,SCREEN_HEIGHT - SHAREBOARD_HEIGHT,SHAREBOARD_WIDTH,SHAREBOARD_HEIGHT)];
    } completion:^(BOOL finished) {}];
}

- (void)showShareBoardWithImage:(UIImage *)image{
    if (_curShareBoard) { _curShareBoard = nil;}
    
    OSCShareInvitationBoard *curShareBoard = [OSCShareInvitationBoard shareBoardWithImage:image];
    _curShareBoard = curShareBoard;
    curShareBoard.frame = [UIScreen mainScreen].bounds;
    curShareBoard = curShareBoard;
    curShareBoard.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:curShareBoard];
    
    //背景蒙层的动画：alpha值从0.0变化到0.5
    [curShareBoard.bgView setAlpha:0.0];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.bgView setAlpha:0.5];
    } completion:^(BOOL finished) { }];
    
    //分享面板的动画：从底部向上滚动弹出来
    [curShareBoard.contentView setFrame:CGRectMake(0, SCREEN_HEIGHT , SHAREBOARD_WIDTH, SHAREBOARD_HEIGHT )];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.contentView setFrame:CGRectMake(0,SCREEN_HEIGHT - SHAREBOARD_HEIGHT,SHAREBOARD_WIDTH,SHAREBOARD_HEIGHT)];
    } completion:^(BOOL finished) {}];
}

- (void)hiddenShareBoard
{
    if (_curShareBoard.superview) {
        [_curShareBoard removeFromSuperview];
    }
}

#pragma mark --- OSCShareInvitationBoardDelegate
- (BOOL)customShareModeWithShareBoard:(OSCShareInvitationBoard* )shareBoard
                     boardIndexButton:(NSInteger)buttonTag
{
    if ([_delegate respondsToSelector:@selector(shareManagerCustomShareModeWithManager:shareBoardIndexButton:)]) {
        [_delegate shareManagerCustomShareModeWithManager:self shareBoardIndexButton:buttonTag];
        return YES;
    }
    return NO;
}

@end



#pragma mark --- OSCShareInvitationBoard
@interface OSCShareInvitationBoard ()

@property (nonatomic, assign) NSInteger aboutId;
@property (nonatomic, assign) InformationType aboutType;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString* authordName;
@property (nonatomic, copy) NSString *digest;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *descString;

@property (nonatomic, strong) UIImage *logoImage;
@property (nonatomic, strong) NSString* resourceUrl;

@property (nonatomic, assign) BOOL isGitShare;

@property (nonatomic, assign) BOOL isImage;

@end

@implementation OSCShareInvitationBoard{
    BOOL _touchTrack;
}

+ (instancetype)shareBoardWithShareType:(InformationType)infomationType
							  withModel:(id)model
{
    OSCShareInvitationBoard *curShareBoard = [[[UINib nibWithNibName:@"OSCShareInvitationBoard" bundle:nil] instantiateWithOwner:nil options:nil] lastObject];
    curShareBoard.isGitShare = NO;
    curShareBoard.isImage = NO;
    [curShareBoard settingShareType:infomationType model:model];
    return curShareBoard;
}

- (void)settingShareType:(InformationType)infomationType
				   model:(id)model
{
    self.logoImage = [UIImage imageNamed:@"logo"];
    
    switch (infomationType) {
        case InformationTypeTweet://动弹（评论）类型
        {
            OSCTweetItem *tweetItem = (OSCTweetItem *)model;
            NSString *trimmedHTML = [tweetItem.content deleteHTMLTag];
            NSInteger length = trimmedHTML.length < 10 ? trimmedHTML.length : 10;
			
			self.title = [NSString stringWithFormat:@"%@ - 开源中国社区",[trimmedHTML substringToIndex:length]]; ;
            self.digest = [trimmedHTML substringToIndex:length];
            self.href = tweetItem.href;
            self.aboutId = tweetItem.id;
            self.aboutType = InformationTypeTweet;
            self.descString = [self stringReplayOcc:trimmedHTML];
            self.authordName = tweetItem.author.name;
			
			if (tweetItem.images != nil) {
                self.resourceUrl = tweetItem.images[0].thumb;
			}
			
            break;
        }
        case InformationTypeForum://讨论区帖子（问答）
        {
            OSCListItem *questionItem = (OSCListItem *)model;
            NSString *trimmedHTML = [questionItem.body deleteHTMLTag];
            NSInteger length = trimmedHTML.length < 100 ? trimmedHTML.length : 100;
            
            self.title = questionItem.title;
            self.digest = [trimmedHTML substringToIndex:length];
            self.href = questionItem.href;
            self.aboutId = questionItem.id;
            self.aboutType = questionItem.type;//InformationTypeForum;
            self.descString = [self stringReplayOcc:trimmedHTML];
			
			NSString *extractedImagePath = [self extractImagesUrlFromContent:questionItem.body];
			if (extractedImagePath != nil) {
                self.resourceUrl = extractedImagePath;
			}
			
            break;
        }
        case InformationTypeBlog://博客
        {
            OSCListItem *blogItem = (OSCListItem *)model;
            NSString *trimmedHTML = [blogItem.body deleteHTMLTag];
            NSInteger length = trimmedHTML.length < 100 ? trimmedHTML.length : 100;
            
            self.title = blogItem.title;
            self.digest = [trimmedHTML substringToIndex:length];
            self.href = blogItem.href;
            self.aboutId = blogItem.id;
            self.aboutType = blogItem.type;//InformationTypeBlog;
            self.descString = [self stringReplayOcc:trimmedHTML];
			
			NSString *extractedImagePath = [self extractImagesUrlFromContent:blogItem.body];
			if (extractedImagePath != nil) {
                self.resourceUrl = extractedImagePath;
			}
            
            break;
        }
        case InformationTypeTranslation://翻译文章
        {
            OSCListItem *translationItem = (OSCListItem *)model;
            NSString *trimmedHTML = [translationItem.body deleteHTMLTag];
            NSInteger length = trimmedHTML.length < 100 ? trimmedHTML.length : 100;
            
            self.title = translationItem.title;
            self.digest = [trimmedHTML substringToIndex:length];
            self.href = translationItem.href;
            self.aboutId = translationItem.id;
            self.aboutType = translationItem.type;//InformationTypeTranslation;
            self.descString = [self stringReplayOcc:trimmedHTML];
			
			NSString *extractedImagePath = [self extractImagesUrlFromContent:translationItem.body];
			if (extractedImagePath != nil) {
				self.resourceUrl = extractedImagePath;
			}
            
            break;
        }
        case InformationTypeActivity://活动类型
        {
            OSCListItem *activityItem = (OSCListItem *)model;
            NSString *trimmedHTML = [activityItem.body deleteHTMLTag];
            NSInteger length = trimmedHTML.length < 100 ? trimmedHTML.length : 100;
            
            self.title = activityItem.title;
            self.digest = [trimmedHTML substringToIndex:length];
            self.href = activityItem.href;
            self.aboutId = activityItem.id;
            self.aboutType = activityItem.type;//InformationTypeActivity;
            self.descString = [self stringReplayOcc:trimmedHTML];
			
			
			NSString *imagePath = nil;
			if (activityItem.images != nil) {
				imagePath = activityItem.images[0].thumb;
			} else {
				NSString *extractedImagePath = [self extractImagesUrlFromContent:activityItem.body];
				if (extractedImagePath!= nil) {
					imagePath = extractedImagePath;
				}
			}
			
			if (imagePath != nil) {
				self.resourceUrl = imagePath;
			}
			
            break;
        }
        case InformationTypeInfo://资讯
        {
            OSCListItem *infomationItem = (OSCListItem *)model;
            NSString *trimmedHTML = [infomationItem.body deleteHTMLTag];
            NSInteger length = trimmedHTML.length < 100 ? trimmedHTML.length : 100;
            
            self.title = infomationItem.title;
            self.digest = [trimmedHTML substringToIndex:length];
            self.href = infomationItem.href;
            self.aboutId = infomationItem.id;
            self.aboutType = infomationItem.type;//InformationTypeInfo;
            self.descString = [self stringReplayOcc:trimmedHTML];
			
			NSString *extractedImagePath = [self extractImagesUrlFromContent:infomationItem.body];
			if (extractedImagePath != nil) {
				self.resourceUrl = extractedImagePath;
			}
            
            break;
        }
		case InformationTypeSoftWare: //软件
		{
			OSCListItem *softwareItem = (OSCListItem *) model;
			NSString *trimmedHTML = [softwareItem.body deleteHTMLTag];
			NSInteger length = trimmedHTML.length < 100 ? trimmedHTML.length : 100;
			
			self.title = [NSString stringWithFormat:@"%@%@",softwareItem.extra.softwareTitle,softwareItem.extra.softwareName];
			self.digest = [trimmedHTML substringFromIndex:length];
			self.href = softwareItem.href;
			self.aboutId = softwareItem.id;
			self.aboutType = InformationTypeSoftWare;
			self.descString = [self stringReplayOcc:trimmedHTML];
            
            OSCNetImage *image = softwareItem.images[0];
            if (image && ![image.href containsString:@"logo/default.png"]) {
                self.resourceUrl = image.href;
            }
		}
        default:
            break;
    }
}

+ (instancetype)shareBoardWithGitModel:(OSCGitDetailModel *)model path:(NSString* )path{
    OSCShareInvitationBoard *curShareBoard = [[[UINib nibWithNibName:@"OSCShareInvitationBoard" bundle:nil] instantiateWithOwner:nil options:nil] lastObject];
    curShareBoard.isGitShare = YES;
    curShareBoard.isImage = NO;
    [curShareBoard settingGitModel:model path:path];
    return curShareBoard;
}

- (void)settingGitModel:(OSCGitDetailModel *)model path:(NSString* )path{
    self.logoImage = [UIImage imageNamed:@"ios_120"];
    OSCGitDetailModel *questionItem = (OSCGitDetailModel *)model;
    NSString *trimmedHTML = [questionItem.readme deleteHTMLTag];
    NSInteger length = trimmedHTML.length < 100 ? trimmedHTML.length : 100;
    
    self.title = [NSString stringWithFormat:@"%@/%@",questionItem.owner.name,questionItem.name];
    self.digest = [trimmedHTML substringToIndex:length];
    self.href = path ?: [NSString stringWithFormat:@"https://git.oschina.net/%@",questionItem.path_with_namespace];
    self.aboutId = questionItem.id;
    self.descString = [self stringReplayOcc:trimmedHTML];
}

+ (instancetype)shareBoardWithImage:(UIImage *)image{
    OSCShareInvitationBoard *curShareBoard = [[[UINib nibWithNibName:@"OSCShareInvitationBoard" bundle:nil] instantiateWithOwner:nil options:nil] lastObject];
    curShareBoard.isGitShare = NO;
    curShareBoard.isImage = YES;
    [curShareBoard settingImage:image];
    return curShareBoard;
}

- (void)settingImage:(UIImage *)image{
    self.logoImage = image;
    self.href = nil;
    self.descString = @"开源中国活动邀请";
    self.title = @"开源中国活动邀请";
}

- (NSString *)stringReplayOcc:(NSString *)trimmedHTML
{
    NSString *string = [trimmedHTML stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    string = [string substringToIndex:(string.length < 100 ? string.length : 100)];
    string = [NSString stringWithFormat:@"%@", string];
    return string;
}

- (IBAction)cancleAction:(id)sender {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (IBAction)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    UIViewController* curViewController = [self topViewControllerForViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
	
    UMSocialUrlResource* resource = nil;
    if (self.resourceUrl && self.resourceUrl.length > 0) {
        resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:self.resourceUrl];
    }
    
    switch (button.tag) {
        case 1: //weibo
        {
            if (_isImage) {
                [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:self.href];
            }else{
               [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:self.href];
            }
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSina]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
                                                                }
                                                            }];
            
            break;
        }
        case 2: //Wechat Timeline
        {
            
            if (_isImage) {
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
            }else{
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
            }
            
            [UMSocialData defaultData].extConfig.wechatSessionData.url = self.href;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.href;
            [UMSocialData defaultData].extConfig.title = self.title;
            
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatTimeline]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                NSLog(@"%u",response.responseCode);
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
                                                                }
                                                            }];
            break;
        }
        case 3: //WechatSession
        {
            if (_isImage) {
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
            }else{
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
            }
            [UMSocialData defaultData].extConfig.wechatSessionData.url = self.href;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = self.title;
            
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatSession]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
																}
                                                            }];
            
            break;
        }
        case 4: //qq
        {
            if (_isImage) {
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
            }else{
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
            }
            [UMSocialData defaultData].extConfig.qqData.title = self.title;
            [UMSocialData defaultData].extConfig.qqData.url = self.href;
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToQQ]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
                                                                }
                                                            }];
            
            break;
        }
        case 5: //brower
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.href]];
            
            break;
        }
        case 6: //copy url
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString stringWithFormat:@"%@", self.href];
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"已复制到剪切板";
            if (self.superview) {
                [self removeFromSuperview];
            }
            [HUD hideAnimated:YES afterDelay:1];
            
            break;
        }
        case 7:  //more
        {
//            if (self.superview) {
//                [self removeFromSuperview];
//            }
//            
//            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"%@ %@",self.title,self.href]] applicationActivities:nil];
//            if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
//                activityViewController.popoverPresentationController.sourceView = self;
//            }
//
//            [curViewController presentViewController:activityViewController animated:YES completion:nil];
            
            //tag修改了。 保存到相册
            OSCShareInvitation *shareInvitation = [OSCShareInvitation shareManager];
            [shareInvitation hiddenShareBoard];
            
            ImageViewerController *imageVC = [[ImageViewerController alloc] initWithImage:self.logoImage];
            
            [curViewController presentViewController:imageVC animated:YES completion:nil];
            
            break;
        }
        case 8:     //tweet
        {
            if (_isGitShare) {
                MBProgressHUD *hud = [Utils createHUD];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"暂时不支持分享码云到动弹";
                [hud hideAnimated:YES afterDelay:1];
                break;
            }
            
            if (self.superview) {
                [self removeFromSuperview];
            }
            
            BOOL isOuterIMP = NO;
            if ([_delegate respondsToSelector:@selector(customShareModeWithShareBoard:boardIndexButton:)]) {
                isOuterIMP = [_delegate customShareModeWithShareBoard:self boardIndexButton:button.tag];
            }
            
            if (isOuterIMP) break;
            
            if (_isImage) {
                TweetEditingVC *tweetEditingVC = [[TweetEditingVC alloc] initWithImage:self.logoImage];
                UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
                [curViewController presentViewController:tweetEditingNav animated:YES completion:nil];
                break;
            }
            
            OSCAbout* forwardInfo = [OSCAbout forwardInfoModelWithTitle:self.authordName
                                                                          content:self.descString type:self.aboutType fullWidth:[UIScreen mainScreen].bounds.size.width - 32];
            TweetEditingVC *tweetEditingVC = [[TweetEditingVC alloc] initWithAboutID:self.aboutId aboutType:self.aboutType forwardItem:forwardInfo];
            UINavigationController *tweetEditingNav = [[UINavigationController alloc] initWithRootViewController:tweetEditingVC];
            [curViewController presentViewController:tweetEditingNav animated:YES completion:nil];
            
            break;
        }
        default:
            break;
    }
    
    
}

-(NSString *) extractImagesUrlFromContent: (NSString *) content {
	NSRange rangeOfString = NSMakeRange(0, [content length]);
	NSString *pattern = @"<img src=\"([^\"]+)\"";
	NSError *error = nil;
	NSString *imageString = nil;
 
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
	NSArray *matchs = [regex matchesInString:content options:0 range:rangeOfString];
	for (NSTextCheckingResult* match in matchs) {
		imageString = [content substringWithRange:[match rangeAtIndex:1]];
		break;
	}
	return imageString;
}


- (UIViewController *)topViewControllerForViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerForViewController:navigationController.visibleViewController];
    }
    
    if (rootViewController.presentedViewController) {
        return [self topViewControllerForViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}

#pragma mark --- touch handle 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _touchTrack = NO;
    UITouch* t = [touches anyObject];
    CGPoint p1 = [t locationInView:_contentView];
    if (!CGRectContainsPoint(_contentView.bounds, p1)) {
        _touchTrack = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_touchTrack) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_touchTrack) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }else{
        [super touchesCancelled:touches withEvent:event];
    }
}

@end









