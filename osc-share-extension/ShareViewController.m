//
//  ShareViewController.m
//  OSChina
//
//  Created by Peter Gra on 2017/3/27.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "ShareViewController.h"
#import "GACompressionHelper.h"
#import <AudioToolbox/AudioToolbox.h>
#import <MobileCoreServices/MobileCoreServices.h>


#define SHARE_EXTENSION_GROUP_ID @"group.net.oschina.share.tweet.app"

@interface ShareViewController ()

	@property(nonatomic,strong) NSString* imageToken;

	@property(nonatomic,strong) NSString* otherString;

	@property(nonatomic,strong) NSMutableArray* imageArray;

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    self.title = @"开源中国";
    self.placeholder = @"发送至动弹...";
	
	NSInteger messageLength = [[self.contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length];
	NSInteger charRemaining = 140 - messageLength;
	self.charactersRemaining = @(charRemaining);
	
	if (charRemaining >= 0 && charRemaining < 140) {
		return YES;
	}
	
	return NO;
}

-(void) presentationAnimationDidFinish {
	_imageArray = [NSMutableArray arrayWithCapacity:9];
	NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
	NSExtensionItem *outputItem = [inputItem copy];
	
	for (NSItemProvider *provider in outputItem.attachments) {		
		if ([provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeImage]) {
			[provider loadItemForTypeIdentifier:(NSString*)kUTTypeImage options:nil completionHandler:^(UIImage<NSSecureCoding>*  _Nullable imageItem, NSError * _Null_unspecified error) {
				NSData *data = [GACompressionHelper CompressionHelperWithOriginImage:imageItem];
				[self.imageArray addObject:data];
			}];
		}else if([provider hasItemConformingToTypeIdentifier:(NSString*)kUTTypeURL]) {
			[provider loadItemForTypeIdentifier:(NSString*)kUTTypeURL options:nil completionHandler:^(NSURL<NSSecureCoding>*  _Nullable urlItem, NSError * _Null_unspecified error) {
				self.otherString = urlItem.absoluteString;
			}];
		}
	}//end of for
}

-(void) didSelectPost {
	
	if (self.imageArray && self.imageArray.count > 0) {
		[self uploadImages4Tweet];
	} else {
		[self sendTweet];
	}
	
	[self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (void) sendTweet{
	
	NSURLSession* session = [NSURLSession sharedSession];
	NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.oschina.net/action/apiv2/tweet"]];
	mRequest.HTTPMethod = @"POST";
	mRequest.allHTTPHeaderFields = [self headers];
	NSString* contentText = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self.contentText,NULL,CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),kCFStringEncodingUTF8));
	if (self.otherString) {
		contentText = [NSString stringWithFormat:@"%@   %@",contentText,self.otherString];
	}
	
	if (self.imageToken) {
		mRequest.HTTPBody = [[NSString stringWithFormat:@"content=%@&images=%@",contentText,self.imageToken] dataUsingEncoding:NSUTF8StringEncoding];
	} else {
		mRequest.HTTPBody = [[NSString stringWithFormat:@"content=%@",contentText] dataUsingEncoding:NSUTF8StringEncoding];
	}
	
	NSURLSessionDataTask* task = [session dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			[self playSystemSound:NO];
		} else {
			NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
			NSLog(@"++++++++\n%@",dict);
			if (dict) {
				NSNumber* code = dict[@"code"];
				if(code && code.intValue == 1) {
					[self playSystemSound:YES];
				}
			} else {
				[self playSystemSound:NO];
			}//end of if(dict)
		}//end of if(error)
	}];
	
	[task resume];
}



