//
//  YSBatteryTool.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//  电池相关信息（电量、电池状态）

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^YSBatteryStatus)(NSString *status, UIColor *color);
typedef void(^YSBatteryLevel)(float level, UIColor *color);

@interface YSBatteryTool : NSObject

//@property (strong, nonatomic, readonly) UIColor *color;
/*
 初始化电池
 */
+ (instancetype)batteryToolWithStatus:(YSBatteryStatus)status
                                level:(YSBatteryLevel)level;

@end

NS_ASSUME_NONNULL_END
