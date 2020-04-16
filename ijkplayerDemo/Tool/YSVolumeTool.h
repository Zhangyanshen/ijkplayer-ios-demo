//
//  YSVolumeTool.h
//  ijkplayerDemo
//
//  Created by 张延深 on 2020/4/16.
//  Copyright © 2020 张延深. All rights reserved.
//  系统音量

#import <UIKit/UIKit.h>

@import MediaPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface YSVolumeTool : NSObject

/*
 音量
 */
@property (assign, nonatomic) CGFloat volume;

/*
 MPVolumeView
 */
@property (strong, nonatomic, readonly) MPVolumeView *mpVolumeView;

/*
 音量slider
 */
@property (strong, nonatomic, readonly) UISlider *volumeSlider;

@end

NS_ASSUME_NONNULL_END
