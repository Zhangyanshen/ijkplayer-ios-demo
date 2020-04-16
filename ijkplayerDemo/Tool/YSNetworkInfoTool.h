//
//  YSNetworkInfoTool.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//  网络相关（4G、WiFi等）

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSNetworkInfoTool : NSObject

/*
 获取网络信息
 */
+ (void)loadNetworkInfo:(void(^)(NSString *info))block;

@end

NS_ASSUME_NONNULL_END
