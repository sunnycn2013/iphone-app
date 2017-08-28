//
//  OSCPopInputView.m
//  iosapp
//
//  Created by Graphic-one on 16/11/14.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCPopInputView.h"
#import "Utils.h"
#import "UIButtonColorHF.h"

#import "NSObject+KitHock.h"

#import <YYKit.h>

#define defaultMaxStringLenght 160

/** autoLayout */
#define atButton_and_emoji_width 32

#define atButton_left_padding_default 19
#define emjioButton_left_padding_default 57
#define forwardingButton_left_padding_default 99

@interface OSCPopInputView () <YYTextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bg_View;
@property (weak, nonatomic) CAGradientLayer* gradientLayer;

@property (weak, nonatomic) IBOutlet YYTextView *inputTextView;
@property (weak, nonatomic) IBOutlet UIButton *atButton;
@property (weak, nonatomic) IBOutlet UIButton *emojiButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardingButton;
@property (weak, nonatomic) IBOutlet UILabel *tipTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

/** autoLayout */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *atButton_left_padding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emjioButton_left_padding;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *forwardingButton_left_padding;

@end

@implementation OSCPopInputView

@synthesize autoSaveDraftNote = _isAutoSaveDraftNote;

- (void)awakeFromNib{
    [super awakeFromNib];
    
    /** layout setting*/
    _inputTextView.tintColor = [UIColor colorWithHex:0x01A83A];
    _inputTextView.text = nil;
    _inputTextView.delegate  = self;
    _inputTextView.returnKeyType = UIReturnKeyNext;
    _inputTextView.typingAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                                   NSFontAttributeName : [UIFont systemFontOfSize:14]};
    
    _forwardingButton.hidden = YES;//暂时性隐藏
    
    _tipTextLabel.hidden = YES;
    _sendButton.enabled = NO;

    /** UI display setting*/
    _inputTextView.layer.borderWidth = 1;
    _inputTextView.layer.borderColor = [UIColor colorWithHex:0xc7c7cc].CGColor;
    _sendButton.layer.masksToBounds = YES;
    _sendButton.layer.cornerRadius = 3;
    
    [_sendButton setBackgroundImage:[Utils createImageWithColor:ButtonNormalBackgroundColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:ButtonNormalTextColor forState:UIControlStateDisabled];

    [_sendButton setBackgroundImage:[Utils createImageWithColor:ButtonDissableBackgroundColor] forState:UIControlStateDisabled];
    [_sendButton setTitleColor:ButtonDissableTextColor forState:UIControlStateDisabled];
    
    [_sendButton setBackgroundImage:[Utils createImageWithColor:ButtonPressedBackgroundColor] forState:UIControlStateHighlighted];
    [_sendButton setTitleColor:ButtonPressedTextColor forState:UIControlStateHighlighted];
}

+ (instancetype)popInputViewWithFrame:(CGRect)frame
                      maxStringLenght:(NSInteger)maxStringLenght
                             delegate:(id<OSCPopInputViewDelegate>)delegate
                    autoSaveDraftNote:(BOOL)isAutoSaveDraftNote
{
    OSCPopInputView* popInputView = [[[NSBundle mainBundle] loadNibNamed:@"OSCPopInputView" owner:nil options:nil] lastObject];
    popInputView.frame = frame;
    popInputView.maxStringLenght = maxStringLenght == NSNotFound ? defaultMaxStringLenght : maxStringLenght;
    popInputView.delegate = delegate;
    popInputView.autoSaveDraftNote = isAutoSaveDraftNote;
    return popInputView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isAutoSaveDraftNote = YES;
        _maxStringLenght = defaultMaxStringLenght;
    }
    return self;
}

+ (NSAttributedString* )getDraftNoteById:(NSString* )draftKeyID
{
    if (!draftKeyID || [draftKeyID isEqual:[NSNull null]]) return nil;
    if (!_draftNoteDic || [_draftNoteDic isEqual:[NSNull null]]) return nil;
    
    NSAttributedString* draftNote = _draftNoteDic[draftKeyID];
    if (draftNote && draftNote.length > 0) {
        return draftNote;
    }else{
        return nil;
    }
}


- (void)activateInputView{
//    [self.bg_View.layer addSublayer:self.gradientLayer];
    
    [_inputTextView becomeFirstResponder];
    
    if (_isAutoSaveDraftNote) {
        NSMutableDictionary* draftDic = [self draftNoteDic];
        NSArray* keys = [draftDic allKeys];
        if (_draftKeyID && _draftKeyID.length > 0) {
            if (![keys containsObject:_draftKeyID]) {
                [draftDic setValue:[[NSAttributedString alloc] initWithString:@""] forKey:_draftKeyID];
            }else{
                NSAttributedString* draftStr = [draftDic valueForKey:_draftKeyID];
                _inputTextView.typingAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                                    NSFontAttributeName : [UIFont systemFontOfSize:14]};
                _inputTextView.attributedText = draftStr;
                _inputTextView.selectedRange = NSMakeRange(draftStr.length, 0);
                [self updateInputViewStatus];
            }
        }
    }
    
    if ([_delegate respondsToSelector:@selector(popInputViewDidShow:)]) {
        [_delegate popInputViewDidShow:self];
    }
}
- (void)freezeInputView{
    [self updateDraftNote:_inputTextView.attributedText];
    [_inputTextView resignFirstResponder];

    if ([_delegate respondsToSelector:@selector(popInputViewDidDismiss:draftNoteAttribute:)]) {
        [_delegate popInputViewDidDismiss:self draftNoteAttribute:_inputTextView.attributedText];
    }
    
    [self.gradientLayer removeFromSuperlayer];
}
- (void)clearDraftNote{
    _inputTextView.attributedText = nil;
    _inputTextView.text = @"";
    NSMutableDictionary* draftDic = [self draftNoteDic];
    if (_draftKeyID && _draftKeyID.length > 0) {
        [draftDic removeObjectForKey:_draftKeyID];
    }
}

