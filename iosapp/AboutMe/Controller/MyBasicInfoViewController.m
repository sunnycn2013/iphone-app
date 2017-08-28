//
//  MyBasicInfoViewController.m
//  iosapp
//
//  Created by 李萍 on 15/2/5.
//  Copyright (c) 2015年 oschina. All rights reserved.
//

#import "MyBasicInfoViewController.h"
#import "OSCUserItem.h"
#import "UIColor+Util.h"
#import "OSCAPI.h"
#import "Config.h"
#import "Utils.h"
#import "HomepageViewController.h"
#import "ImageViewerController.h"
#import "AppDelegate.h"
#import "OSCMyBasicInfoCell.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <UIImageView+WebCache.h>
#import <AFNetworking.h>
#import <AFOnoResponseSerializer.h>
#import <Ono.h>
#import <MBProgressHUD.h>

static NSString *reuseIdentifier = @"OSCMyBasicInfoCell";

@interface MyBasicInfoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) OSCUserItem *myNewProfile;
@property (nonatomic, readonly, assign) int64_t myID;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIImageView *portrait;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *idendityLabel;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *moreInfo;
@property (nonatomic, assign) BOOL isShowIdendity;

@end

@implementation MyBasicInfoViewController

- (instancetype)initWithUserItem:(OSCUserItem *)userItem
              isNeedShowIdendity:(BOOL)isShowIdendity
{
    self = [super init];
    if (self) {
        _myNewProfile = userItem;
        _isShowIdendity = isShowIdendity;
        
        _titles = [NSArray new];
        _moreInfo = [NSArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.bounces = NO;
    self.navigationItem.title = (_myNewProfile.id == [Config getOwnID] ? @"我的资料" : _myNewProfile.name);
    self.view.backgroundColor = [UIColor themeColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCMyBasicInfoCell" bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    _titles = @[@"加入时间：", @"所在地区：", @"开发平台：", @"专长领域：",@"个性签名："];
    NSString *joinTime = [_myNewProfile.more.joinDate componentsSeparatedByString:@" "][0];
    _moreInfo = @[
                          joinTime ?: @"<无>",
                          ![_myNewProfile.more.city isEqualToString:@""] ? _myNewProfile.more.city : @"<无>",
                          ![_myNewProfile.more.platform isEqualToString:@""] ? _myNewProfile.more.platform: @"<无>",
                          ![_myNewProfile.more.expertise isEqualToString:@""] ? _myNewProfile.more.expertise : @"<无>",
						  ![_myNewProfile.desc isEqualToString:@""] ? _myNewProfile.desc : @"<无>"
                          ];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_HUD hideAnimated:YES];
}



#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView *header = [UIImageView new];
    header.clipsToBounds = YES;
    header.userInteractionEnabled = YES;
    header.contentMode = UIViewContentModeScaleAspectFill;
    header.image = [UIImage imageNamed:@"bg_my"];
    
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [_portrait setCornerRadius:25];
    [_portrait loadPortrait:[NSURL URLWithString:_myNewProfile.portrait] userName:_myNewProfile.name];
    _portrait.userInteractionEnabled = YES;
    [header addSubview:_portrait];
    
    _nameLabel = [UILabel new];
    _nameLabel.font = [UIFont boldSystemFontOfSize:18];
    _nameLabel.textColor = [UIColor colorWithHex:0xEEEEEE];
    _nameLabel.text = _myNewProfile.name;
    [header addSubview:_nameLabel];
    
    _idendityLabel = [UILabel new];
    _idendityLabel.font = [UIFont systemFontOfSize:10.0];
    _idendityLabel.text = @"官方人员";
    _idendityLabel.textColor = [UIColor whiteColor];
    _idendityLabel.textAlignment = NSTextAlignmentCenter;
    _idendityLabel.layer.masksToBounds = YES;
    _idendityLabel.layer.cornerRadius = 2;
    _idendityLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    _idendityLabel.layer.borderWidth = 1;
    [header addSubview:_idendityLabel];
    if (_myNewProfile.identity.officialMember && _isShowIdendity) {
        _idendityLabel.hidden = NO;
    }else{
        _idendityLabel.hidden = YES;
    }
    
    for (UIView *view in header.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *views = NSDictionaryOfVariableBindings(_portrait, _nameLabel,_idendityLabel);
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_portrait(50)]-8-[_nameLabel]-8-[_idendityLabel(16)]-8-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_portrait(50)]" options:0 metrics:nil views:views]];
    
    [header addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_idendityLabel(50)]" options:0 metrics:nil views:views]];
    
    [header addConstraint:[NSLayoutConstraint constraintWithItem:_portrait attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:header attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    [header addConstraint:[NSLayoutConstraint constraintWithItem:_idendityLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                          toItem:header attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
    
    return header;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCMyBasicInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor cellsColor];

    cell.titleLabel.text = _titles[indexPath.row];
    cell.moreInfoLabel.text = _moreInfo[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 135;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (void)tapPortrait
{
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
       
        if (_myNewProfile.portrait.length == 0 || [_myNewProfile.portrait containsString:@"/img/portrait.gif"]) {
            UIAlertController *alertCtlBigImage = [UIAlertController alertControllerWithTitle:@"尚未设置头像" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertCtlBigImage addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                return;
            }]];
            
            [self presentViewController:alertCtlBigImage animated:YES completion:nil];
            
            return ;
        }
        
        NSArray *array1 = [_myNewProfile.portrait componentsSeparatedByString:@"_"];
        
        NSArray *array2 = [array1[1] componentsSeparatedByString:@"."];
		
		NSString *bigPortraitURL;
		
		if (array1 != nil && array2 != nil) {
			bigPortraitURL = [NSString stringWithFormat:@"%@_200.%@", array1[0], array2[1]];
		} else {
			bigPortraitURL = _myNewProfile.portrait;
		}
		
        ImageViewerController *imgViewweVC = [[ImageViewerController alloc] initWithImageURL:[NSURL URLWithString:bigPortraitURL]];
        [self presentViewController:imgViewweVC animated:YES completion:nil];
    }]];
    
    //功能：取消
    [alertCtl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return;
    }]];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}

- (void)updatePortrait
{
    MBProgressHUD *HUD = [Utils createHUD];
    HUD.label.text = @"正在上传头像";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager OSCManager];
    
    [manager POST:[NSString stringWithFormat:@"%@%@", OSCAPI_PREFIX, OSCAPI_USERINFO_UPDATE] parameters:@{@"uid":@([Config getOwnID])}
    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (_image) {
            [formData appendPartWithFileData:[Utils compressImage:_image] name:@"portrait" fileName:@"img.jpg" mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation *operation, ONOXMLDocument *responseDoment) {
        ONOXMLElement *result = [responseDoment.rootElement firstChildWithTag:@"result"];
        int errorCode = [[[result firstChildWithTag:@"errorCode"] numberValue] intValue];
        NSString *errorMessage = [[result firstChildWithTag:@"errorMessage"] stringValue];
        
        HUD.mode = MBProgressHUDModeCustomView;
        if (errorCode) {
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"HUD-done"]];
            HUD.label.text = @"头像更新成功";
            
            HomepageViewController *homepageVC = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
            [homepageVC refresh];
            
            _portrait.image = _image;
        } else {
            HUD.label.text = errorMessage;
        }
        [HUD hideAnimated:YES afterDelay:1];
        
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





@end
