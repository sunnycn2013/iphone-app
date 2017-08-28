//
//  OSCCommentReplyViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/11/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCCommentReplyViewController.h"
#import "OSCUserHomePageController.h"
#import "CommentDetailViewController.h"
#import "NewLoginViewController.h"
#import "OSCCommetCell.h" //test

#import "OSCAPI.h"
#import "Utils.h"
#import "Config.h"
#import "OSCCommentItem.h"
#import "OSCModelHandler.h"

#import <MJRefresh.h>
#import <MBProgressHUD.h>

#import "CommentTextView.h"
#import "OSCPopInputView.h"
#import "OSCModelHandler.h"
#import "OSCTweetFriendsViewController.h"//新选择@好友列表
#import "JDStatusBarNotification.h"

#import "UIView+Common.h"

@interface OSCCommentReplyViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,OSCPopInputViewDelegate,CommentTextViewDelegate, OSCCommetCellDelegate>

@property (nonatomic, assign) InformationType commentType;
@property (nonatomic, assign) NSInteger sourceId;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic, copy) NSString *nextPageToken;

//软键盘size
@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, assign) BOOL isReply;
@property (nonatomic, assign) NSInteger selectIndexPath;
@property (nonatomic, strong) UITapGestureRecognizer *tap;

@property (nonatomic,strong) OSCPopInputView *inputView;
@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIView *tapView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet CommentTextView *commentTextView;

@property (nonatomic, assign)BOOL isShowEditView;

@end

@implementation OSCCommentReplyViewController