#pragma clang diagnostic pop
- (void) uploadImages4Tweet {
	
	NSURLSession* session = [NSURLSession sharedSession];
	NSMutableURLRequest* mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://www.oschina.net/action/apiv2/resource_image"]];
	mRequest.HTTPMethod = @"POST";
	[mRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	NSMutableDictionary* mutableHeaders = [self headers].mutableCopy;
 	NSData *data = self.imageArray.firstObject;
	[mutableHeaders setValue:[NSString stringWithFormat:@"multipart/form-data; charset=utf-8; boundary=OSCImageUpload"] forKey:@"Content-Type"];
	[mutableHeaders setValue:[NSString stringWithFormat:@"%lu",[self bodyData:data].length] forKey:@"Content-Length"];
	mRequest.allHTTPHeaderFields = mutableHeaders.copy;
	mRequest.HTTPShouldHandleCookies = NO;
	mRequest.HTTPBody = [self bodyData:data];
	mRequest.timeoutInterval = 15;
	
	NSURLSessionUploadTask* task = [session uploadTaskWithRequest:mRequest fromData:[mRequest HTTPBody] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
		if (error) {
			NSLog(@"\n=======>>>>error: \n%@",error);
		} else {
			NSDictionary* dict =  [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
			NSLog(@"\n========>>>result:\n%@",dict);
			if (dict) {
				NSDictionary* resultDict = dict[@"result"];
				if (resultDict && !self.imageToken) {
					self.imageToken = resultDict[@"token"];
					[self.imageArray removeObjectAtIndex:0]; //remove current image data which has been uploaded
				}
			}//end of if(dict)
			[self sendTweet];
		}//end of if()
	}];	
	[task resume];
}

- (NSData* ) bodyData:(NSData* )data{
    if (!data || data == (id)kCFNull) return nil ;
	
	NSMutableString* mStr = [NSMutableString string];
	
	[mStr appendFormat:@"--OSCImageUpload\r\n"];
	[mStr appendFormat:@"Content-Disposition: form-data; name=\"token\"; \r\n\r\n%@\r\n",self.imageToken];
	
	[mStr appendFormat:@"--OSCImageUpload\r\n"];
	[mStr appendFormat:@"Content-Disposition: form-data; name=\"resource\"; filename=\"osc_tweet_upload.jpg\"\r\n"];
	[mStr appendFormat:@"Content-Type: image/jpg\r\n\r\n"];
	NSMutableData* mData = [[NSMutableData alloc] init];
	[mData appendData:[mStr.copy dataUsingEncoding:NSUTF8StringEncoding]];
	[mData appendData:data];
	
	[mData appendData:[@"\r\n--OSCImageUpload--\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	
	return mData.copy;
}

- (NSDictionary* ) headers{
    NSMutableDictionary *mutableHeaders = [NSMutableDictionary dictionary];
    NSString* ua = [[[NSUserDefaults alloc] initWithSuiteName:SHARE_EXTENSION_GROUP_ID] objectForKey:@"groupShareExtensionUA"];
    NSString* appToken = [[[NSUserDefaults alloc] initWithSuiteName:SHARE_EXTENSION_GROUP_ID] objectForKey:@"groupShareExtensionAppToken"];
    NSArray* cookies = [NSKeyedUnarchiver unarchiveObjectWithData:[[[NSUserDefaults alloc] initWithSuiteName:SHARE_EXTENSION_GROUP_ID] objectForKey:@"groupShareExtensionCookies"]];
    NSString* cookie = [self restoreCookieInfo:cookies];
    if (cookie) [mutableHeaders setValue:cookie forKey:@"Cookie"];
    [mutableHeaders setValue:@"en;q=1" forKey:@"Accept-Language"];
    [mutableHeaders setValue:appToken forKey:@"AppToken"];
    [mutableHeaders setValue:ua forKey:@"User-Agent"];
    return mutableHeaders.copy;
}

- (NSString* ) restoreCookieInfo:(NSArray* )cookies{
    NSMutableString* mStr = [NSMutableString string];
    if (!cookies || cookies == (id)kCFNull || cookies.count == 0) return nil;
    
    for (NSHTTPCookie* cookie in cookies) {
        [mStr appendString:[NSString stringWithFormat:@"%@=%@; ",cookie.name,cookie.value]];
    }
    
    if (mStr.length > 1) {
        mStr = [mStr substringWithRange:NSMakeRange(0, mStr.length - 1)].mutableCopy;
    }
 
    return mStr.copy;
}

-(void) playSystemSound: (BOOL) isSuccess {
	
	if (isSuccess) {
		SystemSoundID soundID;
		NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/tweet_sent.caf"];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
		AudioServicesPlaySystemSound(soundID); //success
	} else {
		SystemSoundID soundID;
		NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/ussd.caf"];
		AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundID);
		AudioServicesPlaySystemSound(soundID); // error
	}
}

@end
