//
//  NewCommentListViewController.m
//  iosapp
//
//  Created by 李萍 on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "NewCommentListViewController.h"
#import "NewLoginViewController.h"
#import "OSCUserHomePageController.h"

#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import "OSCCommentItem.h"
#import "OSCModelHandler.h"
#import "OSCShareInvitation.h"
#import "ShareCommentView.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>
#import <Masonry.h>

#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "JDStatusBarNotification.h"
#import "OSCUserHomePageController.h"

#import "OSCCommetCell.h"
#import "ShareView.h"//蒙板
#import "SelectBoardView.h"//分享按钮

@interface NewCommentListViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,OSCPopInputViewDelegate,CommentTextViewDelegate, OSCCommetCellDelegate,SelectBoardViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet CommentTextView *commentTextView;


@property (nonatomic, assign) InformationType commentType;
@property (nonatomic, assign) NSInteger sourceId;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, copy) NSString *nextPageToken;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic, strong) OSCPopInputView *inputView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *tapView;

@property (nonatomic, strong) OSCCommentItem *locationCommentItem;

@property (nonatomic, assign) BOOL isShowEditView;
@property (nonatomic, strong) OSCCommentItem *clickCommentItem;
@property (nonatomic, strong) NSString *titleStr;//文章标题
@property (nonatomic, strong) UIImage *shareImg;//分享的图片
@property (nonatomic, strong) ShareView *shareV;//蒙板

@end

@implementation NewCommentListViewController

- (instancetype)initWithCommentType:(InformationType)commentType sourceID:(NSInteger)sourceId titleStr:(NSString *)titleStr
{
    self = [super init];
    if (self) {
        _titleStr = titleStr;
        _commentType = commentType;
        _sourceId = sourceId;
    }
    
    return self;
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!_isShowEditView) {
        [self showEditView];
        _isShowEditView = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"评论";
    _comments = [NSMutableArray new];
    _nextPageToken = @"";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.commentTextView.commentTextViewDelegate = self;
    [self.commentTextView handleAttributeWithAttribute:[OSCPopInputView getDraftNoteById:[NSString stringWithFormat:@"%ld_%ld",_commentType,(long)_sourceId]]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerClass:[OSCCommetCell class] forCellReuseIdentifier:OSCCommetCellIdentifier];
    self.tableView.tableFooterView = [UIView new];
    [self getCommentData:NO];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getCommentData:YES];
    }];
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self getCommentData:NO];
    }];
    
    
    //软键盘
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _isShowEditView = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)getCommentData:(BOOL)isRefresh
{
    NSString *blogDetailUrlStr = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENTS_LIST];
    AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
    if (isRefresh) {
        _nextPageToken = @"";
    }
    [manger GET:blogDetailUrlStr
     parameters:@{
                  @"sourceId"  : @(self.sourceId),
                  @"type"      : @(self.commentType),
                  @"pageToken" : _nextPageToken,
                  @"order"     : @(1),
                  @"parts"     : @"refer",
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                NSArray *jsonItems = result[@"items"];
                NSArray *array = [NSArray osc_modelArrayWithClass:[OSCCommentItem class] json:jsonItems];
                for (OSCCommentItem *item in array) {
                    [item calculateLayout:YES];
                }
                _nextPageToken = result[@"nextPageToken"];
                
                if (isRefresh) {
                    [_comments removeAllObjects];
                }
                [_comments addObjectsFromArray:array];
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                }else{
                    [self.tableView.mj_footer endRefreshing];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                });
            } else {
                MBProgressHUD *hud = [Utils createHUD];
                hud.mode = MBProgressHUDModeCustomView;
                hud.label.text = responseObject[@"message"];
                
                [hud hideAnimated:YES afterDelay:1];
                
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                }else{
                    [self.tableView.mj_footer endRefreshing];
                }
            }
            
        }
        failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            if (isRefresh) {
                [self.tableView.mj_header endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshing];
            }
            NSLog(@"error = %@",error);
        }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_comments.count > 0) {
        return _comments.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_comments.count > 0) {
        OSCCommetCell *cell = [OSCCommetCell commetCellWithTableView:tableView
                                                          identifier:OSCCommetCellIdentifier
                                                           indexPath:indexPath
                                                         commentItem:_comments[indexPath.row]
                                                 commentUxiliaryNode:
                               ((self.commentType == InformationTypeInfo) ? ( CommentUxiliaryNode_like) : CommentUxiliaryNode_none)
                                                     isNeedReference:YES];
        
        //资讯 没有评论了
//        ((self.commentType == InformationTypeInfo) ? (CommentUxiliaryNode_comment | CommentUxiliaryNode_like) : CommentUxiliaryNode_comment)
        
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_comments.count > 0) {
        OSCCommentItem *item = _comments[indexPath.row];
        return item.layoutHeight;
    } else {
        return 0;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //弹出蒙板
    self.shareV = [[ShareView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, kScreenSize.height)];
    self.shareV.selV.delegate = self;
    self.shareV.selV.item = _comments[indexPath.row];
    [self.shareV showView];
    
    //生成分享图片
    ShareCommentView *shareImgView = [[ShareCommentView alloc] initWithFrame:CGRectMake(0, 50, kScreenSize.width, kScreenSize.height - 50) CommentItem:_comments[indexPath.row] title:self.titleStr];
    [shareImgView layoutIfNeeded];//重新绘制
    UIImage *img = [self convertViewToImage:shareImgView];
    self.shareImg = img;
}



