//
//  HomepageViewController.m
//  iosapp
//
//  Created by AeternChan on 7/18/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "AppDelegate.h"
#import "HomepageViewController.h"
#import "Utils.h"
#import "Config.h"
#import "OSCAPI.h"
#import "TeamAPI.h"

#import "TeamTeam.h"
#import "OSCUserItem.h"
#import "OSCFavorites.h"
#import "OSCMsgCount.h"
#import "OSCModelHandler.h"

#import "SwipableViewController.h"
#import "FriendsViewController.h"
#import "FavoritesViewController.h"
#import "NewLoginViewController.h"
#import "MyBasicInfoViewController.h"

#import "TeamCenter.h"
#import "SettingsPage.h"
#import "MyBlogsViewController.h"
#import "MyQustionViewController.h"
#import "HomePageHeadView.h"
#import "ImageViewerController.h"
#import "OSCMessageCenterController.h"
#import "TweetTableViewController.h"
#import "MyActivityListViewController.h"

#import "NSObject+Comment.h"
#import "UINavigationBar+BackgroundColor.h"
#import "UIScrollView+ScalableCover.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"
#import "UIImage+Comment.h"

#import <MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh.h>

static NSString *reuseIdentifier = @"HomeButtonCell";


#define screen_height [UIScreen mainScreen].bounds.size.height - 88
#define Large_Size  (CGSize){40,20}
#define Medium_Size (CGSize){30,20}
#define Small_Size  (CGSize){20,20}


@interface HomepageViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ButtonViewDelegate>

@property (nonatomic, strong) UIImageView *myQRCodeImageView;

@property (nonatomic, assign) int64_t myID;
@property (nonatomic, strong) OSCUserItem *myNewProfile;
@property (nonatomic, strong) OSCUserItem *myInfo;
@property (nonatomic, assign) BOOL isLogin;
@property (nonatomic, strong) NSMutableArray *noticeCounts;
@property (nonatomic, assign) NSInteger badgeValue;

@property (nonatomic, strong) UIImageView * imageView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) HomePageHeadView *homePageHeadView;
@property (nonatomic, strong) UIView *statusBarView;//状态栏
@property (nonatomic, assign) BOOL isNewFans;

@end

@implementation HomepageViewController

- (void)awakeFromNib
{
    [super awakeFromNib];

    ///登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userRefreshHandler:)
                                                 name:@"userRefresh"
                                               object:nil];
    
    ///msgCount通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newNoticeUpdate:)
                                                 name:MsgCount_Notification_Key
                                               object:nil];
    
    if ([OSCMsgCount currentMsgCount].totalCount) {
        self.navigationController.tabBarItem.badgeValue = [@([OSCMsgCount currentMsgCount].totalCount) stringValue];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.tableView.tableHeaderView = self.homePageHeadView;
    [self.tableView sendSubviewToBack:self.homePageHeadView];
    
    [self refreshHeaderView];
    
    [self refresh];
    [self.tableView reloadData];
    [self.navigationController.navigationBar lt_setBackgroundColor:[UIColor navigationbarColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor clearColor]}];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forBarMetrics:UIBarMetricsDefault];

    [self.navigationController.navigationBar lt_setBackgroundColor:[[UIColor navigationbarColor] colorWithAlphaComponent:0]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar setBackgroundImage:[Utils createImageWithColor:[UIColor navigationbarColor]] forBarMetrics:UIBarMetricsDefault];
    
    [self.navigationController.navigationBar lt_setBackgroundColor:[[UIColor navigationbarColor] colorWithAlphaComponent:1]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.homePageHeadView = nil;
    self.tableView.tableHeaderView = nil;
    
    [self.navigationController.navigationBar lt_reset];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    _imageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor separatorColor];
    self.tableView.bounces = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeButtonCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    _myID = [Config getOwnID];
    [self refreshHeaderView];
    
    [self refresh];
    
    self.tableView.tableFooterView = [UIView new];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_qrcode"] style:UIBarButtonItemStylePlain target:self action:@selector(showCodeAction)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_my_setting"] style:UIBarButtonItemStylePlain target:self action:@selector(setUpAction)];
    self.navigationItem.title = @"我的";
    
    [self refreshNotice:[OSCMsgCount currentMsgCount]];
}

