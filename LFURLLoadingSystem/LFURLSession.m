//
//  LFURLSession.m
//  LFURLLoadingSystem
//
//  Created by 梁芳 on 16/7/31.
//  Copyright © 2016年 梁芳. All rights reserved.
//

#import "LFURLSession.h"


@implementation LFURLSession

- (instancetype)init
{
    if (self = [super init]) {
        self.completeHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        [self commomInit];
        return self;
        
    }
    return nil;
}

- (void)commomInit
{
    NSURLSessionConfiguration *defaultConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSessionConfiguration *ephemeralConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    //backgroundsession之所以有一个identifier参数是为了后台与前台做关联
    NSURLSessionConfiguration *backgroundConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"LFBackgroundSessionIdentifier"];
    
    //给defaultsession创建缓存目录
    NSString *cachePath = @"/LFCacheDirectory";
    NSArray *myPathList = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *myPath = [myPathList objectAtIndex:0];
    NSString *bundleIdentifier = [NSBundle mainBundle];
    NSString *fullCachePath = [[myPath stringByAppendingPathComponent:bundleIdentifier] stringByAppendingPathComponent:cachePath];
    NSURLCache *myCache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:fullCachePath];
    defaultConfig.URLCache = myCache;
    defaultConfig.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
    
    self.defaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.ephemeralSession = [NSURLSession sessionWithConfiguration:ephemeralConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.backgroundSession = [NSURLSession sessionWithConfiguration:backgroundConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    //当创建一个新的session对象，会对它的config参数执行深拷贝，如果修改这个config也不会对之前的config产生影响
    NSURLSession *secondDefaultSession = [NSURLSession sessionWithConfiguration:defaultConfig delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    //使用系统提供的delegate执行请求（delegate置为nil）,其中resume表示如果暂停，重新请求任务
    [[secondDefaultSession dataTaskWithURL:[NSURL URLWithString:@"http://www.example.com/"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Got response %@ with error %@.\n", response, error);
        } else {
            NSLog(@"DATA:\n%@\nEND DATA\n",
                  [[NSString alloc] initWithData: data
                                        encoding: NSUTF8StringEncoding]);
        }
        
    }] resume];
    
    //下面是不同task类型的实现
    
    //使用自定义的delegate获取数据，至少需要实现后面的两个代理方法
    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    NSURLSessionDataTask *dataTask = [self.defaultSession dataTaskWithURL:url];
    [dataTask resume];
    
    //实现文件下载操作
    NSURL *downloadURL = [NSURL URLWithString:@"https://developer.apple.com/library/ios/documentation/Cocoa/Reference/"
                          "Foundation/ObjC_classic/FoundationObjC.pdf"];
    NSURLSessionDownloadTask *downloadTask = [self.backgroundSession downloadTaskWithURL:downloadURL];
    [downloadTask resume];
    
}

//downloadTask Delegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"Session %@ download task %@ finished downloading to URL %@\n",
          session, downloadTask, location);
    [self callCompleteHandlerForSession:self.backgroundSession.configuration.identifier];
    
    //读取新下载的文件
#define READ_THE_FILE 0
#if READ_THE_FILE
    NSError *err = nil;
    NSFileHandle *fh = [NSFileHandle fileHandleForReadingFromURL:location error:&err];
#else
    NSError *err = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cacheDir = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Caches"];
    NSURL *cacheDirURL = [NSURL fileURLWithPath:cacheDir];
    if ([fileManager moveItemAtURL:location toURL:cacheDirURL error:&err]) {
         /* Store some reference to the new URL */
    } else {
        
    }
    
#endif
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Session %@ download task %@ wrote an additional %lld bytes (total %lld bytes) out of an expected %lld bytes.\n",
          session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

//用于暂停后的重新请求问题
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
}

- (void)addCompletionHandler:(CompletionHandlerType)handler forSession:(NSString *)identifier
{
    if ([self .completeHandlerDictionary objectForKey:identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    [self.completeHandlerDictionary setObject:handler forKey:identifier];
}


- (void)callCompleteHandlerForSession:(NSString *)identifier
{
    CompletionHandlerType handler = [self.completeHandlerDictionary objectForKey:identifier];
    if (handler) {
        [self.completeHandlerDictionary removeObjectForKey:identifier];
        NSLog(@"Calling completion handler.\n");
        handler();
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier)
        [self callCompleteHandlerForSession:session.configuration.identifier];
}

@end
