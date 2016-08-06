//
//  LFURLSession.h
//  LFURLLoadingSystem
//
//  Created by 梁芳 on 16/7/31.
//  Copyright © 2016年 梁芳. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionHandlerType)();

@interface LFURLSession : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *defaultSession;
@property (nonatomic, strong) NSURLSession *ephemeralSession;
@property (nonatomic, strong) NSURLSession *backgroundSession;

@property (nonatomic, strong) NSMutableDictionary *completeHandlerDictionary;

- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier;
- (void)callCompleteHandlerForSession:(NSString *)identifier;


@end
