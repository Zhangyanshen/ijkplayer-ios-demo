//
//  YSNetworkInfoTool.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSNetworkInfoTool.h"
#import "Reachability.h"

@interface YSNetworkInfoTool ()

@end

@implementation YSNetworkInfoTool

+ (void)loadNetworkInfo:(void (^)(NSString * _Nonnull))block {
    if (!block) {
        return;
    }
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.apple.com"];
    reach.reachableBlock = ^(Reachability *reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
            block(reach.currentReachabilityString);
        });
    };
    reach.unreachableBlock = ^(Reachability *reach) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"UNREACHABLE!");
            block(@"无网");
        });
    };
    [reach startNotifier];
}

@end
