//
//  YSCarrierTool.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//  运营商相关信息

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSCarrierTool : NSObject

/*
 获取运营商信息
 */
+ (void)loadCarrier:(void(^)(NSString *carrierName))block;

@end

NS_ASSUME_NONNULL_END
