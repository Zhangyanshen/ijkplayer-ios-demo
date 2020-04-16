//
//  YSScreenBrightnessTool.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//  屏幕亮度

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSScreenBrightnessTool : NSObject

/*
 改变屏幕亮度
 */
+ (void)changeBrightness:(CGFloat)brightness;

/*
 获取屏幕亮度
 */
+ (CGFloat)getBrightness;

@end

NS_ASSUME_NONNULL_END
