//
//  GcdTestViewController.m
//  LFURLLoadingSystem
//
//  Created by 梁芳 on 16/8/6.
//  Copyright © 2016年 梁芳. All rights reserved.
//

#import "GcdTestViewController.h"

#ifndef __OPTIMIZE__
#define NSLog(...) printf("%f %s\n",[[NSDate date]timeIntervalSince1970],[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);
#endif


@interface GcdTestViewController ()

@property (nonatomic, strong) dispatch_queue_t globalQueue1;
@property (nonatomic, strong) dispatch_queue_t globalQueue2;
@property (nonatomic, strong) UIButton *asyncButton;
@property (nonatomic, strong) UIButton *syncButton;

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;


@end

@implementation GcdTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.asyncButton];
    [self.view addSubview:self.syncButton];
    
//    [self serialQueueTest];
//    [self concurrentQueueTest];
    [self syncMainQueue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (UIButton *)asyncButton
{
    if (!_asyncButton) {
        _asyncButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
        _asyncButton.backgroundColor = [UIColor whiteColor];
        [_asyncButton setTitle:@"asynctestteste" forState:UIControlStateNormal];
        [_asyncButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_asyncButton addTarget:self action:@selector(asyncTest) forControlEvents:UIControlEventTouchUpInside];
    }
    return _asyncButton;
}

- (UIButton *)syncButton
{
    if (!_syncButton) {
        _syncButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 120, 50, 50)];
        _syncButton.backgroundColor = [UIColor whiteColor];
        [_syncButton setTitle:@"sync" forState:UIControlStateNormal];
        [_syncButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_syncButton addTarget:self action:@selector(syncTest) forControlEvents:UIControlEventTouchUpInside];
    }
    return _syncButton;
}

- (void)asyncTest
{
    //在第一个队列分别追加两个同步任务，看同步block块是否是要等前一个执行完后才开始执行，
    self.globalQueue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(self.globalQueue1, ^{
        
        [NSThread sleepForTimeInterval:10];
    });
    
    dispatch_sync(self.globalQueue1, ^{
        NSLog(@"等待当前队列前一个任务完成后，开始追加当前block中的任务到队列");
        self.view.backgroundColor = [UIColor redColor];
        
        
    });
}

- (void)syncTest
{
    self.globalQueue2 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(self.globalQueue2, ^{
        [NSThread sleepForTimeInterval:10];
        NSLog(@"10执行完时调用");
    });
    
    dispatch_async(self.globalQueue2, ^{
        NSLog(@"不等待当前队列的前一个任务执行完成，直接将当前block任务追加到队列（前一个任务之后）,又因为当前队列是concurrent对象，所以马上执行");
        //要注意的是虽然下面注释的UI代码马上执行了，但是界面是等整个队列的任务执行完之后才响应
        //self.view.backgroundColor = [UIColor blueColor];
        //但是如果，是像下面这样把UI操作放在主线程中，界面一执行到下面block中的代码就马上更新界面了。这也回答了为什么一些耗时操作要放在异步线程，更更新界面、返回数据等的操作要放在主线程，因为这个队列返回数据之后，可能还要执行其它耗时操作，而我们可能只想拿到数据。
        dispatch_async(dispatch_get_main_queue(), ^{
            self.view.backgroundColor = [UIColor blueColor];
            
        });
        
        
    });
    
}