- (instancetype)initWithCommentType:(InformationType)commentType sourceID:(NSInteger)sourceId
{
    self = [super init];
    
    if (self) {
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
    
    self.title = @"评论列表";
    _comments = [NSMutableArray new];
    _nextPageToken = @"";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.commentTextView.commentTextViewDelegate = self;
    [self.tableView registerClass:[OSCCommetCell class] forCellReuseIdentifier:OSCCommetCellIdentifier];
    self.tableView.tableFooterView = [UIView new];
    self.commentTextView.commentTextViewDelegate = self;
    self.commentTextView.placeholder = @"发表评论";
    
    [self getCommentData:YES];
    
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
    [self.tableView hideBlankPageView];
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
//                  @"parts"     : @"refer",
                  }
        success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            
            if (isRefresh) {
                [_comments removeAllObjects];
            }
            
            if ([responseObject[@"code"] integerValue] == 1) {
                NSDictionary *result = responseObject[@"result"];
                NSArray *jsonItems = result[@"items"];
                NSArray *array = [NSArray osc_modelArrayWithClass:[OSCCommentItem class] json:jsonItems];
                
                for (OSCCommentItem *item in array) {
                    [item calculateLayout:NO];
                }
                
                _nextPageToken = result[@"nextPageToken"];
                
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
                if (isRefresh) {
                    [self.tableView.mj_header endRefreshing];
                    [self.tableView reloadData];
                    [self.tableView showBlankPageView];
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
    if (_comments.count) {
        OSCCommentItem *commentItem = _comments[indexPath.row];
        OSCCommetCell *commentCell = [OSCCommetCell commetCellWithTableView:self.tableView
                                                                 identifier:OSCCommetCellIdentifier
                                                                  indexPath:indexPath
                                                                commentItem:commentItem
                                                        commentUxiliaryNode:((self.commentType == InformationTypeActivity) ?CommentUxiliaryNode_comment : CommentUxiliaryNode_none)
                                                            isNeedReference:NO];
        commentCell.selectedBackgroundView = [[UIView alloc] initWithFrame:commentCell.frame];
        commentCell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
        commentCell.delegate = self;
        
        return commentCell;
    } else {
        return [UITableViewCell new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_comments.count) {
        OSCCommentItem *commentItem = _comments[indexPath.row];
        return commentItem.layoutHeight;
    } else {
        return 0;
    }
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCCommentItem *comment = _comments[indexPath.row];
    if (_commentType == InformationTypeActivity) {
        [self showEditView];
        [self.inputView restoreDraftNoteWithAttribute:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"回复 @%@ ：",comment.author.name]]];
    } else if (_commentType == InformationTypeSoftWare) {
        
    } else {
        if (indexPath.section == 0) {
            if (_comments.count > indexPath.row) {
                
                CommentDetailViewController *commentDetailVC = [[CommentDetailViewController alloc] initWithDetailCommentID:comment.id commentAuthorID:comment.author.id detailType:5];
                commentDetailVC.questDetailId = self.sourceId;
                
                [self.navigationController pushViewController:commentDetailVC animated:YES];
            }
            
        }
    }
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

#pragma mark - NSNotification

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

#pragma mark - 发评论
- (void)sendComment:(NSInteger)replyID authorID:(NSInteger)authorID withString:(NSString *)commentStr
{
        //本地数据
        OSCCommentItem *locationCommentItem = [OSCCommentItem new];
        OSCUserItem *author = [Config myNewProfile];
        locationCommentItem.author = author;
        locationCommentItem.content = commentStr;
        locationCommentItem.pubDate = [Utils getCurrentTimeString];
        [locationCommentItem calculateLayout:NO];
        [_comments insertObject:locationCommentItem atIndex:0];
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
                       @"replyId"    : @(replyID),
                       @"reAuthorId" : @(authorID),
                       }
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 if ([responseObject[@"code"]integerValue] == 1) {
                     stauts.textLabel.text = @"发送成功";
                     [JDStatusBarNotification dismissAfter:2];
                     [self.tableView hideBlankPageView];
                     
                     if (self.changeCommentStatus_block) {
                         self.changeCommentStatus_block(YES);
                     }
                     
                 } else {
                     stauts.textLabel.text = responseObject[@"message"];
                     [JDStatusBarNotification dismissAfter:2];
                     [_comments removeObjectAtIndex:0];
                     [_commentTextView handleAttributeWithString:locationCommentItem.content];
                     if (_comments.count == 0) {
                         [self.tableView showBlankPageView];
                     }
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [self.tableView reloadData];
             });
         }
         failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             stauts.textLabel.text = @"网络错误，发送失败";
             [JDStatusBarNotification dismissAfter:2];
             [_commentTextView handleAttributeWithString:commentStr];
             [_comments removeObjectAtIndex:0];
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (_comments.count == 0) {
                     [self.tableView showBlankPageView];
                 }
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

#pragma CommentTextViewDelegate
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

- (void)popInputViewClickDidAtButton:(OSCPopInputView* )popInputView{
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
        OSCCommentItem *comment = _comments[_selectIndexPath];
        [self sendComment:comment.id authorID:comment.author.id withString:textView.text];
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
    [_backView addSubview:self.inputView];
    
    
//    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
//    [_backView addGestureRecognizer:tapGR];

    UIView *tapView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenSize.width, 200 )];
    
    _tapView = tapView;
    tapView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchBackWithGR:)];
    [tapView addGestureRecognizer:tapGR];
    
    [_backView addSubview:tapView];
    
    [self.inputView activateInputView];
    [window addSubview:_backView];
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

#pragma mark --- lazy load
- (OSCPopInputView *)inputView{
    if(!_inputView){
        _inputView = [OSCPopInputView popInputViewWithFrame:CGRectMake(0, kScreenSize.height, kScreenSize.width, kScreenSize.height / 3) maxStringLenght:160 delegate:self autoSaveDraftNote:YES];
        if (_commentType == InformationTypeSoftWare) {
            _inputView.popInputViewType = OSCPopInputViewType_At;
        }else{
            _inputView.popInputViewType = OSCPopInputViewType_At | OSCPopInputViewType_Forwarding;
        }
        _inputView.draftKeyID = [NSString stringWithFormat:@"%ld_%ld",_commentType,(long)_sourceId];
    }
    return _inputView;
}

@end
