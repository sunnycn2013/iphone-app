//
//  enumList.h
//  iosapp
//
//  Created by Graphic-one on 16/5/27.
//  Copyright © 2016年 oschina. All rights reserved.
//

#ifndef enumList_h
#define enumList_h

typedef NS_ENUM(NSUInteger, InformationType)
{
    InformationTypeLinkNews = 0,//链接新闻
    InformationTypeSoftWare = 1,//软件推荐
    InformationTypeForum = 2,//讨论区帖子（问答）
    InformationTypeBlog = 3,//博客
    InformationTypeTranslation = 4,//翻译文章
    InformationTypeActivity = 5,//活动类型
    InformationTypeInfo = 6,//资讯
    
    InformationTypeUserCenter = 11,//用户中心
    
    InformationTypeTweet = 100//动弹（评论）类型
};

typedef NS_ENUM(NSInteger, UserGenderType)
{
    UserGenderTypeUnknown = 0 ,//未知
    UserGenderTypeMan,//男性
    UserGenderTypeWoman //女性
};

typedef NS_ENUM(NSInteger, UserRelationStatus)
{
    UserRelationStatusMutual = 1 ,//双方互为粉丝
    UserRelationStatusSelf = 2 ,//你单方面关注他
    UserRelationStatusOther = 3 ,//他单方面关注我
    UserRelationStatusNone = 4 //互不关注
};

typedef NS_ENUM(NSInteger, CommentStatusType)
{
    CommentStatusType_None      = 0 ,//none
    CommentStatusType_Like      = 1 ,//已顶
    CommentStatusType_Unlike    = 2 ,//已踩
};

typedef NS_ENUM (NSUInteger, ActivityStatus){
    ActivityStatusEnd = 1,// 活动已经结束
    ActivityStatusHaveInHand,//活动进行中
    ActivityStatusClose//活动报名已经截止
};

typedef NS_ENUM (NSUInteger, ActivityType){
    ActivityTypeOSChinaMeeting = 1,//源创会
    ActivityTypeTechnical,//技术交流
    ActivityTypeOther,// 其他
    ActivityTypeBelow//站外活动(当为站外活动的时候，href为站外活动报名地址)
};

typedef NS_ENUM(NSUInteger, ApplyStatus) {
    ApplyStatusUnSignUp = -1,//未报名
    ApplyStatusAudited = 0 ,//审核中
    ApplyStatusDetermined = 1 ,//已经确认
    ApplyStatusAttended,//已经出席
    ApplyStatusCanceled,//已取消
    ApplyStatusRejected,//已拒绝
};

typedef NS_ENUM(NSInteger,OSCInformationListBannerType) {
    OSCInformationListBannerTypeNone = 0,//没有banner
    OSCInformationListBannerTypeSimple = 1,//通用banner (UIImageView显示图片 + UILabel显示title)
    OSCInformationListBannerTypeSimple_Blogs = 2,//自定义banner (用于blog列表展示)
    OSCInformationListBannerTypeCustom_Activity = 3,//自定义banner (用于activity列表展示)
};

#define kTopicRecommedTweetImageArray @[@"bg_topic_1",@"bg_topic_2",@"bg_topic_3",@"bg_topic_4",@"bg_topic_5"]

typedef NS_ENUM(NSInteger,TopicRecommedTweetType){
    TopicRecommedTweetTypeFirst = 0,
    TopicRecommedTweetTypeSecond = 1,
    TopicRecommedTweetTypeThird = 2,
    TopicRecommedTweetTypeForth = 3,
    TopicRecommedTweetTypeFifth = 4,
};

/** 机型设备信息 用DeviceResolution作为下标访问*/
#define kDeviceArray @[@"iPhone_4",@"iPhone_4s",@"iPhone_5",@"iPhone_5c",@"iPhone_5s",@"iPhone_6",@"iPhone_6p",@"iPhone_6s",@"iPhone_6sp",@"iPhone_se",@"iPhone_7",@"iPhone_7p",@"Simulator"]

typedef NS_ENUM(NSUInteger,DeviceResolution){
    Device_iPhone_4 = 0 ,
    Device_iPhone_4s    ,
    Device_iPhone_5     ,
    Device_iPhone_5c    ,
    Device_iPhone_5s    ,
    Device_iPhone_6     ,
    Device_iPhone_6p    ,
    Device_iPhone_6s    ,
    Device_iPhone_6sp   ,
    Device_iPhone_se    ,
    Device_iPhone_7     ,
    Device_iPhone_7p    ,
    Device_Simulator
};

typedef NS_ENUM(NSUInteger,SystemVersion){
    Version_iOS7 = 0    ,
    Version_iOS8        ,
    Version_iOS9        ,
    Version_iOS10       ,
    Version_noSupport
};

typedef NS_ENUM(NSUInteger,AppClientType){
    AppClientType_Phone         = 2,//手机
    AppClientType_Android       = 3,//Android
    AppClientType_iPhone        = 4,//iPhone
    AppClientType_WindowsPhone  = 5,//Windows Phone
    AppClientType_WeChat        = 6,//WeChat
};


typedef NS_ENUM(NSInteger, EventApplyPreloadKeyType) //活动报名预拉取字段提交类型
{
    EventApplyPreloadKeyTypeString = 0,
    EventApplyPreloadKeyTypeInt = 1,
};

typedef NS_ENUM(NSInteger, EventApplyPreloadFormType)//活动报名预拉取界面渲染的样式
{
    EventApplyPreloadFormTypeDefault = -1,
    EventApplyPreloadFormTypeText = 0 ,
    EventApplyPreloadFormTypeTextarea,  //备注等多行输入框
    EventApplyPreloadFormTypeSelect,//选择
    EventApplyPreloadFormTypeCheckbox,//多选框
    EventApplyPreloadFormTypeRadio,//单选框
    EventApplyPreloadFormTypeEmail,
    EventApplyPreloadFormTypeDate,
    EventApplyPreloadFormTypeMobile,
    EventApplyPreloadFormTypeNumber,
    EventApplyPreloadFormTypeUrl,
};

typedef NS_OPTIONS(NSInteger, MsgCountType){
    MsgCountTypeMention = 1 << 0,
    MsgCountTypeLetter  = 1 << 1,
    MsgCountTypeReview  = 1 << 2,
    MsgCountTypeFans    = 1 << 3,
    MsgCountTypeLike    = 1 << 4,
    
    MsgCountTypeAll     = 1 << 5,
};

/**
 mention    :   @数量
 letter     :   私信数量
 review     :   回复数量
 fans       :   粉丝数量
 like       :   赞数量
 */

#endif /* enumList_h */