- (void)dealloc{
    debugMethod();
}

- (void)restoreDraftNoteWithAttribute:(NSAttributedString *)draftNoteAttribute{
    if (!draftNoteAttribute || [draftNoteAttribute isEqual:[NSNull null]] || draftNoteAttribute.length <= 0) return;
    
    _inputTextView.attributedText = draftNoteAttribute;
    _inputTextView.selectedRange = NSMakeRange(draftNoteAttribute.length, 0);
    _inputTextView.typingAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                        NSFontAttributeName : [UIFont systemFontOfSize:14]};
    [self updateInputViewStatus];
    [self updateDraftNote:draftNoteAttribute];
}

- (void)insertAtrributeString2TextView:(NSAttributedString *)attributedString
{
    if (!attributedString || [attributedString isEqual:[NSNull null]]) return ;
    
    NSMutableAttributedString *mAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:_inputTextView.attributedText];
    
    @try {
        [mAttStr replaceCharactersInRange:_inputTextView.selectedRange withAttributedString:attributedString];
        NSRange range = NSMakeRange(_inputTextView.selectedRange.location + attributedString.length, _inputTextView.selectedRange.length);
        _inputTextView.attributedText = mAttStr.copy;
        _inputTextView.selectedRange = range;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
        NSLog(@"replaceCharactersInRange: or setAttributedText: error");
    } @finally {
        //code...
    }
    
    _inputTextView.textColor = [UIColor titleColor];
    [_inputTextView insertText:@""];
    _inputTextView.typingAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                        NSFontAttributeName : [UIFont systemFontOfSize:14]};
}

- (void)insertAtrributeString:(NSTextAttachment *)textAttachment
{
    if (!textAttachment || [textAttachment isEqual:[NSNull null]]) return;
    
    NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:_inputTextView.attributedText];
    
    @try {
        YYTextAttachment* textAttachment_YY = [YYTextAttachment new];
        textAttachment_YY.content = textAttachment.image;
        textAttachment_YY.userInfo = @{@"emoji" : objc_getAssociatedObject(textAttachment, @"emoji") };
        
        NSAttributedString *attachText = [NSAttributedString attachmentStringWithTextAttachment:textAttachment_YY imageSize:textAttachment.image.size];
        
        NSRange range = NSMakeRange(_inputTextView.selectedRange.location + 1, _inputTextView.selectedRange.length);
        [mutableAttributeString replaceCharactersInRange:_inputTextView.selectedRange withAttributedString:attachText];
        _inputTextView.attributedText = mutableAttributeString.copy;
        _inputTextView.selectedRange = range;
    } @catch (NSException *exception) {
        NSLog(@"add textAttachment_YY error ");
    } @finally {
        //code ...
    }

    _inputTextView.textColor = [UIColor titleColor];
    [_inputTextView insertText:@""];
    _inputTextView.typingAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                                   NSFontAttributeName : [UIFont systemFontOfSize:14]};
}

- (void)deleteClick{
    [_inputTextView deleteBackward];
}

- (void)beginEditing{
    [_inputTextView becomeFirstResponder];
}

- (void)endEditing{
    [_inputTextView resignFirstResponder];
}

#pragma mark - set Method
- (void)setPopInputViewType:(OSCPopInputViewType)popInputViewType{
    _popInputViewType = popInputViewType;
    
    if (popInputViewType & OSCPopInputViewType_At) {
        _atButton.hidden = NO;
    }else{
        _atButton.hidden = YES;
    }
    
    if (popInputViewType & OSCPopInputViewType_Emoji) {
        _emojiButton.hidden = NO;
        _emjioButton_left_padding.constant = _atButton.isHidden ? atButton_left_padding_default : emjioButton_left_padding_default;
    }else{
        _emojiButton.hidden = YES;
    }
    
    if (popInputViewType & OSCPopInputViewType_Forwarding) {
        [_forwardingButton setTitle:@"转发到动弹" forState:UIControlStateNormal];
        _forwardingButton.hidden = NO;
        _forwardingButton_left_padding.constant = _atButton.isHidden ? (_emojiButton.isHidden ? atButton_left_padding_default : emjioButton_left_padding_default) : (_emojiButton.isHidden ? emjioButton_left_padding_default : forwardingButton_left_padding_default);
    }
    
    if (popInputViewType & OSCPopInputViewType_Commenting) {
        [_forwardingButton setTitle:@"同时评论" forState:UIControlStateNormal];
        _forwardingButton.hidden = NO;
        _forwardingButton_left_padding.constant = _atButton.isHidden ? (_emojiButton.isHidden ? atButton_left_padding_default : emjioButton_left_padding_default) : (_emojiButton.isHidden ? emjioButton_left_padding_default : forwardingButton_left_padding_default);
    }
    
    if (!(popInputViewType & OSCPopInputViewType_Forwarding) &&
        !(popInputViewType & OSCPopInputViewType_Commenting)) {
        _forwardingButton.hidden = YES;
    }
}

