//
//  ViewController.m
//  LFURLLoadingSystem
//
//  Created by 梁芳 on 16/7/30.
//  Copyright © 2016年 梁芳. All rights reserved.
//

#import "ViewController.h"
#import "MessageUI/MessageUI.h"
#import "AddressBook/AddressBook.h"
#import "GcdTestViewController.h"

@interface ViewController () <NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLConnectionDownloadDelegate>

@property (nonatomic, nonnull, strong) UIButton *gcdTestVC;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.gcdTestVC];
    [self requestWithConn];

    
   
    
    // Do any additional setup after loading the view, typically from a nib.
}


//通过NSURLConnection完成一个简单的网络请求，或者下载操作（暂时还未区分get和post）
- (void)requestWithConn
{
    NSURL *requestURL = [[NSURL alloc] initWithString:@"http://api.mobile.meituan.com/gct/api/select/poiList"];
    //使用默认的缓存策略和timeout
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
}





- (void)requestWithDownloader
{
    
}

- (void)requestWithSession
{
    
}

#pragma NSURLConnectionDelegate
//仅执行1次，当connection出现错误时调用
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (error) {
        NSLog(@"出错了，错误信息为:%@", error);
    }
}


//仅执行1次，如果返回true,说明这个连接应该访问共享的NSURLCredentialStorage（获取证书）来响应authentication challenges
//NSLocalizedDescription=The resource could not be loaded because the App Transport Security policy requires the use of a secure connection.}
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return false;
}

//当前连接将发送一个带身份验证的https请求，提供关于challenge的所有信息，详情可详细了解 NSURLAuthenticationChallenge.h
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (challenge) {
        NSLog(@"获取身份验证信息challenge为：%@", challenge);
    }
}

#pragma NSURLConnectionDataDelegate,用于加载数据到内存

//为了继续加载一个request请求，连接connect必须改变其urls的时候会调用这个代理方法，让代理方法检查是否需要修改一个请求，如果调用了connection的cancel方法或者返回nil，这个请求就会终止
- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    NSLog(@"初始请求:%@", request);
    NSLog(@"初始返回的reponse数据:%@",response);
    
    return [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"http://api.mobile.meituan.com/gct/api/select/poiList"]];
}

//获取请求返回的状态，包括status code: headers等信息
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"请求返回的状态:%@", response);
}

//返回一个不可变的NSData类型的对象，可以用来表示当前获取data占总体数据的比例，
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"网络返回的nsdata类型的数据:%@", data);
}

//当因为连接失败或者身份验证失败，需要重新加载一个请求的时候会调用下面的方法，这个方法应该构造一个新的带autorelease的NSInputStream对象，如果没有实现，就需要将相应字节组合上传到磁盘,是一个潜在的昂贵的操作，如果返回nil，会直接取消连接
- (nullable NSInputStream *) connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request
{
    return nil;
}

//为upload上传操作提供进度回调，如果请求重新加载，下面的值会以意想不到的方式发生改变
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

//如果原始的NSURLRequest启用了缓存，下面的代理方就可以查看和修改被缓存的NSCachedURLResponse对象，如果返回nil，这个代理方法就会阻止相应资源被缓存，注意缓存响应的data方法会返回真实数据的autorelease类型的内存拷贝。需要注意不能替代connection:didReceiveData:方法来获取和积累数据
- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSLog(@"需要缓存的response:%@",cachedResponse);
    
    return nil;
}

//在connect的代理释放之前，下列方法会在所有的连接操作都成功的处理完成时调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
}

#pragma NSURLConnectionDownloadDelegate
//用于提供下载状态的进度信息，从上一个代理回调之后写入的字节的大小，写入磁盘的整体字节的大小，以及期望的整体字节的大小（如果返回0：表示大小未知）
- (void)connection:(NSURLConnection *)connection didWriteData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    
}

//当一个连接或者网络失败情况下，会调用这个代理方法，当这个连接能够恢复一个进度下载，
- (void)connectionDidResumeDownloading:(NSURLConnection *)connection totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes
{
    
}

//这个唯一一个必须实现的代理方法，用于下载完成时通知这个代理下载文件的具体位置，这个文件会放置在应用的缓存目录，并且确保delegate回调期间它是存在的，实现这个方法如果有必要可以copy或者移动下载的文件到一个persistent目录
- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)gcdTestVC
{
    if (!_gcdTestVC) {
        _gcdTestVC = [[UIButton alloc] init];
        _gcdTestVC.backgroundColor = [UIColor blueColor];
        _gcdTestVC.frame = CGRectMake(50, 50, 50, 50);
        [_gcdTestVC addTarget:self action:@selector(gotoGcdTestVC) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _gcdTestVC;
}

- (void)gotoGcdTestVC
{
    GcdTestViewController *gcd = [[GcdTestViewController alloc] init];
    [self presentViewController:gcd animated:YES completion:nil];
}

@end
