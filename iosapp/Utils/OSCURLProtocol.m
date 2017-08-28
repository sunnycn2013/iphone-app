//
//  OSCURLProtocol.m
//  iosapp
//
//  Created by Graphic-one on 16/12/19.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCURLProtocol.h"
#import "OSCAPI.h"
#import "GACompressionPicHandle.h"

#import "NSObject+Comment.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <SDWebImage/SDWebImageDownloader.h>

@implementation OSCURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    
    if([NSURLProtocol propertyForKey:@"OSCUrlProtocolKey" inRequest:request]) { return NO; }

    NSString* requestURL = request.URL.absoluteString;
    requestURL = [requestURL substringFromIndex:7];
    
    NSString* webViewImagesCacheFolderPath = [NSObject webViewImagesCacheFolderPath];
    
    if ([requestURL rangeOfString:webViewImagesCacheFolderPath].length > 0) {
        
        NSMutableString* mutableStr = requestURL.mutableCopy;
        NSString* imageID_Path = [mutableStr substringWithRange:NSMakeRange(webViewImagesCacheFolderPath.length, mutableStr.length - webViewImagesCacheFolderPath.length)];
        
        NSString* cacheImageUrl = requestURL;
        
        __block BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheImageUrl];
        
        if (isExists) {
            [[NSNotificationCenter defaultCenter] postNotificationName:downloaded_noti_name object:[self notificationInfo:YES usingImagePath:imageID_Path]];

            return YES;
        }else{
            if ([AFNetworkReachabilityManager shareReachability].networkReachabilityStatus != AFNetworkReachabilityStatusReachableViaWWAN) {//Wifi
                NSMutableString* mutableStr = [NSMutableString stringWithString:imageID_Path];
                [mutableStr insertString:@"/" atIndex:5];
                [mutableStr insertString:@"/" atIndex:10];
                NSString* curImageNetUrl = [NSString stringWithFormat:@"%@%@",OSC_Instation_Static_Image_Path,mutableStr.copy];
                
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:curImageNetUrl]
                                                                      options:SDWebImageDownloaderUseNSURLCache | SDWebImageDownloaderHandleCookies
                                                                     progress:nil
                                                                    completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                        
                if (error == nil) {

                    if (CGImageGetWidth(image.CGImage) > [UIScreen mainScreen].bounds.size.width - 32) {
                        if (data.length >= Compression_Default) {
                            
                            CGFloat scale = CGImageGetWidth(image.CGImage) / CGImageGetHeight(image.CGImage);
                            CGFloat tager_W = [UIScreen mainScreen].bounds.size.width - 32;
                            CGFloat tager_H = tager_W / scale;
                            
                            data = [[GACompressionPicHandle shareCompressionPicHandle] imageByScalingAndCroppingForSize:(CGSize){tager_W,tager_H} image:image];
                            
                        }
                    }
                    isExists = [data writeToFile:cacheImageUrl atomically:YES];
                    
                    if (isExists) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:downloaded_noti_name object:[self notificationInfo:YES usingImagePath:imageID_Path]];
                    }else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:downloaded_noti_name object:[self notificationInfo:NO usingImagePath:imageID_Path]];
                    }
                    
                }else{
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:downloaded_noti_name object:[self notificationInfo:NO usingImagePath:imageID_Path]];
                    
                }
                                                                        }];
                
            }else{// Not Wifi
                [[NSNotificationCenter defaultCenter] postNotificationName:downloaded_noti_name object:[self notificationInfo:NO usingImagePath:imageID_Path]];
            }

            return YES;
        }
        
    }else{
        
        return YES;
        
    }

}

/**
 notiDic
 @{
 @"isDownloaded" : YES or NO ,
 @"useImagePath" : NSString ,
  }
 */
+ (NSDictionary* )notificationInfo:(BOOL)isDownloaded
                    usingImagePath:(NSString* )imagePath
{
    return @{
             WebViewImage_Notication_IsDownloaded_Key : @(isDownloaded) ,
             WebViewImage_Notication_UseImagePath_Key : imagePath
             };
}

#pragma mark - Session delegate 

+(NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+(BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

-(void)startLoading
{
    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@YES forKey:@"OSCUrlProtocolKey" inRequest:mutableRequest];

    self.connection = [NSURLConnection connectionWithRequest:mutableRequest delegate:self];
    
//    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
}

- (void)stopLoading {
    [self.connection cancel];
//    [self.session invalidateAndCancel];
    self.session =nil;
}

#pragma mark --NSURLProtocol Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}



@end