#pragma mark - dealloc
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 处理导航栏下1px横线
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

#pragma mark - 刷新
- (void)refresh
{
    _myID = [Config getOwnID];
    if (_myID == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshHeaderView];
            [self.refreshControl endRefreshing];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        });
    } else {
        //新用户信息接口
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
        
        NSString *strUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_GET_USER_INFO];
        
        [manager GET:strUrl
          parameters:nil
             success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                 NSInteger code = [responseObject[@"code"] integerValue];
                 if (code == 1) {
                     _myInfo = [OSCUserItem osc_modelWithDictionary:responseObject[@"result"]];
                 
                     [Config updateNewProfile:_myInfo];
                     [self refreshHeaderView];
                     [self.refreshControl endRefreshing];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.tableView reloadData];
                     });
                 }
                 

             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 MBProgressHUD *HUD = [Utils createHUD];
                 HUD.mode = MBProgressHUDModeCustomView;
                 HUD.label.text = @"网络异常，加载失败";
                 
                 [HUD hideAnimated:YES afterDelay:1];
                 
                 [self.refreshControl endRefreshing];
             }];
        //*/
    }
}


#pragma mark - refresh header

- (void)refreshHeaderView
{
    _myNewProfile = [Config myNewProfile];
    
    _isLogin = _myID != 0;
    
    if (_isLogin) {//_myProfile.portraitURL
        if ([_myNewProfile.portrait containsString:@"oschina.net/img/portrait"] ||
            [_myNewProfile.portrait containsString:@"secure.gravatar.com/avatar"]){
            [self.homePageHeadView.userPortrait setImage:[UIImage creatCharacterPortrait:_myNewProfile.name]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TweetUserUpdate" object:@(YES)];
        }else{
            [self.homePageHeadView.userPortrait sd_setImageWithURL:[NSURL URLWithString:_myNewProfile.portrait]
                                                  placeholderImage:[UIImage creatCharacterPortrait:_myNewProfile.name]
                                                           options:SDWebImageContinueInBackground | SDWebImageHandleCookies
                                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                                             if (!image) {return;}
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"TweetUserUpdate" object:@(YES)];
                                                         }];
        }
        
        self.homePageHeadView.creditLabel.hidden = NO;
        self.homePageHeadView.creditLabel.text = [NSString stringWithFormat:@"积分 %ld", (long)_myNewProfile.statistics.score];
        
    } else {
        self.homePageHeadView.userPortrait.image = [UIImage imageNamed:@"default-portrait"];
        self.homePageHeadView.creditLabel.hidden = YES;
    }
    
    self.homePageHeadView.buttonView.hidden = !_isLogin;
    self.homePageHeadView.nameLabel.font = [UIFont systemFontOfSize:_isLogin ? 20 : 15];
    self.homePageHeadView.nameLabel.text = _isLogin ? _myNewProfile.name : @"点击头像登录";
    self.homePageHeadView.genderImageView.hidden = YES;
    if (_myNewProfile.gender == 1) {
        [self.homePageHeadView.genderImageView setImage:[UIImage imageNamed:@"ic_male"]];
        self.homePageHeadView.genderImageView.hidden = NO;
    } else if (_myNewProfile.gender == 2) {
        [self.homePageHeadView.genderImageView setImage:[UIImage imageNamed:@"ic_female"]];
        self.homePageHeadView.genderImageView.hidden = NO;
    }
    
    self.homePageHeadView.buttonView.userInfo = _myNewProfile;
    self.homePageHeadView.buttonView.delegate = self;
    
    [self.homePageHeadView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPortraitAction)]];
    self.homePageHeadView.userInteractionEnabled = YES;
    
    
    [self setUpSubviews];
}


