//
//  OSCNetImage.h
//  iosapp
//
//  Created by Graphic-one on 16/12/22.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCNetImage : NSObject

@property (nonatomic, copy) NSString *thumb;//小图

@property (nonatomic, copy) NSString *href;//大图

@property (nonatomic, assign) NSInteger w;//原图宽

@property (nonatomic, assign) NSInteger h;//原图高

@property (nonatomic, strong) NSString* type;//图片格式 (image/bmp image/jpeg image/png)

@property (nonatomic, strong) NSString* name;//图片名称

@end