- (void)serialQueueTest
{
    
    //第二个参数为null，表示默认为串行队列，不为null为并行队列
    self.serialQueue = dispatch_queue_create("com.lf.serialQueue", NULL);
    //下面不管是同步还是异步添加，都是在一个线程中按照追加顺序执行的，不同的是aync异步添加任务，任务不等待前面的任务执行完，直接也是按顺序先追加到队列，而sync同步添加还必须等前一个任务执行完了再追加，执行顺序也更加肯定是不变的
    //所以最终的结论是serialqueue的任务肯定是按顺序一个个执行的，因此它主要用来解决多线程编程中多个线程更新相同资源导致的数据竞争问题，就像上一次我们组的人讨论的那个多线程访问同意资源的问题（解决办法同步锁、串行队列（自线程），）了解这么多之后，我觉得用异步串行队列就挺好，反正创建的队列都是在后台线程，又能保证数据安全
    dispatch_async(self.serialQueue, ^{
        NSLog(@"异步追加到串行队列的第一个任务");
        NSLog(@"第一个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.serialQueue, ^{
        NSLog(@"异步追加到串行队列的第二个任务");
        NSLog(@"第二个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.serialQueue, ^{
        NSLog(@"异步追加到串行队列的第三个任务");
        NSLog(@"第三个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.serialQueue, ^{
        NSLog(@"异步追加到串行队列的第四个任务");
        NSLog(@"第四个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.serialQueue, ^{
        NSLog(@"异步追加到串行队列的第五个任务");
        NSLog(@"第五个任务当前线程:%@", [NSThread currentThread]);
    });
    
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"同步追加到串行队列的第1个任务");
        NSLog(@"第1个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"同步追加到串行队列的第2个任务");
        NSLog(@"第2个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"同步追加到串行队列的第3个任务");
        NSLog(@"第3个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"同步追加到串行队列的第4个任务");
        NSLog(@"第4个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.serialQueue, ^{
        NSLog(@"同步追加到串行队列的第5个任务");
        NSLog(@"第5个任务当前线程:%@", [NSThread currentThread]);
    });
    
}

- (void)concurrentQueueTest
{
    self.concurrentQueue = dispatch_queue_create("com.lf.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    //下面的任务都不等待前面任务的执行，直接加入到队列中，并且在执行时也是在不同线程并行执行的，因此这进使用与没有数据竞争，更新同一块资源的情况
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"异步追加到并行队列的第一个任务");
        NSLog(@"第一个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"异步追加到并行队列的第二个任务");
        NSLog(@"第二个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"异步追加到并行队列的第三个任务");
        NSLog(@"第三个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"异步追加到并行队列的第四个任务");
        NSLog(@"第四个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"异步追加到并行队列的第五个任务");
        NSLog(@"第五个任务当前线程:%@", [NSThread currentThread]);
    });
    
    
    //对于下面的sync，任务都要等前一个任务执行完之后追加到队列，所以没必要使用concurrent队列，因为总是只需要开辟一个线程，好奇怪的是看打印信息，下面的操作貌似都在主队列的主线程?（可以参考一下这篇博客说的http://my.oschina.net/grant110/blog/162515） 那我直接把下面的并发队列改成主队列又会是什么情况呢？后面测试的结果是直接崩了
    
    //后面自己又想了一下，其它队列和线程是两个不同的概念和东西，线程是实际去执行任务的东西，而队列相当于中间的一个helper类（中间人），队列中的任务可以在系统的任何线程（包括主线程）去执行。而主队列一定是只在主线程执行，这个就是主队列给我们封装好了的，
     //因此前面DISPATCH_QUEUE_CONCURRENT 的queue 在使用sync时优先使用主线程(当前线程)就不足为奇了
    
    //因为我没可以把一个任务异步的加入主队列，但是同步的加入主队列是不行的，会出现死锁
    
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"同步追加到并行队列的第1个任务");
        NSLog(@"第1个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"同步追加到并行队列的第2个任务");
        NSLog(@"第2个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"同步追加到病并行队列的第3个任务");
        NSLog(@"第3个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"同步追加到并行队列的第4个任务");
        NSLog(@"第4个任务当前线程:%@", [NSThread currentThread]);
    });
    dispatch_sync(self.concurrentQueue, ^{
        NSLog(@"同步追加到并行队列的第5个任务");
        NSLog(@"第5个任务当前线程:%@", [NSThread currentThread]);
    });

    
    
}


- (void)syncMainQueue
{
    
    //最后的结果是，下面的代码必崩，因为下面的这个block任务总是要等前面的任务完成， 而前面的主队列的任务要等下面这个block执行完，所以循环等待，类似于死锁，但是把main_queue改成concurrentqueue就是可以的？再按照前面的意思就解释不通了，所以下面的问题还需要有一个更好的解释
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        NSLog(@"这里会不会卡住，就不再执行了,结果是，crash了");
        
    });
}




@end