- (void)setAutoSaveDraftNote:(BOOL)autoSaveDraftNote{
    _isAutoSaveDraftNote = autoSaveDraftNote;
}

- (void)setMaxStringLenght:(NSInteger)maxStringLenght{
    _maxStringLenght = maxStringLenght;
}

- (void)setDraftKeyID:(NSString *)draftKeyID{
    if (!draftKeyID || [draftKeyID isEqual:[NSNull null]])  return;
    
    _draftKeyID = draftKeyID;
    
    if (_isAutoSaveDraftNote) {
        NSMutableDictionary* draftDic = [self draftNoteDic];
        NSArray* keys = [draftDic allKeys];
        if (![keys containsObject:draftKeyID]) {
            [draftDic setValue:[NSAttributedString new] forKey:draftKeyID];
        }else{
            NSAttributedString* draftAttStr = [draftDic valueForKey:draftKeyID];
            _inputTextView.attributedText = draftAttStr;
            [self updateInputViewStatus];
        }
    }
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self updateInputViewStatus];
    return YES;
}
- (void)textViewDidChange:(YYTextView *)textView
{
    [self updateInputViewStatus];
}
- (void)textViewDidEndEditing:(YYTextView *)textView
{
    [self updateDraftNote:textView.attributedText];
}

#pragma mark - button method
- (IBAction)didClickAtButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(popInputViewClickDidAtButton:)]) {
        [_delegate popInputViewClickDidAtButton:self];
    }
}
- (IBAction)didClickEmojiButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(popInputViewClickDidEmojiButton:)]) {
        [_delegate popInputViewClickDidEmojiButton:self];
    }
}
- (IBAction)didClickForwardingButton:(UIButton *)sender {
    sender.selected = !sender.selected;
}
- (IBAction)didClickSendButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(popInputViewClickDidSendButton:selectedforwarding:curTextView:)]) {
        [_delegate popInputViewClickDidSendButton:self selectedforwarding:_forwardingButton.selected curTextView:_inputTextView];
    }
}


#pragma mark change subViews status
- (void)updateInputViewStatus
{
    NSInteger totalLength = [Utils convertRichTextToRawYYTextView:_inputTextView].length;
    if (totalLength > _maxStringLenght) {
        _tipTextLabel.text = [NSString stringWithFormat:@"-%ld",(totalLength - (_maxStringLenght))];
        _tipTextLabel.textColor = [UIColor redColor];
        _tipTextLabel.hidden = NO;
        _sendButton.enabled = NO;
    }else{
        _tipTextLabel.text = [NSString stringWithFormat:@"%ld",totalLength];
        _tipTextLabel.textColor = [UIColor grayColor];
        _tipTextLabel.hidden = totalLength > 0 ? NO : YES;
        _sendButton.enabled = totalLength > 0 ? YES : NO;
    }
}

- (void)updateDraftNote:(NSAttributedString* )str
{
    if (!str || [str isEqual:[NSNull null]]) return ;
    
    if (_isAutoSaveDraftNote) {
        if (_draftKeyID && _draftKeyID.length > 0) {
            NSMutableDictionary* draftDic = [self draftNoteDic];
            if (str && str.length > 0) {
                [draftDic setValue:str forKey:_draftKeyID];
            }else{
                [draftDic setValue:[NSAttributedString new] forKey:_draftKeyID];
            }
        }
    }
}

#pragma mark draftNoteDic
static NSMutableDictionary* _draftNoteDic;
- (NSMutableDictionary* )draftNoteDic{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _draftNoteDic = @{}.mutableCopy;
    });
    return _draftNoteDic;
}

#pragma mark - lazy loading
- (CAGradientLayer *)gradientLayer{
    if (!_gradientLayer) {
        CAGradientLayer* gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint   = CGPointMake(0, 1);
        
        gradientLayer.colors = @[
                                 (__bridge id)[[UIColor colorWithHex:0xFFFFFF] colorWithAlphaComponent:0.5].CGColor,
                                 (__bridge id)[[UIColor colorWithHex:0xD1D5DB] colorWithAlphaComponent:0.7].CGColor
                                 ];
        gradientLayer.locations = @[@(0.5f) ,@(1.0f)];
        _gradientLayer = gradientLayer;
    }
    return _gradientLayer;
}
@end