#pragma mark - customize subviews

- (void)setUpSubviews
{
    [self.homePageHeadView.userPortrait setBorderWidth:2.0 andColor:[UIColor whiteColor]];
    [self.homePageHeadView.userPortrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changePortraitAction)]];
    
    self.refreshControl.tintColor = [UIColor refreshControlColor];
}

#pragma mark - change Portrait
- (void)changePortraitAction
{
    if (![Utils isNetworkExist]) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = @"网络无连接，请检查网络";
        
        [HUD hideAnimated:YES afterDelay:1];
    } else {
        if ([Config getOwnID] == 0) {

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
            NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
            [self.navigationController presentViewController:loginVC animated:YES completion:nil];

        } else {
            UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"选择操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            //功能：更换头像
            [alertCtl addAction:[UIAlertAction actionWithTitle:@"更换头像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UIAlertController *alertCtlPhoto = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleAlert];
                
                [alertCtlPhoto addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        
                        UIAlertController *alertCtlCam = [UIAlertController alertControllerWithTitle:@"Error" message:@"Device has no camera" preferredStyle:UIAlertControllerStyleAlert];
                        [alertCtlCam addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            return;
                        }]];
                        
                        [self presentViewController:alertCtlCam animated:YES completion:nil];
                        
                    } else {
                        UIImagePickerController *imagePickerController = [UIImagePickerController new];
                        imagePickerController.delegate = self;
                        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                        imagePickerController.allowsEditing = YES;
                        imagePickerController.showsCameraControls = YES;
                        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
                        imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                        
                        [self presentViewController:imagePickerController animated:YES completion:nil];
                    }
                }]];
                [alertCtlPhoto addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController *imagePickerController = [UIImagePickerController new];
                    imagePickerController.delegate = self;
                    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePickerController.allowsEditing = YES;
                    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
                    [self presentViewController:imagePickerController animated:YES completion:nil];
                }]];
                
                [alertCtlPhoto addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    return;
                }]];
                
                [self presentViewController:alertCtlPhoto animated:YES completion:nil];
                
            }]];
            
            //功能：查看大头像
            [alertCtl addAction:[UIAlertAction actionWithTitle:@"查看大头像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
				NSString *pattern = @"_[0-9]{1,3}";
				NSError *error = nil;
				NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
				NSArray *resultsArray = [re matchesInString:_myInfo.portrait options:0 range:NSMakeRange(0, _myInfo.portrait.length)];
				NSString *portroitURL;
				if (resultsArray.count > 0) {
					NSTextCheckingResult *match = [resultsArray lastObject];
					NSRange range = match.range;
					portroitURL = [_myInfo.portrait stringByReplacingCharactersInRange:range withString:@"_200"];
				}else{
					portroitURL = _myInfo.portrait;
				}
				
                ImageViewerController *imgViewweVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:portroitURL]];
                
                [self presentViewController:imgViewweVC animated:YES completion:nil];
            }]];
            
            //功能：取消
            [alertCtl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                return;
            }]];
            
            [self presentViewController:alertCtl animated:YES completion:nil];
        }
    }
    
}

- (void)updatePortrait
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"正在上传头像";

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCJsonManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", OSCAPI_V2_PREFIX, OSCAPI_USER_EDIT_PORTRAIT];
    
    [manager POST:strUrl
parameters:@{@"uid":@([Config getOwnID])}
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (_image) {
            [formData appendPartWithFileData:[Utils compressImage:_image]
                                        name:@"portrait"
                                    fileName:@"img.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 1) {
            _myInfo = [OSCUserItem osc_modelWithDictionary:responseObject[@"result"]];
            
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
            HUD.label.text = @"头像更新成功";
        } else {
            HUD.label.text = @"头像更换失败";
        }
        [HUD hideAnimated:YES afterDelay:1];
        [Config updateNewProfile:_myInfo];
        
        [self refreshHeaderView];
        [self.refreshControl endRefreshing];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.label.text = @"网络异常，头像更换失败";
        
        [HUD hideAnimated:YES afterDelay:1];
    }];
    
}