#pragma mark - share image  

-(UIImage *)convertViewToImage:(UIView *)view{
    CGSize size = view.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - OSCCommetCellDelegate
- (void)commetCellDidClickUserPortrait:(OSCCommetCell *)commetCell
{
    if (commetCell.commentItem.author.id > 0) {
        OSCUserHomePageController *userDetailsVC = [[OSCUserHomePageController alloc] initWithUserID:commetCell.commentItem.author.id];
        [self.navigationController pushViewController:userDetailsVC animated:YES];
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"该用户不存在";
        
        [HUD hideAnimated:YES afterDelay:1];
    }
}

- (void)commetCellDidClickLikeButton:(OSCCommetCell* )commetCell
{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    } else {
        if (commetCell.commentItem.voteState != CommentStatusType_Like) {
            
            commetCell.commentItem.vote++;
            commetCell.commentItem.voteState = CommentStatusType_Like;
            
            [commetCell setVoteStatus:commetCell.commentItem animation:YES];
            
            AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
            JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论点赞中..."];
            [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENT_VOTE_REVERSE]
              parameters:@{
                           @"commentId"       : @(commetCell.commentItem.id),
                           @"commentAuthorId" : @(commetCell.commentItem.author.id),
                           @"sourceType"      : @(self.commentType),
                           @"voteOpt"         : @(1),
                           }
                 success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                     if ([responseObject[@"code"] integerValue] == 1) {
                         stauts.textLabel.text = @"点赞成功";
                         [JDStatusBarNotification dismissAfter:2];
                         
                         NSDictionary *result = responseObject[@"result"];
                         NSInteger vote = [result[@"vote"] integerValue];
                         NSInteger voteSate = [result[@"voteState"] integerValue];
                         
                         commetCell.commentItem.vote = vote;
                         commetCell.commentItem.voteState = voteSate;
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [commetCell setVoteStatus:commetCell.commentItem animation:NO];
                         });
                         
                     } else {
                         commetCell.commentItem.vote--;
                         commetCell.commentItem.voteState = CommentStatusType_None;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [commetCell setVoteStatus:commetCell.commentItem animation:NO];
                         });
                         stauts.textLabel.text = responseObject[@"message"];
                         [JDStatusBarNotification dismissAfter:2];
                     }
                 }
                 failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
                     stauts.textLabel.text = @"网络错误，点赞失败";
                     [JDStatusBarNotification dismissAfter:2];
                     
                     commetCell.commentItem.vote--;
                     commetCell.commentItem.voteState = CommentStatusType_None;
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [commetCell setVoteStatus:commetCell.commentItem animation:NO];
                     });
                     
                 }];
        } else if (commetCell.commentItem.voteState == CommentStatusType_Like) {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"不支持取消点赞喔！";
            [hud hideAnimated:YES afterDelay:2];
        }
        
    }
}

- (void)commetCellDidClickCommentButton:(OSCCommetCell* )commetCell
{
    if (commetCell.commentItem.author.id > 0) {
        _isReply = YES;
        [self showEditView];
        _clickCommentItem = commetCell.commentItem;
        [self locationDataSource:commetCell.commentItem];
        [self.inputView insertAtrributeString2TextView:[Utils handle_TagString:[NSString stringWithFormat:@"@%@ ",commetCell.commentItem.author.name] fontSize:14]];

    } else {
        MBProgressHUD *hud = [Utils createHUD];
        hud.mode = MBProgressHUDModeCustomView;
        hud.label.text = @"该用户不存在，不可引用回复";
        [hud hideAnimated:YES afterDelay:1];
    }
}

#pragma mark - keyboard

