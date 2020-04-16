//
//  YSScreenBrightnessTool.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSScreenBrightnessTool.h"

@implementation YSScreenBrightnessTool

+ (void)changeBrightness:(CGFloat)brightness {
    if (brightness > 1.0) {
        brightness = 1.0;
    }
    if (brightness < 0.0) {
        brightness = 0.0;
    }
    [UIScreen mainScreen].brightness = brightness;
}

+ (CGFloat)getBrightness {
    return [UIScreen mainScreen].brightness;
}

@end
