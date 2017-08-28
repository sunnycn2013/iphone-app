//
//  BubbleChatViewController.m
//  iosapp
//
//  Created by ChanAetern on 2/15/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "BubbleChatViewController.h"
#import "Config.h"
#import "Utils.h"
#import "OSCAPI.h"
#import "OSCListItem.h"
#import "OSCPrivateChatController.h"
#import "JDStatusBarNotification.h"

#import "NSObject+Comment.h"

#import <MBProgressHUD.h>

@interface BubbleChatViewController () <UIWebViewDelegate>

@property (nonatomic, strong) OSCAuthor* author;

@property (nonatomic, strong) OSCPrivateChatController *messageBubbleVC;

@end

@implementation BubbleChatViewController

- (instancetype)initWithUser:(OSCAuthor* )author{
    self = [super initWithPhotoButton:YES];
    if (self) {
        self.navigationItem.title = author.name;
        
        _author = author;
        _messageBubbleVC = [[OSCPrivateChatController alloc] initWithAuthorId:_author.id];
        [self addChildViewController:_messageBubbleVC];
        
        [self setUpBlock];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setUpBlock
{
    __weak BubbleChatViewController *weakSelf = self;
    
    _messageBubbleVC.didScroll = ^ {
        [weakSelf.editingBar.editView resignFirstResponder];
        [weakSelf hideEmojiPageView];
    };
}


- (void)setLayout
{
    [self.view addSubview:_messageBubbleVC.view];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = @{@"messageBubbleTableView": _messageBubbleVC.view, @"editingBar": self.editingBar};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[messageBubbleTableView]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[messageBubbleTableView][editingBar]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil views:views]];
}


- (void)sendContent
{
    [NSObject updateToRecentlyContacterList:_author];
    
    JDStatusBarView *status = [JDStatusBarNotification showWithStatus:@"私信发送中.."];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_HTTPS_PREFIX, OSCAPI_MESSAGES_PUB];
    
    [manager POST:strUrl
       parameters:@{
                    @"authorId": @(_author.id),
                    @"content": [Utils convertRichTextToRawText:self.editingBar.editView]
                    }
    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    if (self.image) {
                        [formData appendPartWithFileData:[Utils compressImage:self.image]
                                                    name:@"file"
                                                fileName:@"img.jpg"
                                                mimeType:@"image/jpeg"];
                    }
                }
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              NSInteger errorCode = [responseObject[@"code"] integerValue];
              
              if (errorCode == 1) {
                  self.editingBar.editView.text = @"";
                  [self updateInputBarHeight];
                  status.textLabel.text = @"发送私信成功";
              } else {
                  status.textLabel.text = [NSString stringWithFormat:@"错误：%@", responseObject[@"message"]];
              }
              self.image = nil;
              [JDStatusBarNotification dismissAfter:2];
              
              //CGPointMake(0, CGFLOAT_MAX)最底部
              dispatch_async(dispatch_get_main_queue(), ^{
                  [_messageBubbleVC refresh];
              });
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              self.image = nil;
              
              status.textLabel.text = @"网络异常，私信发送失败";
              [JDStatusBarNotification dismissAfter:2];
          }];
    
}




@end
