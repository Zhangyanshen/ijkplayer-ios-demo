//
//  YSLiveListViewController.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/12.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSLiveListViewController.h"
#import "YSLiveListCell.h"
#import "UIImageView+WebCache.h"
#import "YSLiveViewController.h"

typedef void(^YSRunLoopBlock)(void);

@interface YSLiveListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *liveArray;
@property (strong, nonatomic) NSMutableArray *taskArray;
@property (assign, nonatomic) NSUInteger maxTaskCount;

@end

@implementation YSLiveListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.maxTaskCount = 50;
    self.title = @"直播";
    self.tableView.tableFooterView = [UIView new];
    self.tableView.rowHeight = 400;
    [self loadLives];
    // 添加RunLoop observer
    [self addRunLoopObserver];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = nil;
    cellId = NSStringFromClass([YSLiveListCell class]);
    YSLiveListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *dic = self.liveArray[indexPath.row];
//    [self addRunLoopTask:^{
        if (dic[@"creator"][@"albums"] && [dic[@"creator"][@"albums"] count] > 0) {
            [cell.avatorImageView sd_setImageWithURL:[NSURL URLWithString:[dic[@"creator"][@"albums"] objectAtIndex:0]] placeholderImage:nil];
        }
        cell.nameLbl.text = dic[@"name"];
        cell.areaLbl.text = dic[@"city"];
        cell.visitCountLbl.text = dic[@"real_number_text"];
        [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:dic[@"creator"][@"portrait"]] placeholderImage:nil];
//    }];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.liveArray[indexPath.row];
    YSLiveViewController *liveVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"YSLiveViewController"];
    liveVC.liveUrlStr = dic[@"stream_addr"];
    liveVC.coverUrlStr = dic[@"creator"][@"portrait"];
    [self.navigationController pushViewController:liveVC animated:YES];
}

#pragma mark - Setters/Getters

- (NSMutableArray *)liveArray {
    if (!_liveArray) {
        _liveArray = [NSMutableArray array];
    }
    return _liveArray;
}

- (NSMutableArray *)taskArray {
    if (!_taskArray) {
        _taskArray = [NSMutableArray array];
    }
    return _taskArray;
}

#pragma mark - Private methods

- (void)loadLives {
    [self.activityIndicatorView startAnimating];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"http://service.inke.com/api/live/simpleall?&gender=1&gps_info=116.346844%2C40.090467&loc_info=CN%2C%E5%8C%97%E4%BA%AC%E5%B8%82%2C%E5%8C%97%E4%BA%AC%E5%B8%82&is_new_user=1&lc=0000000000000053&cc=TG0001&cv=IK4.0.30_Iphone&proto=7&idfa=D7D0D5A2-3073-4A74-A726-98BE8B4E8F38&idfv=58A18E13-A21D-456D-B6D8-7499948B379D&devi=54b68af1895085419f7f8978d95d95257dd44f93&osversion=ios_10.300000&ua=iPhone6_2&imei=&imsi=&uid=450515766&sid=20XNNoa5VwMozGALfmi2xN1YCfLWvEq7aJuTHTQLu8bT88i1aNbi0&conn=wifi&mtid=391bb3520c38e0444ba0b3975f4bb1aa&mtxid=f0b42913a33c&logid=162,210&s_sg=3111b3a0092d652ab3bcb218099968de&s_sc=100&s_st=1492954889"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            if (error) {
                NSLog(@"获取直播数据失败：%@", error);
                return;
            }
            if (data) {
                NSError *err;
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&err];
                if (err) {
                    NSLog(@"json转model失败：%@", err);
                    return;
                }
                [self.liveArray addObjectsFromArray:(NSArray *)dic[@"lives"]];
                [self.tableView reloadData];
            }
        });
    }];
    [task resume];
}

- (void)addRunLoopObserver {
    // 1.获取当前线程的RunLoop
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    // 2.创建观察者
    __weak typeof(self) wself = self;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (wself.taskArray.count == 0) {
            return;
        }
        YSRunLoopBlock block = wself.taskArray[0];
        if (block) {
            block();
        }
        [wself.taskArray removeObjectAtIndex:0];
    });
    // 3.添加观察者
    CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
    // 4.释放观察者
    CFRelease(observer);
}

- (void)addRunLoopTask:(YSRunLoopBlock)task {
    if (self.taskArray.count >= self.maxTaskCount) {
        [self.taskArray removeObjectAtIndex:0];
    }
    [self.taskArray addObject:task];
}

#pragma mark - dealloc

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