#pragma mark - UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerEditedImage];
    
    [picker dismissViewControllerAnimated:YES completion:^ {
        [self updatePortrait];
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)tapPortraitAction
{
    if (![Utils isNetworkExist]) {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeText;
        HUD.label.text = @"网络无连接，请检查网络";
        
        [HUD hideAnimated:YES afterDelay:1];
    } else {
        if ([Config getOwnID] == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
            NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
            [self presentViewController:loginVC animated:YES completion:nil];
        } else {
            MyBasicInfoViewController *basicInfoVC = [[MyBasicInfoViewController alloc] initWithUserItem:[Config myNewProfile] isNeedShowIdendity:NO];
            basicInfoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:basicInfoVC animated:YES];
        }
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 5;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = [UIColor colorWithHex:0xF5FFFA];
    [cell setSelectedBackgroundView:selectedBackground];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.textLabel.text = @[@"我的消息", @"我的博客", @"我的问答", @"我的活动", @"我的团队"][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@[@"ic_my_messege", @"ic_my_blog", @"ic_my_question", @"ic_my_event", @"ic_my_team"][indexPath.row]];
    
    
    cell.textLabel.textColor = [UIColor titleColor];
    
    if (indexPath.row == 0) {
        if (_badgeValue == 0) {
            cell.accessoryView = nil;
        } else {
            CGSize labelSize;
            
            labelSize = _badgeValue > 9 ? (_badgeValue > 99 ? Large_Size : Medium_Size) : Small_Size;
            
            UILabel *accessoryBadge = [[UILabel alloc] initWithFrame:(CGRect){{(CGRectGetWidth(self.view.frame)-36 - labelSize.width), 12}, labelSize}];
            
            accessoryBadge.backgroundColor = [UIColor redColor];
            accessoryBadge.font = [UIFont systemFontOfSize:14];
            accessoryBadge.text = [@(_badgeValue) stringValue];
            accessoryBadge.textColor = [UIColor whiteColor];
            accessoryBadge.textAlignment = NSTextAlignmentCenter;
            accessoryBadge.layer.cornerRadius = 10;
            accessoryBadge.clipsToBounds = YES;
            
            [cell addSubview:accessoryBadge];
        }
    }
 
    
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_isLogin) {
        if ([Config getOwnID] == 0) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
            NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
            [self presentViewController:loginVC animated:YES completion:nil];
            return;
        }
    }
    
    switch (indexPath.row) {
        case 0: {
            OSCMessageCenterController* messageCenter = [[OSCMessageCenterController alloc] init];
            messageCenter.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:messageCenter animated:YES];
            
            break;
        }
        case 1: {
            MyBlogsViewController *blogsVC = [[MyBlogsViewController alloc] initWithUserID:(NSInteger)_myID];
            blogsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:blogsVC animated:YES];
            break;
        }
        case 2: {
            MyQustionViewController *qustionVC = [[MyQustionViewController alloc] initWithAuthorId:(NSInteger)_myID];
            qustionVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:qustionVC animated:YES];
            break;
        }
        case 3: {
            /*
            ActivitiesViewController *myActivitiesVc = [[ActivitiesViewController alloc] initWithUID:[Config getOwnID]];
            myActivitiesVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myActivitiesVc animated:YES];
             */
            
            MyActivityListViewController *myActivitiesVc = [[MyActivityListViewController alloc] initWithAuthorID:[Config getOwnID] authorName:[Config getOwnUserName]];
            myActivitiesVc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myActivitiesVc animated:YES];
            
            break;
        }
        case 4: {
            TeamCenter *teamCenter = [TeamCenter new];
            teamCenter.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:teamCenter animated:YES];
            
            break;
        }
        default: break;
    }
}

#pragma mark - old notice
- (void)noticeUpdate:(NSNotification *)noti
{
    
}

