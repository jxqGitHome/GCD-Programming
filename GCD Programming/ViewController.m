//
//  ViewController.m
//  GCD Programming
//
//  Created by 姜晓强 on 15/11/4.
//  Copyright (c) 2015年 深圳莫比克. All rights reserved.
//

#import "ViewController.h"
#import "GCD.h"
@interface ViewController ()

@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UIImage     *image;
@property(nonatomic,strong)GCDTimer    *gcdTimer;
@property(nonatomic,strong)NSTimer     *normalTimer;
@property(nonatomic,strong)UIImageView *view1;
@property(nonatomic,strong)UIImageView *view2;
@property(nonatomic,strong)UIImageView *view3;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view1 = [self createImageViewWithFrame:CGRectMake(0, 0, 100, 100)];
    self.view2 = [self createImageViewWithFrame:CGRectMake(100, 0, 100, 100)];
    self.view3 = [self createImageViewWithFrame:CGRectMake(200, 0, 100, 100)];
    
    NSString *urlString1 = @"http://pic.cnitblog.com/avatar/607542/20140226182241.png";
    NSString *urlString2 = @"http://pic.cnitblog.com/avatar/708810/20141230105233.png";
    NSString *urlString3 = @"http://pic.cnitblog.com/avatar/704178/20141216150843.png";
    
    GCDSemaphore * semaphore = [[GCDSemaphore alloc] init];
    [GCDQueue executeInGlobalQueue:^{
       //图片1
        //在子线程中处理业务逻辑，在主线程中更新UI
        UIImage *image1 = [self accessDataByNetString:urlString1];
        [GCDQueue executeInMainQueue:^{
            [UIView animateWithDuration:2.f animations:^{
                self.view1.image = image1;
                self.view1.alpha = 1.f;
            } completion:^(BOOL finished){
                [semaphore signal];
            }];
        }];
    }];
    
    [GCDQueue executeInGlobalQueue:^{
        //图片2
        UIImage *image2 = [self accessDataByNetString:urlString2];
        [semaphore wait];
        [GCDQueue executeInMainQueue:^{
            [UIView animateWithDuration:2.f animations:^{
                self.view2.image = image2;
                self.view2.alpha = 1.f;
            } completion:^(BOOL finished){
                [semaphore signal];
            }];
        }];
    }];
    
    [GCDQueue executeInGlobalQueue:^{
       //图片3
        UIImage *image3 = [self accessDataByNetString:urlString3];
        [semaphore wait];
        [GCDQueue executeInMainQueue:^{
            [UIView animateWithDuration:2.f animations:^{
                self.view3.image = image3;
                self.view3.alpha = 1.f;
            } completion:^(BOOL finished) {
                [semaphore signal];
            }];
        }];
    }];
}

//创建view(优化代码)
-(UIImageView *)createImageViewWithFrame :(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.alpha        = 0.f;
    [self.view addSubview:imageView];
    return imageView;
}

-(UIImage *)accessDataByNetString : (NSString *)string {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:string]];
    NSData          *data = [NSURLConnection sendSynchronousRequest:request
                                                  returningResponse:nil
                                                              error:nil];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}


-(void)runGCDTimer {
    self.gcdTimer = [[GCDTimer alloc] initInQueue:[GCDQueue mainQueue]];
    
    [self.gcdTimer event:^{
        NSLog(@"GCDTimer");
    } timeInterval:NSEC_PER_SEC];
    
    [self.gcdTimer start];
}

-(void)delayEvent {
    NSLog(@"延时2秒");
}
-(void)serailQueue {
    //创建队列
    GCDQueue *queue = [[GCDQueue alloc] initSerial];
    //执行队列
    [queue execute:^{
        NSLog(@"1");
    }];
    
    [queue execute:^{
        NSLog(@"2");
    }];
    
    [queue execute:^{
        NSLog(@"3");
    }];
    
    [queue execute:^{
        NSLog(@"4");
    }];
    
    [queue execute:^{
        NSLog(@"5");
    }];
}
-(void)createConcurrent {
    GCDQueue *queue = [[GCDQueue alloc] initConcurrent];
    [queue execute:^{
        NSLog(@"1");
    }];
    
    [queue execute:^{
        NSLog(@"2");
    }];
    
    [queue execute:^{
        NSLog(@"3");
    }];
    
    [queue execute:^{
        NSLog(@"4");
    }];
    
    [queue execute:^{
        NSLog(@"5");
    }];

}

- (void)testviewDidLoad {
//    [super viewDidLoad];

    
    //GCD定时器
    //    [self runGCDTimer];
    
    //    //GCDGroup 管理线程的运行情况
    //    GCDGroup *group = [[GCDGroup alloc] init];
    //    GCDQueue *queue = [[GCDQueue alloc] initConcurrent];
    //
    //    [queue execute:^{
    //        sleep(1);
    //        NSLog(@"线程1执行完");
    //    } inGroup:group];
    //
    //    [queue execute:^{
    //        sleep(3);
    //        NSLog(@"线程2执行完");
    //    } inGroup:group];
    //
    //    [queue notify:^{
    //        NSLog(@"线程3执行完");
    //    } inGroup:group];
    
    
    //NSThread,GCD延时比较
    //    NSLog(@"启动");
    //    [self performSelector:@selector(delayEvent) withObject:self afterDelay:2.f];
    //    [NSObject cancelPreviousPerformRequestsWithTarget:self]; //取消延时
    //
    ////GCD 延时，不能被取消，精确度不如NSThread,但代码更为简洁。
    //    [GCDQueue executeInMainQueue:^{
    //        NSLog(@"CGD delay");
    //    } afterDelaySecs:2.f];
    //
    
    //    GCD 串行和并发执行
    //    [self serailQueue];
    //    [self createConcurrent];
    
    //    self.imageView        = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    //    self.imageView.center = self.view.center;
    //    [self.view addSubview:self.imageView];
    //
    //    [GCDQueue executeInGlobalQueue:^{
    //        //处理业务逻辑
    //        NSString *urlString   = @"http://pic.cnitblog.com/avatar/607542/20140226182241.png";
    //        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //        NSData       *picData = [NSURLConnection sendSynchronousRequest:request
    //                                                      returningResponse:nil
    //                                                                  error:nil];
    //        self.image = [UIImage imageWithData:picData];
    //
    //        [GCDQueue executeInMainQueue:^{
    //         //更新UI
    //            self.imageView.image = self.image;
    //
    //        }];
    //
    //    }];
    //信号量,必须成对出现，一个信号只能解一次锁。可以将异步线程转化成同步线程
    //    GCDSemaphore *semaphore = [[GCDSemaphore alloc] init];
    //    [semaphore signal];
    //    [semaphore wait];
    //
    //    [GCDQueue executeInGlobalQueue:^{
    //        NSLog(@"1");
    //        [semaphore signal];
    //    }];
    //
    //    [GCDQueue executeInGlobalQueue:^{
    //        [semaphore wait];
    //        NSLog(@"2");
    //        [semaphore signal];
    //    }];
    //    
    //    [GCDQueue executeInGlobalQueue:^{
    //        [semaphore wait];
    //        NSLog(@"3");
    //        [semaphore signal];
    //    }];
    //    [GCDQueue executeInGlobalQueue:^{
    //        [semaphore wait];
    //        NSLog(@"4");
    //    }];
    
}

@end
