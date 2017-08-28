//
//  EmojiPageVC.m
//  iosapp
//
//  Created by chenhaoxiang on 11/27/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EmojiPageVC.h"
#import "EmojiPanelVC.h"
#import "PlaceholderTextView.h"
#import "Utils.h"
#import "OSCPopInputView.h"

#import "NSObject+KitHock.h"

#import <YYKit.h>
#import <objc/runtime.h>

@interface EmojiPageVC () <UIPageViewControllerDataSource>

@property (nonatomic, copy) void (^didSelectEmoji) (NSTextAttachment *);
@property (nonatomic, copy) void (^deleteEmoji)();

@end


@implementation EmojiPageVC

- (instancetype)initWithTextView:(__kindof UIView *)view
{
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                  options:nil];
    if (self) {
        if ([view isKindOfClass:[PlaceholderTextView class]]) {
            UITextView *textView = view;
            _didSelectEmoji = ^(NSTextAttachment *textAttachment) {
                NSAttributedString *emojiAttributedString = [NSAttributedString attributedStringWithAttachment:textAttachment];
                NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
                NSRange range = NSMakeRange(textView.selectedRange.location + 1, textView.selectedRange.length);
                [mutableAttributeString replaceCharactersInRange:textView.selectedRange withAttributedString:emojiAttributedString];
                textView.attributedText = mutableAttributeString;
                textView.selectedRange = range;
                textView.textColor = [UIColor titleColor];
                [textView insertText:@""];
                textView.font = [UIFont systemFontOfSize:16];
            };
            _deleteEmoji = ^ {
                [textView deleteBackward];
            };
        }else if ([view isKindOfClass:[YYTextView class]]){
            YYTextView *textView = view;
            _didSelectEmoji = ^(NSTextAttachment *textAttachment) {
                NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
                
                YYTextAttachment* textAttachment_YY = [YYTextAttachment new];
                textAttachment_YY.content = textAttachment.image;
                textAttachment_YY.userInfo = @{@"emoji" : objc_getAssociatedObject(textAttachment, @"emoji") };
                
                NSAttributedString *attachText = [NSAttributedString attachmentStringWithTextAttachment:textAttachment_YY imageSize:textAttachment.image.size];
                
                NSRange range = NSMakeRange(textView.selectedRange.location + 1, textView.selectedRange.length);
                [mutableAttributeString replaceCharactersInRange:textView.selectedRange withAttributedString:attachText];
                textView.attributedText = mutableAttributeString.copy;
                textView.selectedRange = range;
                textView.textColor = [UIColor titleColor];
                [textView insertText:@""];
                textView.font = [UIFont systemFontOfSize:16];
                textView.typingAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                                   NSFontAttributeName : [UIFont systemFontOfSize:16]};
            };
            _deleteEmoji = ^ {
                [textView deleteBackward];
            };
        }else{
            OSCPopInputView *inputView = view;
            _didSelectEmoji = ^(NSTextAttachment *textAttachment) {
                [inputView insertAtrributeString:textAttachment];
            };
            _deleteEmoji = ^ {
                [inputView deleteClick];
            };
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];//[UIColor themeColor]
    
    EmojiPanelVC *emojiPanelVC = [[EmojiPanelVC alloc] initWithPageIndex:0];
    emojiPanelVC.didSelectEmoji = _didSelectEmoji;
    emojiPanelVC.deleteEmoji    = _deleteEmoji;
    if (emojiPanelVC != nil) {
        self.dataSource = self;
        [self setViewControllers:@[emojiPanelVC]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:NO
                      completion:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(EmojiPanelVC *)vc
{
    int index = vc.pageIndex;
    
    if (index == 0) {
        return nil;
    } else {
        EmojiPanelVC *emojiPanelVC = [[EmojiPanelVC alloc] initWithPageIndex:index-1];
        emojiPanelVC.didSelectEmoji = _didSelectEmoji;
        emojiPanelVC.deleteEmoji    = _deleteEmoji;
        return emojiPanelVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(EmojiPanelVC *)vc
{
    int index = vc.pageIndex;
    
    if (index == 6) {
        return nil;
    } else {
        EmojiPanelVC *emojiPanelVC = [[EmojiPanelVC alloc] initWithPageIndex:index+1];
        emojiPanelVC.didSelectEmoji = _didSelectEmoji;
        emojiPanelVC.deleteEmoji    = _deleteEmoji;
        return emojiPanelVC;
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 7;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}





@end