#pragma mark - new notice
- (void)newNoticeUpdate:(NSNotification *)noti
{
    OSCMsgCount *messageCount = (OSCMsgCount *)noti.object;
    
    [self refreshNotice:messageCount];
}

- (void)refreshNotice:(OSCMsgCount *)messageCount
{
    _badgeValue = messageCount.totalCount;
    
    self.homePageHeadView.buttonView.redPointView.hidden = (messageCount.fans > 0) ? NO : YES;
    
    if (_badgeValue) {
        self.navigationController.tabBarItem.badgeValue = [@(_badgeValue) stringValue];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (void)userRefreshHandler:(NSNotification *)notification
{
    _myID = [Config getOwnID];
    
    [self refreshHeaderView];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - 功能

#pragma mark - setup
- (void)setUpAction {
    SettingsPage *settingPage = [SettingsPage new];
    settingPage.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingPage animated:YES];
}

#pragma mark - 二维码相关
- (void)showCodeAction {
    if ([Config getOwnID] == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
        NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
        return;
    } else {
        MBProgressHUD *HUD = [Utils createHUD];
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.customView.backgroundColor = [UIColor whiteColor];
        
        HUD.label.text = @"扫一扫上面的二维码，加我为好友";
        HUD.label.font = [UIFont systemFontOfSize:13];
        HUD.label.textColor = [UIColor grayColor];
        HUD.customView = self.myQRCodeImageView;
        [HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideHUD:)]];
    }
}

- (UIImageView *)myQRCodeImageView
{
    if (!_myQRCodeImageView) {
        UIImage *myQRCode = [Utils createQRCodeFromString:[NSString stringWithFormat:@"http://my.oschina.net/u/%ld", (long)[Config getOwnID]]];
        _myQRCodeImageView = [[UIImageView alloc] initWithImage:myQRCode];
    }
    
    return _myQRCodeImageView;
}

- (void)hideHUD:(UIGestureRecognizer *)recognizer
{
    [(MBProgressHUD *)recognizer.view hideAnimated:YES];
}

#pragma mark - ButtonViewDelegate
- (void)clickButtonAction:(NSInteger)senderTag
{
    NSLog(@"sender tag =%ldd",(long) senderTag);
    switch (senderTag) {
        case 1://动弹
        {
            TweetTableViewController *myFriendTweetViewCtl = [[TweetTableViewController alloc] initTweetListWithType:NewTweetsTypeOwnTweets];
            myFriendTweetViewCtl.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:myFriendTweetViewCtl animated:YES];
            
            break;
        }
        case 2://收藏
        {
            FavoritesViewController *favoritesSVC = [[FavoritesViewController alloc] initWithFavoritesType:FavoritesTypeAll];
            favoritesSVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:favoritesSVC animated:YES];
            
            break;
        }
        case 3://关注
        {
            FriendsViewController *friendVC = [[FriendsViewController alloc] initUserId:(long)_myID andRelation:OSCAPI_USER_FOLLOWS];
            friendVC.title = @"关注";
            friendVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:friendVC animated:YES];
            
            break;
        }
        case 4://粉丝
        {
            FriendsViewController *friendVC = [[FriendsViewController alloc] initUserId:(long)_myID andRelation:OSCAPI_USER_FANS];
            friendVC.title = @"粉丝";
            friendVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:friendVC animated:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - 初始化
- (HomePageHeadView *)homePageHeadView
{
    _isLogin = [Config getOwnID] ? YES : NO;
    if(_homePageHeadView == nil) {
        CGFloat homeViewHeight = 230;
        if (!_isLogin) {
            homeViewHeight = homeViewHeight - 60;
        }
        
        _homePageHeadView = [[HomePageHeadView alloc] initWithFrame:(CGRect){{0,-64},{[UIScreen mainScreen].bounds.size.width, homeViewHeight}}];
    }
    
    return _homePageHeadView;
}

@end
