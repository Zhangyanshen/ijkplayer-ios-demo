//
//  YSVolumeTool.m
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//

#import "YSVolumeTool.h"

@interface YSVolumeTool ()

@property (strong, nonatomic) MPVolumeView *mpVolumeView;
@property (strong, nonatomic) UISlider *volumeSlider;

@end

@implementation YSVolumeTool

- (instancetype)init {
    if (self = [super init]) {
        [self initMPVolumeView];
    }
    return self;
}

#pragma mark - Setters/Getters

- (void)setVolume:(CGFloat)volume {
    if (volume > 1.0) {
        volume = 1.0;
    }
    if (volume < 0.0) {
        volume = 0.0;
    }
    self.volumeSlider.value = volume;
}

- (CGFloat)volume {
    return self.volumeSlider.value;
}

#pragma mark - Private methods

- (void)initMPVolumeView {
    self.mpVolumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-30, -30, 0, 0)];
//    mpVolumeView.showsRouteButton = NO; // 是否显示AirPlay按钮
//    mpVolumeView.showsVolumeSlider = NO; // 是否显示音量条，如果设置为NO，则系统的音量条会显示
    for (UIView *view in self.mpVolumeView.subviews) {
        if ([view isKindOfClass:UISlider.class]) {
            self.volumeSlider = (UISlider *)view;
            break;
        }
    }
}

@end
