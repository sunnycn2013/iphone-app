//
//  OSCURLProtocol.h
//  iosapp
//
//  Created by Graphic-one on 16/12/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSCURLProtocol : NSURLProtocol <NSURLConnectionDelegate,NSURLSessionDelegate>

@property (nonatomic,strong) NSURLConnection* connection;

@property (nonatomic,strong) NSURLSession* session;

@end
