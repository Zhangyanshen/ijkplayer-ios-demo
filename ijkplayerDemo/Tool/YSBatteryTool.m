//
//  YSBatteryTool.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSBatteryTool.h"

@interface YSBatteryTool ()

@property (copy, nonatomic) YSBatteryStatus status;
@property (copy, nonatomic) YSBatteryLevel level;
@property (strong, nonatomic) UIColor *color;

@end

@implementation YSBatteryTool

- (instancetype)initWithStatus:(YSBatteryStatus)status
                         level:(YSBatteryLevel)level
{
    if (self = [super init]) {
        // 开启电池监测
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        self.status = status;
        self.level = level;
        [self addNotifications];
        [self loadBatteryLevel];
        [self loadBatteryState];
    }
    return self;
}

+ (instancetype)batteryToolWithStatus:(YSBatteryStatus)status
                                level:(YSBatteryLevel)level
{
    return [[self alloc] initWithStatus:status level:level];
}

#pragma mark - Event response

- (void)handleBatteryStateDidChangeNotification:(NSNotification *)notification {
    [self loadBatteryState];
}

- (void)handleBatteryLevelDidChangeNotification:(NSNotification *)notification {
    [self loadBatteryLevel];
}

#pragma mark - Private methods

// 添加通知
- (void)addNotifications {
    // 电池状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBatteryStateDidChangeNotification:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
    // 电池电量
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBatteryLevelDidChangeNotification:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
}

// 移除通知
- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 加载电量信息
- (void)loadBatteryLevel {
    [self loadBatteryState];
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (self.level) {
        self.level(batteryLevel, self.color);
    }
}

// 加载电池状态信息
- (void)loadBatteryState {
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    NSString *statusStr = @"未知";
    switch (batteryState) {
        case UIDeviceBatteryStateCharging: // 正在充电(<100%)
        {
            statusStr = @"充电中";
            self.color = [UIColor greenColor];
        }
            break;
        case UIDeviceBatteryStateFull: // 正在充电(100%)
        {
            statusStr = @"已充满";
            self.color = [UIColor greenColor];
        }
            break;
        case UIDeviceBatteryStateUnplugged:
        {
            statusStr = @"未充电";
            if ([UIDevice currentDevice].batteryLevel > 20) {
                self.color = [UIColor whiteColor];
            } else {
                self.color = [UIColor redColor];
            }
        }
            break;
        case UIDeviceBatteryStateUnknown:
        {
            statusStr = @"未知";
            self.color = [UIColor whiteColor];
        }
            break;
        default:
        {
            self.color = [UIColor whiteColor];
        }
            break;
    }
    if (self.status) {
        self.status(statusStr, self.color);
    }
}

#pragma mark - dealloc

- (void)dealloc {
    [self removeNotifications];
    NSLog(@"%s", __func__);
}

@end
