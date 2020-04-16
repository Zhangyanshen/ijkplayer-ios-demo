//
//  YSCarrierTool.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSCarrierTool.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation YSCarrierTool

+ (void)loadCarrier:(void (^)(NSString * _Nonnull))block {
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        NSDictionary *carrierDic = [networkInfo serviceSubscriberCellularProviders];
        if (@available(iOS 13.0, *)) {
            [self updateCarrierInfo:carrierDic[networkInfo.dataServiceIdentifier] block:block];
        } else {
            [self updateCarrierInfo:networkInfo.subscriberCellularProvider block:block];
        }
        __weak typeof(self) weakSelf = self;
        // 监听运营商变化
        networkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = ^(NSString * _Nonnull dataServiceIdentifier) {
            CTCarrier *carrier = carrierDic[dataServiceIdentifier];
            [weakSelf updateCarrierInfo:carrier block:block];
        };
    } else {
        [self updateCarrierInfo:networkInfo.subscriberCellularProvider block:block];
        __weak typeof(self) weakSelf = self;
        networkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier * _Nonnull carrier) {
            [weakSelf updateCarrierInfo:carrier block:block];
        };
    }
}

// 更新运营商信息
+ (void)updateCarrierInfo:(CTCarrier *)carrier block:(void(^)(NSString *))block {
    NSString *carrierName;
    if (!carrier.isoCountryCode) {
        carrierName = @"无 SIM 卡";
    } else {
        carrierName = carrier.carrierName;
    }
    if (block) {
        block(carrierName);
    }
}

@end