- (void)keyboardDidShow:(NSNotification *)nsNotification
{
    
    //获取键盘的高度
    
    NSDictionary *userInfo = [nsNotification userInfo];
    
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    
    _keyboardHeight = keyboardRect.size.height;
    
    [UIView animateWithDuration:1 animations:^{
        self.inputView.frame = CGRectMake(0, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - _keyboardHeight, kScreenSize.width, CGRectGetHeight(self.inputView.frame));
        _tapView.frame = CGRectMake(0, 0, kScreenSize.width, kScreenSize.height - CGRectGetHeight(self.inputView.frame) - keyboardRect.size.height);
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    [self hideEditView];
}

#pragma mark - 软键盘隐藏
- (void)keyBoardHiden:(UITapGestureRecognizer *)tap
{
    [self.view removeGestureRecognizer:_tap];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 按钮评论
- (void)selectedToComment:(UIButton *)button
{
    OSCCommentItem *comment = _comments[button.tag];

    if (_selectIndexPath == button.tag) {
        _isReply = !_isReply;
    } else {
        _isReply = YES;
    }
    _selectIndexPath = button.tag;

    if (_isReply) {
        if (comment.author.id > 0) {
            _commentTextView.placeholder = [NSString stringWithFormat:@"@%@ ", comment.author.name];

        } else {
            MBProgressHUD *hud = [Utils createHUD];
            hud.mode = MBProgressHUDModeCustomView;
            hud.label.text = @"该用户不存在，不可引用回复";
            [hud hideAnimated:YES afterDelay:1];
        }
        
    } else {
        _commentTextView.placeholder = @"发表评论";
    }
    
    [self locationDataSource:comment];
    
    [_commentTextView becomeFirstResponder];
}

/*
 生成本地新评论
 */
- (void)locationDataSource:(OSCCommentItem *)comment
{
    _locationCommentItem = [OSCCommentItem new];
    
    if (_isReply) {
        OSCCommentItemRefer *newRefer = [OSCCommentItemRefer new];
        newRefer.author = comment.author.name;
        newRefer.content = comment.content;
        newRefer.pubDate = comment.pubDate;
        
        NSMutableArray *refers = [NSMutableArray new];
        [refers addObjectsFromArray:comment.refer];
        [refers addObject:newRefer];
        
        _locationCommentItem.refer = [refers mutableCopy];
    }
}

#pragma mark - 发评论
- (void)sendComment:(NSInteger)replyID authorID:(NSInteger)authorID withString:(NSString *)commentStr
{
        //本地数据
        if (_locationCommentItem == nil) {
            _locationCommentItem = [OSCCommentItem new];
        }
        OSCUserItem *author = [Config myNewProfile];
        _locationCommentItem.author = author;
        _locationCommentItem.content = commentStr;
        _locationCommentItem.pubDate = [Utils getCurrentTimeString];
        [_locationCommentItem calculateLayout:YES];
        [_comments insertObject:_locationCommentItem atIndex:0];
        _commentTextView.text = @"";
        _commentTextView.placeholder = @"发表评论";
        [self.tableView reloadData];
        
        //网络请求
        AFHTTPRequestOperationManager* manger = [AFHTTPRequestOperationManager OSCJsonManager];
        JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"评论发送中..."];
        [manger POST:[NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_COMMENT_PUSH]
          parameters:@{
                       @"sourceId"   : @(self.sourceId),
                       @"type"       : @(self.commentType),
                       @"content"    : commentStr,
                       @"replyId"    : (_isReply ? @(replyID) : @(0)),
                       @"reAuthorId" : (_isReply ? @(authorID) : @(0)),
                       }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"]integerValue] == 1) {
                     stauts.textLabel.text = @"发送成功";
                     [JDStatusBarNotification dismissAfter:2];
                     //处理用户阅读信息搜集评论状态
                     if (self.changeCommentStatus_block) {
                         self.changeCommentStatus_block(YES);
                     }
                     _isReply = NO;
                 } else {
                 stauts.textLabel.text = @"发送失败";
                 [JDStatusBarNotification dismissAfter:2];
                 [_comments removeObjectAtIndex:0];
                 [_commentTextView handleAttributeWithString:_locationCommentItem.content];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             stauts.textLabel.text = @"网络错误，发送失败";
             [JDStatusBarNotification dismissAfter:2];
             [_comments removeObjectAtIndex:0];
             [_commentTextView handleAttributeWithString:_locationCommentItem.content];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         }];
}

#pragma mark --- 转发
- (void)forwardTweetWithContent:(NSString *)contentText{
    JDStatusBarView *stauts = [JDStatusBarNotification showWithStatus:@"转发中.."];
    NSDictionary *parameDic = @{
                                @"content":contentText,
                                @"aboutId":@(_sourceId),
                                @"aboutType":@(_commentType)
                                };
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    [manager POST:[OSCAPI_V2_HTTPS_PREFIX stringByAppendingString:@"tweet"] parameters:parameDic success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            stauts.textLabel.text = @"转发成功";
        }else{
            stauts.textLabel.text = @"转发失败";
        }
        [JDStatusBarNotification dismissAfter:2];
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        stauts.textLabel.text = @"转发失败";
        [JDStatusBarNotification dismissAfter:2];
    }];
}

