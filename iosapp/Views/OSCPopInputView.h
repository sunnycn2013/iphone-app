//
//  OSCPopInputView.h
//  iosapp
//
//  Created by Graphic-one on 16/11/14.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, OSCPopInputViewType){
    OSCPopInputViewType_At              = 1 << 0,
    OSCPopInputViewType_Emoji           = 1 << 1,
    OSCPopInputViewType_Forwarding      = 1 << 2,
    OSCPopInputViewType_Commenting      = 1 << 3,
};

@class OSCPopInputView,YYTextView;

@protocol OSCPopInputViewDelegate <NSObject>

@optional
- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView;

- (void)popInputViewClickDidEmojiButton:(OSCPopInputView* )popInputView;

- (void)popInputViewClickDidSendButton:(OSCPopInputView* )popInputView
                    selectedforwarding:(BOOL)isSelectedForwarding
                           curTextView:(YYTextView* )textView;

- (void)popInputViewDidShow:(OSCPopInputView* )popInputView;

- (void)popInputViewDidDismiss:(OSCPopInputView *)popInputView
            draftNoteAttribute:(NSAttributedString *)draftNoteAttribute;

@end

@interface OSCPopInputView : UIView

+ (instancetype)popInputViewWithFrame:(CGRect)frame
                      maxStringLenght:(NSInteger)maxStringLenght
                             delegate:(id<OSCPopInputViewDelegate>)delegate
                    autoSaveDraftNote:(BOOL)isAutoSaveDraftNote;

@property (nonatomic,assign) OSCPopInputViewType popInputViewType;

@property (nonatomic,assign,getter=isAutoSaveDraftNote) BOOL autoSaveDraftNote;///default is YES

@property (nonatomic,assign) NSInteger maxStringLenght;///default is 160

@property (nonatomic,weak) id<OSCPopInputViewDelegate> delegate;

@property (nonatomic,strong) NSString* draftKeyID;///传入咨询或者博客的id 作为草稿存储的key

+ (NSAttributedString* )getDraftNoteById:(NSString* )draftKeyID;///<根据草稿ID读取草稿内容

- (void)activateInputView;

- (void)freezeInputView;

- (void)clearDraftNote;

- (void)restoreDraftNoteWithAttribute:(NSAttributedString *)draftNoteAttribute;

- (void)insertAtrributeString2TextView:(NSAttributedString *)attributedString;

- (void)insertAtrributeString:(NSTextAttachment *)textAttachment;

- (void)deleteClick;

- (void)beginEditing;
- (void)endEditing;

@end

NS_ASSUME_NONNULL_END