#pragma mark - CommentTextViewDelegate
- (void)ClickTextViewWithString:(NSString *)string
{
    [self showEditView];
}

#pragma --mark OSCPopInputViewDelegate

- (void)popInputViewDidDismiss:(OSCPopInputView *)popInputView
            draftNoteAttribute:(NSAttributedString *)draftNoteAttribute
{
    [_commentTextView handleAttributeWithAttribute:draftNoteAttribute];
}

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView
{
    OSCTweetFriendsViewController * vc = [OSCTweetFriendsViewController new];
    [self hideEditView];
    _isShowEditView = NO;
    [vc setSelectDone:^(NSString *result) {
        [self showEditView];
        [self.inputView insertAtrributeString2TextView:[Utils handle_TagString:result fontSize:14]];
        _isShowEditView = YES;
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)popInputViewClickDidSendButton:(OSCPopInputView *)popInputView selectedforwarding:(BOOL)isSelectedForwarding curTextView:(YYTextView *)textView{
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    }
    if (_isReply) {
        [self sendComment:_clickCommentItem.id authorID:_clickCommentItem.author.id withString:textView.text];
        if (isSelectedForwarding) {
            [self forwardTweetWithContent:textView.text];
        }
    } else {
        if (textView.text.length > 0) {
            [self sendComment:0 authorID:0 withString:textView.text];
            if (isSelectedForwarding) {
                [self forwardTweetWithContent:textView.text];
            }
        } else {
            MBProgressHUD *HUD = [Utils createHUD];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.label.text = @"评论不能为空";
            
            [HUD hideAnimated:YES afterDelay:1];
        }
    }
    [self.inputView clearDraftNote];
    [self hideEditView];
}

#pragma mark --- EditView status
- (void)showEditView{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _backView = [[UIView alloc] initWithFrame:window.bounds];
    _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
//    [_backView addGestureRecognizer:tapGR];
    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 200 )];
    
    _tapView = tapView;
    tapView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
    [tapView addGestureRecognizer:tapGR];
    
    [_backView addSubview:tapView];
    
    [window addSubview:_backView];

    [_backView addSubview:self.inputView];
    [self.inputView activateInputView];
}

- (void)hideEditView{
    [self.inputView freezeInputView];
    [UIView animateWithDuration:0.3 animations:^{
        _backView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        self.inputView.frame = CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) ;
    } completion:^(BOOL finished) {
        [_backView removeFromSuperview];
        _backView = nil;
    }];
}
- (void)touchBackWithGR:(UITapGestureRecognizer *)tapGR{
    CGPoint touchPoint = [tapGR locationInView:_backView];
    CGRect rect = CGRectMake(0, 0, kScreenSize.width, CGRectGetMinY(self.inputView.frame));
    if (CGRectContainsPoint(rect, touchPoint)) {
        [self hideEditView];
    }
}

- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Forwarding;
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld_%ld",_commentType,(long)_sourceId];
    }
    return _inputView;
}


#pragma - mark SelectBoardViewDelegate

- (void)copyClickBtn:(OSCCommentItem *)item {
    //复制到剪切板
    [self.shareV dismissContactView];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = item.content;
    //提示复制成功
    MBProgressHUD *hud = [Utils createHUD];
    hud.mode = MBProgressHUDModeCustomView;
    hud.label.text = @"已经复制到剪切板";
    [hud hideAnimated:YES afterDelay:1];

}

- (void)commentClickBtn:(OSCCommentItem *)item {
    //弹出评论框
    [self.shareV dismissContactView];

    if (item.author.id > 0) {
        _isReply = YES;
        [self showEditView];
        _clickCommentItem = item;
        [self locationDataSource:item];
        [self.inputView insertAtrributeString2TextView:[Utils handle_TagString:[NSString stringWithFormat:@"@%@ ",item.author.name] fontSize:14]];
    } else {
        MBProgressHUD *hud = [Utils createHUD];
        hud.mode = MBProgressHUDModeCustomView;
        hud.label.text = @"该用户不存在，不可引用回复";
        [hud hideAnimated:YES afterDelay:1];
    }
    
}
- (void)shareClickBtn:(OSCCommentItem *)item{
    [self.shareV dismissContactView];
    //弹出图片分享界面
    [[OSCShareInvitation shareManager] showShareBoardWithImage:self.shareImg];

}

@end
